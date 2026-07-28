param(
    [switch]$Force,
    [switch]$SmokeTest,
    [switch]$Verbose
)

$Script:ErrorActionPreference = "Stop"
$Green  = "Green"
$Cyan   = "Cyan"
$Yellow = "Yellow"
$Red    = "Red"
$Dim    = "DarkGray"

$openCodeDir   = "$env:USERPROFILE\.config\opencode\skills"
$globalSkills  = "$env:USERPROFILE\.agents\skills"
$repoSkillsDir = Join-Path $PSScriptRoot ".agents\skills"
$testDir       = Join-Path $PSScriptRoot "_test"
$passedStages  = @()
$failedStages  = @()
$overallPass   = $true

Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  Monthly Content Toolkit — Setup"       -ForegroundColor $Cyan
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""

# ── Pre-flight checks ──
Write-Host "[Pre-flight] Checking prerequisites..." -ForegroundColor $Cyan

$allPrereqs = $true

# 1. Node.js
$nodeVer = node --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  `u{2705} Node.js $nodeVer" -ForegroundColor $Green
} else {
    Write-Host "  `u{274C} Node.js not found — install from https://nodejs.org/" -ForegroundColor $Red
    $allPrereqs = $false
}

# 2. npx
$npxVer = npx --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  `u{2705} npx $npxVer" -ForegroundColor $Green
} else {
    Write-Host "  `u{274C} npx not found (comes with Node.js)" -ForegroundColor $Red
    $allPrereqs = $false
}

# 3. OpenCode
$opencodeFound = $false
$opencodePaths = @(
    "$env:USERPROFILE\.config\opencode",
    "$env:LOCALAPPDATA\Programs\opencode",
    "$env:ProgramFiles\opencode"
)
$opencodeCmd = Get-Command opencode -ErrorAction SilentlyContinue
if ($opencodeCmd) {
    $opencodeFound = $true
    Write-Host "  `u{2705} OpenCode found: $($opencodeCmd.Source)" -ForegroundColor $Green
} else {
    foreach ($p in $opencodePaths) {
        if (Test-Path $p) { $opencodeFound = $true; break }
    }
    if (-not $opencodeFound) {
        Write-Host "  `u{274C} OpenCode not found — install from https://opencode.ai" -ForegroundColor $Red
        $allPrereqs = $false
    } else {
        Write-Host "  `u{2705} OpenCode detected" -ForegroundColor $Green
    }
}

if (-not $allPrereqs) {
    Write-Host "`n  Fix the issues above, then re-run: .\setup.ps1" -ForegroundColor $Yellow
    exit 1
}

# 4. gh CLI (informational, non-blocking)
Write-Host ""
Write-Host "[Info] Checking optional tools..." -ForegroundColor $Cyan
$ghOk = $false
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "  `u{26A0}  gh CLI not found — needed for landing page deploy" -ForegroundColor $Yellow
    Write-Host "         Install: winget install GitHub.cli" -ForegroundColor $Dim
} else {
    $ghStatus = gh auth status 2>&1
    if ($ghStatus -match "Logged in|authenticated") {
        Write-Host "  `u{2705} GitHub CLI: authenticated" -ForegroundColor $Green
        $ghOk = $true
    } else {
        Write-Host "  `u{26A0}  GitHub CLI: not authenticated — run: gh auth login" -ForegroundColor $Yellow
    }
}

# 5. Vercel CLI (informational, non-blocking)
$vOk = $false
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "  `u{26A0}  vercel CLI not found — needed for landing page deploy" -ForegroundColor $Yellow
    Write-Host "         Install: npm install -g vercel" -ForegroundColor $Dim
} else {
    $vWho = vercel whoami 2>&1
    if ($vWho -and $vWho -notmatch "Error|not logged in|No such") {
        Write-Host "  `u{2705} Vercel CLI: authenticated ($vWho)" -ForegroundColor $Green
        $vOk = $true
    } else {
        Write-Host "  `u{26A0}  Vercel CLI: not authenticated — run: vercel login" -ForegroundColor $Yellow
    }
}

