# Video Script Guide

Guía para escribir el guion de un deliverable `video.N` dentro de `content-plan.md`/`content-plan.html`. Esto NO cubre producción real (no hay pipeline de generación de video en Half-Click hoy) — el único entregable es el texto del guion. Por eso queda afuera todo lo de herramientas/APIs (AI avatars, modelos de generación, frameworks programáticos): si en algún momento se agrega una etapa downstream real, ese conocimiento vive en la skill `video` del catálogo de marketing-skills, no acá.

## Tipo, aspecto y presentador ya vienen decididos

El ciclo trae, para cada `video.N`, su `type` / `aspect` / `presenter` ya elegidos en Half-Click (LAYER 4 del prompt) — nunca se preguntan en vivo. Si el tipo llega como "Mixto", elegí vos el tipo real de la lista de abajo según la dirección estratégica del ciclo, sin repetir el mismo tipo en dos videos de la misma mezcla.

| Type | Qué es | Duración típica |
|---|---|---|
| Demo | Muestra el producto/feature funcionando | 30–60s |
| Explainer | Problema → solución → CTA | 45–90s |
| Testimonial | Caso de uso o cita de cliente | 30–60s |
| Social clip | Gancho corto, un solo mensaje | 15–30s |
| Ad | Variante orientada a conversión, headline fuerte al frente | 15–30s |
| Tutorial | Paso a paso de una tarea concreta | 45–90s |

| Aspect | Uso |
|---|---|
| 9:16 vertical | TikTok / Reels / Shorts |
| 16:9 horizontal | YouTube / web |
| 1:1 cuadrado | Feed |

| Presenter | Qué implica en el guion |
|---|---|
| Sin presentador | El guion describe screen recording + voiceover — nunca "a cámara" |
| AI avatar | El guion queda listo para lip-sync — frases cortas, sin overlaps de audio/visual complejos |
| Sólo voz en off | Sin presentador en pantalla, visual 100% B-roll/UI/gráficos |

## Formato de salida

Cada guion arranca con la etiqueta literal `video.N —` (N = su posición, 1-based) — es el identificador que valida el pipeline, no cambiarle la forma. En `content-plan.html`, la card correspondiente lleva `id="video-N"` con el mismo N.

```
video.N — [Week N] — Video Script
👤 Persona: [Exact cluster name]
🎬 Type: [Demo / Explainer / Testimonial / Social clip / Ad / Tutorial]
📐 Aspect: [9:16 vertical / 16:9 horizontal / 1:1 feed]
🛠 Presenter: [Sin presentador (screen recording + voiceover) / AI avatar / Sólo voz en off]

SCRIPT (beat sheet)
[0–Ns] Visual: [qué se ve en este beat]
Audio: [qué se dice o suena]
[repetir por beat hasta cerrar el CTA — 4 a 6 beats típico para 30-60s]

VISUAL NOTES
[Escenas concretas, texto en pantalla, elementos de marca a incluir]
```

El beat sheet reemplaza al genérico "Opening hook / Body / CTA": da timestamps reales y separa Visual de Audio en cada línea, así quien edite sabe exactamente qué cortar dónde.

## Errores comunes (aplican igual sin pipeline de producción real)

1. **Texto en pantalla como si lo renderizara un modelo de imagen/video** — nunca pedir texto exacto superpuesto vía IA generativa; si hace falta texto en pantalla, anotarlo en VISUAL NOTES como overlay programático (se agrega en edición, no en generación).
2. **Sin mención de captions** — la mayoría del video social se ve sin sonido; VISUAL NOTES siempre aclara que lleva captions.
3. **Aspect ratio que no matchea la plataforma** — 9:16 para social, 16:9 para YouTube/web, 1:1 para feed. Nunca asumas 16:9 por default si el `aspect` que vino del ciclo dice otra cosa.
4. **Presentador "AI avatar" con guion largo y denso** — frases cortas, una idea por beat; un guion pensado para avatar que lee un párrafo entero suena artificial.
5. **Sobre-producir el guion** — auténtico rinde mejor que sobre-pulido, sobre todo en clips cortos; no inflar el guion con más beats de los que el tiempo total permite.
