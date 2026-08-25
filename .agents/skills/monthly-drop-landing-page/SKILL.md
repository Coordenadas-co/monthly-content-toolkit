---
name: monthly-drop-landing-page
description: >
  Generates a fully-branded Monthly Drop landing page (a client content preview) as plain
  static HTML/CSS/JS — no build step — using the template bundled in the skill. ALWAYS
  trigger this skill when the user mentions: generating the landing page, building the
  monthly drop, creating the content preview page, "let's build the preview for [brand]",
  finalizing the monthly deliverables, producing the client preview page, or references the
  Monthly Drop Landing Page together with a content plan. This is the terminal skill in the
  content-production pipeline — it runs after all images have been generated and all blog
  posts have been written. Takes a Content Plan + brand hub URL + blog post outputs + all
  named image files, and produces a static `index.html`/`styles.css`/`app.js`/`content.js`
  committed straight into `coordenadas-content-system`, served by Coolify at
  `docs.916.coordenadas.co` — no Vite, no React, no npm install, nothing to build.
compatibility: >
  Brand-agnostic. Requires a complete set of images (carousels, blog banners, newsletter banners,
  Instagram stories, infographics) named using the conventions documented in the SOP reference
  files, and already uploaded to `docs.coordenadas.co/pix/{marca}/{ciclo}/` (this skill references
  them by remote URL — it never receives or bundles local image files). Requires a Content Plan
  (ideally from content-plan-generator) and blog posts (ideally from blog-post-generator). Requires
  write access to `coordenadas-content-system` and (to trigger the redeploy) a Coolify API token —
  see Step 10. The static template is bundled inside the skill at `template-html/` — plain
  HTML/CSS/JS, no framework, no bundler. No external path needed.
---

# Monthly Drop Landing Page Generator

Generates a fully-branded Monthly Drop landing page — a static HTML/CSS/JS page (no build
step) that shows every content deliverable for the month in one place: carousels with
slide-by-slide browsing, blog posts with banner + story pairs, newsletters with full email
copy and CTAs, and an Instagram grid preview.

This is the **final step** of the content-production pipeline. It runs after:

1. `content-plan-generator` → produced the Content Plan (newsletters + their banner prompts)
2. In parallel: `carousel-prompt-generator` (slide prompts), `blog-post-generator` (full posts +
   banner prompts), `infographic-brief-generator` (design briefs + generation prompts)
3. **Automated step** → all four prompt sources (carousel/blog/newsletter/infographic) generated
   via ComfyUI Cloud and uploaded by FTP (see `coordenadas-hermes-fleet` Fase 5 — engine switched
   2026-08-25, was GPT-5.4 Image-2/OpenRouter) — no manual ChatGPT step for any of the four
4. **This skill** → generates the static landing page and commits it for Coolify to redeploy

The template is bundled inside this skill at `template-html/` — plain `index.html` +
`styles.css` + `app.js`, no framework, no bundler, no `npm install`. The three files are
identical for every brand and cycle; only the data file (`content.js`, written per cycle in
Step 6) changes.

---

## What you need before starting

Five inputs. Check what's already available before asking the user for anything:

1. **The Content Plan** for the relevant month(s) — the full plan with all deliverable
   titles, carousel slide copy, newsletter bodies, CTAs, etc. Already exists as a static
   `.html` file at `01_content_plan/output/{Brand}_Content_Plan_{Month}_{Year}.html`
   (produced by `content-plan-generator`) — this skill only **links** to it (Step 5b), it
   is never copied or regenerated here.

2. **The brand's hub URL** — a public link to the brand's marketing hub, brand guide,
   or Marketing Brain (e.g. a Vercel-hosted Marketing Brain HTML, a Notion page, or
   a Google Doc). This is used as the "Marketing Hub" link on the landing page.

3. **The blog post outputs** — the static `.html` file at
   `02_prompts_and_copy/output/{Brand}_Blog_Posts_{Month}_{Year}.html`, each post with a
   unique anchor ID (`id="post-1"`, `id="post-2"`, etc.). This skill only **links** to it
   (Step 5b) — it's never copied.

