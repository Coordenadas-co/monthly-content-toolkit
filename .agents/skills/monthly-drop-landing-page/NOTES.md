# Notes — deploy target exceptions and pending verification

Context for `coordenadas-hermes-fleet` Fase 8 (T36–T38). This file documents things about
where Monthly Drop landing pages get deployed that don't belong inside `SKILL.md`'s
step-by-step instructions.

## PayWise July–August drop stays on Vercel (T37)

The PayWise Monthly Drop already published for the July–August cycle
(`paywise-monthly-drops.vercel.app`) is in the client's hands and stays exactly where it is.
It is **not** migrated to the remote-image-URL / `docs.916.coordenadas.co` mechanism this
skill now implements, and nobody should touch that deployment as part of adopting the new
mechanism.

Everything else uses the new mechanism described in `SKILL.md`:
- Every cycle for PayWise going forward (starting from whichever cycle comes after
  July–August).
- Every other brand's drop, including the three other July drops that were also deployed to
  standalone Vercel projects (Goozone, Beauty & Beach, Frenzy Salon) — those are a separate,
  smaller migration tracked as `TD3` in `coordenadas-hermes-fleet/docs/tasks.md`, not part of
  this change.

Source: `coordenadas-hermes-fleet/docs/architecture.md` (Hosting del monthly drop row) and the
research backing it — decisión #6 / Hallazgo #14 in
`~/.claude/plans/necesito-que-usemos-coordenadas-hermes-f-optimized-meadow.md`.

## Coolify redeploy from `coordenadas-content-system` — RESUELTO 2026-08-21, Vercel se elimina del todo

**Decisión del usuario, definitiva:** ya no se usa Vercel para nada nuevo (ni siquiera
como respaldo) — todo commitea a `coordenadas-content-system` y Hermes llama a la API de
Coolify para el redeploy. `SKILL.md` Step 10 debe reemplazar `gh repo create` + Vercel
por el flujo de abajo. Única excepción que sigue en pie: el drop de PayWise
julio-agosto ya publicado en Vercel, que se queda donde está (ver sección anterior).

**Los tres puntos que quedaban abiertos, verificados contra la infra real (no supuestos):**

1. **El 403 en `Brands/` era solo directory listing deshabilitado — no un problema real.**
   Probado con `curl`: `docs.916.coordenadas.co/README.md` → 200,
   `docs.916.coordenadas.co/Brands/_template/AGENT.md` → 200,
   `docs.916.coordenadas.co/Brands/` (sin archivo) → 403. `docs.916.coordenadas.co` sirve
   el árbol crudo del repo `coordenadas-content-system` directo — confirmado en la DB de
   Coolify: `build_pack: static`, `static_image: nginx:alpine`, sin build step. Un archivo
   `index.html` commiteado en `Brands/{marca}/03_monthly_cycles/{ciclo}/` queda servible
   tal cual en esa URL.
2. **Shape esperado: HTML plano, no un build de TanStack Start.** Como no hay build step
   (`build_pack: static`), lo que se commitea es exactamente lo que se sirve — nada de
   `dist/`, nada de bundlear. El drop final debe ser HTML+CSS+JS autocontenido (mismo
   patrón que ya usa esta skill para consumir imágenes por URL remota, sin bundlear
   binarios) — no el proyecto TanStack Start completo del `template/`.
3. **Redeploy: Coolify ya tiene un webhook de GitHub configurado** (confirmado en la DB:
   `manual_webhook_secret_github` no es null) — un push a `main` probablemente ya dispara
   redeploy solo. **Aun así, por pedido explícito del usuario, el paso de deploy debe
   llamar a la API de Coolify directo después del push** — no depender solo del webhook
   (más confiable, no depende de que GitHub entregue el webhook correctamente).

**UUIDs reales de la app en Coolify** (leídos de la DB, no son secretos):
```
application_uuid: uw2umtohva1ecieguei55k3r
environment_uuid: z6vuf4tjnf2vlc508lnc86ik
project_uuid:     txnzi6ahctrpgq90uvqd4ffd
server_uuid:      nyqmavrnp51356ubmlyt6upo
fqdn:             docs.916.coordenadas.co
```

**Endpoint de deploy** (API REST de Coolify, patrón estándar):
```
POST https://hermes.916.coordenadas.co:8000/api/v1/deploy?uuid=uw2umtohva1ecieguei55k3r
Authorization: Bearer <COOLIFY_API_TOKEN>
```

**Pendiente real, no resoluble desde esta sesión:** hace falta un API token de Coolify.
Ya existen 2 tokens en la DB (confirmado solo el conteo, nunca se extrajo ni se intentó
extraer el valor — están hasheados de un solo sentido igual, y `coolify-management/SKILL.md`
prohíbe explícitamente extraer tokens de la base de datos). Generar uno nuevo requiere
entrar a la UI de Coolify (`hermes.916.coordenadas.co:8000` → Keys & Tokens) y dárselo a
Hermes como credencial — no algo que se pueda automatizar sin esa acción humana.

Nuevo Step 10 (reemplaza `gh repo create` + Vercel):
1. Generar el HTML plano del drop (no el build de TanStack Start) en
   `Brands/{marca}/03_monthly_cycles/{ciclo}/index.html`, referenciando imágenes por URL
   remota (`docs.coordenadas.co/pix/...`).
2. `git add` + commit + push a `coordenadas-content-system` `main`.
3. `POST /api/v1/deploy?uuid=uw2umtohva1ecieguei55k3r` con el token de Coolify.
4. Poll de `GET /api/v1/deployments/{deployment_uuid}` hasta estado terminal (mismo
   patrón de `coolify-management/SKILL.md`: "un deploy enviado no es un deploy exitoso").
5. Confirmar `docs.916.coordenadas.co/Brands/{marca}/03_monthly_cycles/{ciclo}/` → 200.