# 6. _test fixture files (if -SmokeTest)
if ($SmokeTest) {
    $fixtures = @(
        "TestBrand_brand_guide.md",
        ".agents\product-marketing.md",
        "01_knowledge_base\00_Sample_Message.html",
        "03_monthly_cycles\2026-SMOKE\CYCLE_CONTEXT.md"
    )
    $allFixtures = $true
    foreach ($f in $fixtures) {
        if (-not (Test-Path (Join-Path $testDir $f))) {
            Write-Host "  `u{274C} Smoke test fixture missing: _test\$f" -ForegroundColor $Red
            $allFixtures = $false
        }
    }
    if ($allFixtures) {
        Write-Host "  `u{2705} Smoke test fixtures: present" -ForegroundColor $Green
    } else {
        Write-Host "  Smoke test skipped — fix fixtures and re-run with -SmokeTest" -ForegroundColor $Yellow
        $SmokeTest = $false
    }
}

# ── Step 1: Install marketing sub-skills ──
Write-Host ""
Write-Host "[1/4] Installing marketing sub-skills (coreyhaines31/marketingskills)..." -ForegroundColor $Cyan
Write-Host "      This may take a minute the first time." -ForegroundColor $Dim

$npxArgs = @("skills", "add", "coreyhaines31/marketingskills", "--global", "-y", "--force")
if (-not $Force) { $npxArgs = $npxArgs[0..4] }
try {
    $output = npx @npxArgs 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  `u{2705} Marketing sub-skills installed" -ForegroundColor $Green
    } else {
        Write-Host "  `u{26A0}  npx exited $LASTEXITCODE — output above. Continuing..." -ForegroundColor $Yellow
    }
} catch {
    Write-Host "  `u{274C} Failed to install marketing sub-skills" -ForegroundColor $Red
    Write-Host "    Node.js and npm/npx are required: node --version / npm --version" -ForegroundColor $Yellow
    Write-Host "    Then re-run: .\setup.ps1" -ForegroundColor $Yellow
    exit 1
}

# ── Step 2: Move skills into OpenCode's directory ──
Write-Host ""
Write-Host "[2/4] Moving skills to OpenCode..." -ForegroundColor $Cyan

# 2a: Move globally-installed marketing skills to OpenCode
if (Test-Path $globalSkills) {
    $count = 0
    Get-ChildItem -Path $globalSkills -Directory | ForEach-Object {
        $dst = Join-Path $openCodeDir $_.Name
        Copy-Item -Path $_.FullName -Destination $dst -Recurse -Force
        $count++
    }
    Remove-Item -Path $globalSkills -Recurse -Force
    Write-Host "  `u{2705} $count marketing sub-skills moved to $openCodeDir" -ForegroundColor $Green
} else {
    Write-Host "  `u{26A0}  No global skills found at $globalSkills — may already be in OpenCode" -ForegroundColor $Yellow
}

# 2b: Copy custom skills from repo to OpenCode
$customSkills = @(
    "content-plan-generator",
    "carousel-prompt-generator",
    "blog-post-generator",
    "infographic-brief-generator",
    "monthly-drop-landing-page"
)

$allFound = $true
foreach ($skill in $customSkills) {
    $src = Join-Path $repoSkillsDir $skill
    $dst = Join-Path $openCodeDir $skill
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        if ($Verbose) { Write-Host "    $skill -> $dst" -ForegroundColor $Dim }
    } else {
        Write-Host "  `u{274C} $skill — SKILL.md not found at $src" -ForegroundColor $Red
        $allFound = $false
    }
}

if (-not $allFound) {
    Write-Host "`n  Repo appears incomplete. Try re-cloning." -ForegroundColor $Red
    exit 1
}
Write-Host "  `u{2705} 5 custom skills copied to OpenCode" -ForegroundColor $Green

# ── Step 3: Install landing page template dependencies ──
Write-Host ""
Write-Host "[3/4] Installing landing page template dependencies..." -ForegroundColor $Cyan