4. **The list of uploaded image filenames** — this skill does **not** receive local image
   files. Images are generated and FTP-uploaded to `docs.coordenadas.co/pix/{marca}/{ciclo}/`
   by the image-generation workflow (a separate step, upstream of this skill) before this skill
   ever runs. What you need here is the filenames that were uploaded, following the SOP naming
   conventions:

   | Content Type | Naming Convention | SOP Reference |
   |---|---|---|
   | Carousel slides | `carousel.N.N.png` (carousel number, slide number) | `references/SOP_Carousel_Slide_Generation.md` |
   | Blog banners | `blog.N.png` (blog number) | `references/SOP_Blog_Banner_Image_Generation.md` |
   | Blog stories | `blog.N-story.png` | `references/SOP_Instagram_Story_Banner_Generation.md` |
   | Newsletter banners | `newsletter.N.png` | `references/SOP_Newsletter_Banner_Image_Generation.md` |
   | Newsletter stories | `newsletter.N-story.png` | `references/SOP_Instagram_Story_Banner_Generation.md` |


   **Important:** The naming must be exact — the agent relies on file naming conventions
   to map filenames to remote URLs for the correct carousels, slides, blogs, and newsletters.
   If files have non-standard names, ask the user to confirm the actual uploaded names before
   proceeding — never guess a filename, a wrong guess is a silent 404 `<img>` in the deployed page.

5. **The cycle identifiers for the image URL** — `{marca}` and `{ciclo}`, needed to build
   `https://docs.coordenadas.co/pix/{marca}/{ciclo}/{filename}`. Read them from the cycle's
   `CYCLE_CONTEXT.md` if available, or ask the user. `{marca}` must match the brand's folder
   name under `Brands/` in `coordenadas-content-system` exactly (case-sensitive); `{ciclo}`
   must match the cycle folder under `Brands/{marca}/03_monthly_cycles/{ciclo}/`
   (format `YYYY-NN_LABEL`, e.g. `2026-08_AUG`).

---

## Hard rules

- **Never commit image binaries (PNG/JPG) to `coordenadas-content-system`.** Images live only
  on the FTP host, referenced by URL at `docs.coordenadas.co/pix/{marca}/{ciclo}/{filename}`.
  This skill never downloads, copies, or bundles those files — it only writes URL strings into
  `content.js`. If a step ever has you `cp` a `.png` anywhere, stop.
- **No Vite, no React, no `npm install`, no build step at all.** The old `template/`
  (TanStack Start + Vite + React) is retired for every new brand/cycle — see Step 1. The
  output is `index.html` + `styles.css` + `app.js` (identical every time, copied verbatim
  from `template-html/`) + `content.js` (the only brand/cycle-specific file). If a step ever
  has you run `npm`/`npx`/`vite`, stop — that's the old pattern.
- The old template's `src/assets/paywise/...` images are a fixture belonging **only** to the
  already-published PayWise Vercel drop (see Step 10) — never touched
  by new work.

---

## Step 1 — No Vite, no React, no build step — plain static HTML/CSS/JS

**Decisión definitiva del usuario, 2026-08-21: el template de Vite/React/TanStack Start
se retira del todo.** `docs.916.coordenadas.co` (el deploy target real, ver Step 10) sirve
`coordenadas-content-system` como árbol crudo — `build_pack: static`, nginx sin build step
(confirmado leyendo la config real de Coolify). Un proyecto Vite/React no sirve ahí sin
compilarlo aparte y commitear el `dist/`, que es exactamente lo que se quiere evitar. La
skill genera HTML+CSS+JS planos, listos para servirse tal cual.

