# Blog Post Generator — Setup Guide

## 1. Install Marketing Skills (default)

```powershell
npx skills add coreyhaines31/marketingskills --global -y
```

**Install the catalog by default.** The `skills` CLI detects your agent
(Hermes Agent, OpenCode, etc.), installs into that agent's skill directory,
and maintains a lockfile — it is not a plain file copy. Verify:

```powershell
npx skills list --global
```

> **Fallback (emergency-only):** if the catalog genuinely cannot be installed,
> this skill's bundled `references/` files (`writing-rules.md`,
> `claims-policy.md`) still produce contract-correct, grounded output. Treat
> that as degraded, NOT a parallel choice — the bundled references are static
> snapshots and can go stale (real example: DALL-E 3 deprecation and current
> model guidance live in the `image` catalog skill, not in the bundled
> fallback). Flag "marketing skills not installed" explicitly in the output if
> you run this way. See `docs/EXECUTION_MODES.md`.

## 2. Add the Blog Post Skill

Place the `blog-post-generator` folder in your project's `.agents/skills/` directory:

```
YourProject/.agents/skills/blog-post-generator/SKILL.md
YourProject/.agents/skills/blog-post-generator/SETUP.md
YourProject/.agents/skills/blog-post-generator/references/writing-rules.md
YourProject/.agents/skills/blog-post-generator/references/claims-policy.md
```

If using git, commit `.agents/` — teammates get it on clone.

## 3. Verify

```powershell
npx skills list --global
```

You should see `blog-post-generator` in the list.

## 4. Dependencies

- Requires the marketing skills from `coreyhaines31/marketingskills` at `~/.agents/skills/` (`copywriting`, `seo-audit`, `ai-seo`)
- No Python, no external libraries — output is pure HTML/CSS