$templateDir = Join-Path $openCodeDir "monthly-drop-landing-page\template"
if (Test-Path $templateDir) {
    Push-Location $templateDir
    try {
        $npmOut = npm install 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  `u{2705} Template dependencies ready" -ForegroundColor $Green
        } else {
            Write-Host "  `u{26A0}  npm install returned $LASTEXITCODE" -ForegroundColor $Yellow
        }
    } catch {
        Write-Host "  `u{26A0}  npm install failed — re-run manually:" -ForegroundColor $Yellow
        Write-Host "    cd '$templateDir'; npm install" -ForegroundColor $Dim
    }
    Pop-Location
} else {
    Write-Host "  `u{26A0}  Template directory not found — npm install skipped" -ForegroundColor $Yellow
}

# ── Step 4: Summary ──
Write-Host ""
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  Setup complete!" -ForegroundColor $Green
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""
Write-Host "  5 custom + 46 marketing skills installed" -ForegroundColor $Cyan
Write-Host "  Location: $openCodeDir" -ForegroundColor $Dim
Write-Host ""
Write-Host "  `u{2705} Skills installed in OpenCode — this repo can be deleted." -ForegroundColor $Green
Write-Host ""

# ── ── ── ── ── ── ── ──
# Smoke Test
# ── ── ── ── ── ── ── ──
if (-not $SmokeTest) {
    Write-Host "  Next steps:" -ForegroundColor $Yellow
    Write-Host "    1. Clone your workspace repo" -ForegroundColor $White
    Write-Host "    2. Open it in OpenCode" -ForegroundColor $White
    Write-Host "    3. Run: 'Create the content plan for [month] for [Brand]'" -ForegroundColor $White
    exit 0
}

Write-Host "========================================" -ForegroundColor $Cyan
Write-Host "  Smoke Test" -ForegroundColor $Cyan
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""
Write-Host "  Running full pipeline against _test/TestBrand (4 stages)" -ForegroundColor $White
Write-Host "  This will create a temporary Vercel project and delete it." -ForegroundColor $Dim
Write-Host ""

function Invoke-SmokeStage {
    param([string]$StageName, [string]$Prompt, [int]$TimeoutMinutes)
    Write-Host "  Stage $StageName (timeout ${TimeoutMinutes}min)..." -ForegroundColor $Cyan

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'

    $result = opencode run $Prompt 2>&1
    $exitCode = $LASTEXITCODE

    $ErrorActionPreference = $prevEAP

    if ($exitCode -eq 0 -and $result -notmatch "(?i)error|failed|timed.?out") {
        Write-Host "  `u{2705} $StageName passed" -ForegroundColor $Green
        $global:passedStages += $StageName
        return $true
    } else {
        Write-Host "  `u{274C} $StageName failed (exit $exitCode)" -ForegroundColor $Red
        if ($Verbose) { Write-Host $result -ForegroundColor $Dim }
        $global:failedStages += $StageName
        $global:overallPass = $false
        return $false
    }
}

# Stage 1: Content Plan
$contentPlanPrompt = @"
[AUTO-MODE]
Use the content-plan-generator skill for TestBrand, cycle 2026-SMOKE.

Brand: TestBrand
Language: English
Brand directory: _test

Direction: Smoke test only. One carousel, one blog post. Minimal output for pipeline validation.

Deliverables:
- Carousels: 1
- Blog posts: 1
- Newsletters: 0
- Infographics: 0

Output: _test/03_monthly_cycles/2026-SMOKE/01_content_plan/output/

IMPORTANT: Generate .md then .html immediately. Do NOT ask for approval at any step. Proceed automatically.
"@

$ok = Invoke-SmokeStage -StageName "1/4 Content Plan" -Prompt $contentPlanPrompt -TimeoutMinutes 15
if (-not $ok) { Write-Host "`nStopping — Stage 1 failed." -ForegroundColor $Red; exit 1 }

# Resolve content plan HTML filename (varies by skill output)
$contentPlanHtml = Get-ChildItem "_test/03_monthly_cycles/2026-SMOKE/01_content_plan/output/*.html" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $contentPlanHtml) {
    Write-Host "  `u{274C} No content plan HTML found after Stage 1" -ForegroundColor $Red
    exit 1
}
$cpName = $contentPlanHtml.Name