The template lives inside this skill at:
```
@skill_root/template-html/
```
- `index.html` — the page shell (structure only, no data).
- `styles.css` — plain CSS, light/dark aware via `prefers-color-scheme`, no Tailwind.
- `app.js` — vanilla JS render functions (`imageOrPlaceholder`, `carouselScroller`,
  `renderCarousels`, `renderBlogs`, `renderNewsletters`, a native `<dialog>`-based
  lightbox) that read a global `CONTENT` object and build the DOM. No React, no JSX, no
  bundler — these are the "componentes y funciones" the page is built from.
- `content.example.js` — the data shape reference (`CONTENT.meta`, `CONTENT.carousels`,
  `CONTENT.blogs`, `CONTENT.newsletters`) — copy this pattern into `content.js`, never
  edit `index.html`/`app.js`/`styles.css` to hardcode brand data into them.

The old `template/` (TanStack Start + Vite + React + shadcn/ui, 46+ generic components)
stays in the repo **only** as the historical reference for the PayWise July–August drop
already live on Vercel (see Step 10) — never copy it for a new
brand/cycle.

---

## Step 2 — Locate the cycle folder

The output goes directly into the real cycle folder in `coordenadas-content-system` — not
a separate `Monthly_Drops` folder, and not a new git repo per brand (that was the old,
now-retired Vercel-per-brand pattern):

```
coordenadas-content-system/Brands/{marca}/03_monthly_cycles/{ciclo}/05_landing_page/output/
```

- `{marca}` — the brand's folder name under `Brands/`, exact spelling/casing (confirm,
  don't guess from the display name — see `docs/sheet-brand-rename.md` in
  `coordenadas-hermes-fleet` for known drift).
- `{ciclo}` — the cycle folder name (`YYYY-NN_LABEL`, e.g. `2026-09_SEP`), must already
  exist (created earlier in the pipeline by the intake stage).

Create `05_landing_page/output/` if it doesn't exist yet.

---

## Step 3 — Copy the static template

Copy the three template files as-is, unmodified, into the output directory:
```
@skill_root/template-html/index.html   -> .../05_landing_page/output/index.html
@skill_root/template-html/styles.css   -> .../05_landing_page/output/styles.css
@skill_root/template-html/app.js       -> .../05_landing_page/output/app.js
```
Nothing in these three files is brand-specific — never hand-edit them per cycle. All
brand/cycle data goes into `content.js` (Step 6). If a real design difference is needed
for a specific brand, see Step 8 first.

Also set the `<title>` and `<meta name="description">` in the copied `index.html` head —
these are the only two lines in `index.html` itself that are brand-specific static text
(everything else renders dynamically from `content.js`).

---

## Step 4 — Determine the remote image base URL for this cycle

Build the base URL from the cycle identifiers:
```
https://docs.coordenadas.co/pix/{marca}/{ciclo}/
```
Same `{marca}`/`{ciclo}` as Step 2. **Confirmed live and case-sensitive** (verified with a
real file, `coordenadas-hermes-fleet` docs/tasks.md T29): the FTP folder casing may not
match `Brands/`'s canonical casing exactly for older/test uploads — use the canonical
`Brands/` casing for all new uploads and verify with a real `curl` before publishing, don't
assume.

Never create a local image file or directory for this step — every image reference is a
remote URL string in `content.js`, nothing is copied or bundled.

---

## Step 5 — Map image filenames to remote URL strings

Same naming convention as before, now as plain string literals in `content.js` (Step 6),
built from the Step 4 base URL + exact filename:

**Carousel slides:** `carousel.N.M.png` → `{base}carousel.N.M.png` (M = slide order, first
slide = grid cover)
**Blog banners and stories:** `blog.N.png`, `blog.N-story.png`
**Newsletter banners and stories:** `newsletter.N.png`, `newsletter.N-story.png`

If any images are missing from the upload, flag the gap to the user and ask them to
confirm the upload before proceeding. Do not generate placeholder content for missing
images, and do not guess a URL for a file you haven't confirmed exists — an empty
`slides: []` / missing `banner`/`story` renders a real "Upload pending" placeholder in the
page (see `app.js` `imageOrPlaceholder`), that's the correct honest state, not a bug to
paper over.

