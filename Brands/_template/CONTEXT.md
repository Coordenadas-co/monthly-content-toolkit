# CONTEXT.md — [Brand Name] — Task Routing

Layer 1 document. Routes a request to the right place — don't hold the
whole pipeline in memory, just follow this. Read first before any work.

Updated automatically by the pipeline. Hand-edited only when adding a
new stage type.

---

## Routing Table

| If the request is about... | Go to... |
|---|---|
| Brand identity, positioning, strategy | `01_knowledge_base/` + `[BrandName]_marketing_brain.html`, `[BrandName]_MasterStrategyDoc.html` |
| Visual identity, colors, fonts, logos | `02_brand_kit/` |
| Agent-readable brand guide | `brand_guide.md` |
| This month's content plan | `03_monthly_cycles/[current]/01_content_plan/` |
| Carousel / blog / infographic prompts or copy | `03_monthly_cycles/[current]/02_prompts_and_copy/` and `04_infographic_briefs/` |
| Image generation | `03_monthly_cycles/[current]/03_image_generation/` — see `docs/SOP_reference/` for the SOPs |
| The live monthly drop / landing page | `03_monthly_cycles/[current]/05_landing_page/` |
| Scheduling status | `03_monthly_cycles/[current]/06_scheduling/` |
| Performance report | `03_monthly_cycles/[current]/07_report/` |
| An urgent/custom request outside the normal cycle | Create a new `03_monthly_cycles/AH-[YYYYMMDD]-[slug]/` folder — don't reuse the current cycle folder |
| HL subaccount config | `04_hl_subaccount_config/` |

**Current cycle:** *(set this to the actual most recent `03_monthly_cycles/` folder name)*