# Stage 2: Carousel Prompts
$carouselPrompt = @"
[AUTO-MODE]
Use the carousel-prompt-generator skill for TestBrand, cycle 2026-SMOKE.

Content plan: _test/03_monthly_cycles/2026-SMOKE/01_content_plan/output/$cpName
Brand guide: _test/TestBrand_brand_guide.md
Brand directory: _test
Language: English
Output: _test/03_monthly_cycles/2026-SMOKE/02_prompts_and_copy/output/

IMPORTANT: Generate .md then .html immediately. Do NOT ask for approval at any step. Proceed automatically.
"@

$ok = Invoke-SmokeStage -StageName "2/4 Carousel Prompts" -Prompt $carouselPrompt -TimeoutMinutes 10
if (-not $ok) { Write-Host "`nStopping — Stage 2 failed." -ForegroundColor $Red; exit 1 }

# Stage 3: Blog Posts
$blogPrompt = @"
[AUTO-MODE]
Use the blog-post-generator skill for TestBrand, cycle 2026-SMOKE.

Content plan: _test/03_monthly_cycles/2026-SMOKE/01_content_plan/output/$cpName
Brand guide: _test/TestBrand_brand_guide.md
Knowledge base: _test/01_knowledge_base/
Brand directory: _test
Language: English
Output: _test/03_monthly_cycles/2026-SMOKE/02_prompts_and_copy/output/

IMPORTANT: Generate .md blog posts then generate .html immediately. Do NOT ask for approval at any step. Proceed automatically.
"@

$ok = Invoke-SmokeStage -StageName "3/4 Blog Posts" -Prompt $blogPrompt -TimeoutMinutes 15
if (-not $ok) { Write-Host "`nStopping — Stage 3 failed." -ForegroundColor $Red; exit 1 }

# Resolve filenames for Stage 4
$carouselPromptsHtml = Get-ChildItem "_test/03_monthly_cycles/2026-SMOKE/02_prompts_and_copy/output/*Carousel_Prompts*.html" -ErrorAction SilentlyContinue | Select-Object -First 1
$blogPostsHtml = Get-ChildItem "_test/03_monthly_cycles/2026-SMOKE/02_prompts_and_copy/output/*Blog_Posts*.html" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $carouselPromptsHtml -or -not $blogPostsHtml) {
    Write-Host "  `u{274C} Missing carousel or blog HTML output — cannot run Stage 4" -ForegroundColor $Red
    exit 1
}

# Stage 4: Landing Page + Vercel Deploy
$landingPrompt = @"
[AUTO-MODE]
Use the monthly-drop-landing-page skill for TestBrand, cycle 2026-SMOKE.

Content plan: _test/03_monthly_cycles/2026-SMOKE/01_content_plan/output/$cpName
Carousel prompts: _test/03_monthly_cycles/2026-SMOKE/02_prompts_and_copy/output/$($carouselPromptsHtml.Name)
Blog posts: _test/03_monthly_cycles/2026-SMOKE/02_prompts_and_copy/output/$($blogPostsHtml.Name)
Brand guide: _test/TestBrand_brand_guide.md
Brand directory: _test
Output: _test/03_monthly_cycles/2026-SMOKE/05_landing_page/output/
Image fallback: placeholder — no images were generated for this smoke test. Use the skill's built-in 1x1 placeholder PNG for every missing image path.

IMPORTANT: Generate the landing page immediately. Do NOT ask for approval.
After npx vite build succeeds, deploy using:
  vercel link --project testbrand-monthly-drops --yes
  vercel --prod --yes
Do NOT use gh repo create for this smoke test.
After vercel deploy succeeds, write the deployment URL to a file named deploy_url.txt in the output directory. Confirm .vercel/project.json was created.
Proceed automatically.
"@

$ok = Invoke-SmokeStage -StageName "4/4 Landing Page + Deploy" -Prompt $landingPrompt -TimeoutMinutes 20