---

## Step 5b — Content Plan & Blog HTML files

These are already static HTML produced by other skills in the pipeline
(`content-plan-generator`, `blog-post-generator`) — this skill only links to them, it does
not regenerate them:

- Content Plan: link to `../../../01_content_plan/output/{Brand}_Content_Plan_{Month}_{Year}.html`
  (relative path from `05_landing_page/output/`) in `content.js`'s `meta.links`.
- Blog posts: link each blog's `docUrl` to
  `../../../02_prompts_and_copy/output/{Brand}_Blog_Posts_{Month}_{Year}.html#post-{id}` —
  confirm the anchor scheme is the current one (`post-N`, not the retired `b1`/`c1` scheme,
  see `coordenadas-hermes-fleet` Hallazgo #12) before wiring the link.

---

## Step 6 — Write `content.js`

Copy `template-html/content.example.js`'s shape into a new `content.js` in the same
output directory, populated with the brand's real data — `meta`, `carousels`, `blogs`,
`newsletters`, using the URL strings from Step 5 and the links from Step 5b. This is the
**only** file that's actually brand/cycle-specific; `index.html`/`styles.css`/`app.js` are
identical across every drop.

```js
const CONTENT = {
  meta: { client: "...", period: "...", lede: "...", links: [...] },
  carousels: [{ id, title, caption, slides: [...] }],
  blogs: [{ id, title, preview, banner, story, docUrl }],
  newsletters: [{ id, title, banner, story, body, ctaUrl, ctaText }],
};
```

---

## Step 7 — Verify in a real browser before delivering

Since there's no build step, "does it compile" isn't a meaningful check — verify the
actual rendered page:

```bash
cd .../05_landing_page/output/
python3 -m http.server 8933
```
Then load `http://localhost:8933/index.html` in a real browser (or via `agent-browser`
if available) and confirm:
- No console errors.
- Each section renders (grid, carousels with working prev/next scroll, blogs, newsletters).
- Clicking an image opens the lightbox with download button; clicking a placeholder (no
  `src`) does nothing (`openLightbox` guards on missing `src` — this is correct, not a bug).
- Copy-to-clipboard works on a newsletter body.

Do not skip this — a real bug was found exactly this way during this skill's own rewrite
(nested `<button>` inside `<button>` silently breaks the click handler; browsers auto-fix
invalid nesting instead of erroring, so it fails silently without a console error).

---

## Step 8 — Brand-specific design customization (optional)

If the brand has documented color specifications and the user requests brand theming,
override the CSS custom properties (`--bg`, `--fg`, `--accent`, etc.) at the top of the
copied `styles.css` for that cycle's output only — never edit the template's own
`styles.css` with brand colors baked in, that would leak into every future brand's copy.
Otherwise skip — the default neutral theme works for preview.

---

## Step 10 — Commit to `coordenadas-content-system` and redeploy via Coolify

> **Vercel is retired for this step — decisión definitiva del usuario, 2026-08-21.**
> No más `gh repo create`, no más deploys a Vercel para nada nuevo. Única excepción que
> se mantiene: el drop de PayWise julio-agosto ya publicado en
> `paywise-monthly-drops.vercel.app` (ver `NOTES.md`), que no se toca.
>
> **El deploy target `docs.916.coordenadas.co` está verificado, no es una suposición**
> (`coordenadas-hermes-fleet` T38, resuelto 2026-08-21): `docs.916.coordenadas.co` sirve
> el árbol crudo de `coordenadas-content-system` `main` sin build step
> (`build_pack: static`, `nginx:alpine`) — confirmado con `curl` real:
> `docs.916.coordenadas.co/README.md` → 200,
> `docs.916.coordenadas.co/Brands/_template/AGENT.md` → 200. El 403 que aparecía en
> `docs.916.coordenadas.co/Brands/` (sin archivo) es solo directory listing deshabilitado,
> no un problema real. Detalle completo, incluidos los UUIDs de Coolify y el endpoint
> exacto, en `NOTES.md` junto a este archivo.

1. **Generar el output como HTML plano**, no el proyecto TanStack Start del `template/`
   completo — como no hay build step, lo que se commitea es exactamente lo que se sirve.
   Guardarlo en `Brands/{marca}/03_monthly_cycles/{ciclo}/index.html` dentro del repo
   `coordenadas-content-system`, referenciando imágenes por URL remota
   (`docs.coordenadas.co/pix/{marca}/{ciclo}/...`), nunca bundleando binarios.

2. **Commitear y pushear:**
   ```bash
   git add "Brands/{marca}/03_monthly_cycles/{ciclo}/"
   git commit -m "Monthly drop: {marca} {ciclo}"
   git push origin main
   ```

3. **Disparar el redeploy vía API de Coolify** (no confiar solo en el webhook de GitHub
   ya configurado — más confiable, no depende de que GitHub entregue el webhook):
   ```bash
   curl -X POST "https://hermes.916.coordenadas.co:8000/api/v1/deploy?uuid=uw2umtohva1ecieguei55k3r" \
     -H "Authorization: Bearer $COOLIFY_API_TOKEN"
   ```
   Requiere `COOLIFY_API_TOKEN` generado en la UI de Coolify (Keys & Tokens) — no existe
   todavía, hay que pedírselo al usuario o generarlo antes de correr esto en serio.

4. **Confirmar estado terminal del deployment** (poll de
   `GET /api/v1/deployments/{deployment_uuid}`) y verificar
   `docs.916.coordenadas.co/Brands/{marca}/03_monthly_cycles/{ciclo}/` → 200 antes de
   dar el drop por publicado. Un deploy enviado no es un deploy exitoso.

---

## Step 11 — Deliver the URL

Present the deployed URL with a summary:
- **Brand name and month**
- **Landing page URL:** `https://docs.916.coordenadas.co/Brands/{marca}/03_monthly_cycles/{ciclo}/`
- **Content summary:** total carousels/slides, blog posts, newsletters
- **Reminders:** client preview, scheduling team download, any gaps flagged

---

## Edge Cases

- **More/fewer carousels, blogs, or newsletters than PayWise:** The template arrays are
  flexible — just add or remove entries in the content config. The types accept any number.
- **Missing stories:** Set `story` to `""` — the component shows a placeholder.
- **No blog HTML provided:** Set `docUrl` to `"#"` — button renders but links nowhere.
- **Blog HTML missing anchor IDs:** This skill doesn't own that file (`blog-post-generator`
  does) — if `id="post-N"` is missing on a post's container element, flag it back rather
  than silently patching someone else's output; if asked to fix it directly, add the `id`
  to the opening tag of each blog post container (e.g. `<article id="post-1">`).
- **Newsletter banner "Download" button opens the image instead of saving it:**
  `downloadImage()` in `app.js` sets `<a download>` on the banner URL. Browsers only honor
  the `download` attribute for same-origin URLs — since banners live on
  `docs.coordenadas.co` (cross-origin from `docs.916.coordenadas.co`), the button will
  likely just open the image in a new tab. This is an accepted limitation of the URL-based
  approach, not a regression to fix here; it would need CORS/proxy support on the FTP host
  to force a real download.
- **Brand theming requested:** Only customize CSS if explicitly asked (see Step 8).
- **Coolify deploy fails:** Check the deployment status via the Coolify API (Step 10) before
  retrying — don't just re-push blind.
- **Local preview without deploy:** `python3 -m http.server` from the output directory and
  open `index.html` in a browser (see Step 7) — no build tool needed.
- **Existing Monthly_Drops folder has non-standard names:** Sequence by counting all folders
  and picking the next number regardless of naming variations.
- **Brand's folder doesn't exist yet:** Ask the user where they want the brand's project
  created, then create both the brand folder and `Monthly_Drops` inside it.