# ── Verify deploy ──
if ($ok) {
    Write-Host ""
    Write-Host "  Verifying deployment..." -ForegroundColor $Cyan

    $outputDir = "_test/03_monthly_cycles/2026-SMOKE/05_landing_page/output"

    # Read deploy_url.txt
    $deployUrlPath = Join-Path $outputDir "deploy_url.txt"
    if (Test-Path $deployUrlPath) {
        $deployUrl = Get-Content $deployUrlPath
        Write-Host "  `u{2705} deploy_url.txt: $deployUrl" -ForegroundColor $Green
    } else {
        Write-Host "  `u{26A0}  deploy_url.txt not found — assuming deploy succeeded" -ForegroundColor $Yellow
        $deployUrl = $null
    }

    # Read .vercel/project.json for project name
    $vercelProjectPath = Join-Path $outputDir ".vercel/project.json"
    if (Test-Path $vercelProjectPath) {
        $vJson = Get-Content $vercelProjectPath | ConvertFrom-Json
        $projectName = $vJson.projectName
        Write-Host "  `u{2705} .vercel/project.json: projectName=$projectName" -ForegroundColor $Green
    } else {
        Write-Host "  `u{26A0}  .vercel/project.json not found" -ForegroundColor $Yellow
        $projectName = "testbrand-monthly-drops"
    }

    # Verify URL responds
    if ($deployUrl) {
        try {
            $null = Invoke-WebRequest -Uri $deployUrl -Method GET -TimeoutSec 30
            Write-Host "  `u{2705} URL responds: $deployUrl" -ForegroundColor $Green
        } catch {
            Write-Host "  `u{26A0}  URL did not respond within 30s — deploy may still be in progress" -ForegroundColor $Yellow
            Write-Host "     URL: $deployUrl" -ForegroundColor $Dim
        }
    }

    # Cleanup: delete Vercel project
    Write-Host ""
    Write-Host "  Cleaning up Vercel project..." -ForegroundColor $Cyan
    try {
        $rmOut = vercel project rm $projectName --yes 2>&1
        Write-Host "  `u{2705} Vercel project '$projectName' deleted" -ForegroundColor $Green
    } catch {
        Write-Host "  `u{26A0}  Could not delete Vercel project '$projectName' — delete manually" -ForegroundColor $Yellow
    }
}

# ── Cleanup: delete local smoke test output ──
Write-Host "  Cleaning up local smoke test output..." -ForegroundColor $Cyan
$smokeCycleDir = "_test/03_monthly_cycles/2026-SMOKE"
if (Test-Path $smokeCycleDir) {
    Remove-Item $smokeCycleDir -Recurse -Force
    Write-Host "  `u{2705} Local output cleaned" -ForegroundColor $Green
}

# ── Smoke test result ──
Write-Host ""
Write-Host "========================================" -ForegroundColor $Cyan
if ($overallPass) {
    Write-Host "  Smoke test: PASSED" -ForegroundColor $Green
} else {
    Write-Host "  Smoke test: FAILED" -ForegroundColor $Red
}
Write-Host "========================================" -ForegroundColor $Cyan
Write-Host ""

if ($passedStages.Count -gt 0) {
    Write-Host "  Passed: $($passedStages.Count)/4" -ForegroundColor $Green
    foreach ($s in $passedStages) { Write-Host "    `u{2705} $s" -ForegroundColor $Green }
}
if ($failedStages.Count -gt 0) {
    Write-Host "  Failed: $($failedStages.Count)/4" -ForegroundColor $Red
    foreach ($s in $failedStages) { Write-Host "    `u{274C} $s" -ForegroundColor $Red }
}

Write-Host ""
if ($overallPass) {
    Write-Host "  Everything works. This repo can be deleted." -ForegroundColor $Green
    Write-Host "  Clone your workspace repo to start real content work." -ForegroundColor $White
} else {
    Write-Host "  Check output above for failure details." -ForegroundColor $Yellow
    Write-Host "  Fix the issue and re-run: .\setup.ps1 -Force -SmokeTest" -ForegroundColor $Yellow
}

exit $(if ($overallPass) { 0 } else { 1 })
