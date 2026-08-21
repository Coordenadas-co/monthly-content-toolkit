// Example CONTENT data — copy to content.js and fill in per brand/cycle.
// Every image src is an absolute URL under docs.coordenadas.co/pix/{brand}/{cycle}/
// (confirmed live path, see coordenadas-hermes-fleet/docs/tasks.md T29) — never a
// local/relative path, never bundled into this repo as a binary file.

const PIX_BASE = "https://docs.coordenadas.co/pix/PayWise/2026-09_SEP";

const CONTENT = {
  meta: {
    client: "PayWise",
    period: "September 2026",
    lede:
      "A quick walk-through of everything going out this month: the Instagram grid as it will " +
      "look at month-end, the carousels, blog posts and newsletters — each with its companion story.",
    links: [
      { label: "Content Plan", url: "https://docs.916.coordenadas.co/Brands/PayWise/03_monthly_cycles/2026-09_SEP/01_content_plan/output/PayWise_Content_Plan_SEPTEMBER_2026.html" },
      { label: "Marketing Hub", url: "https://paywisehub.coordenadas.co/", variant: "outline" },
    ],
  },

  // id, title, caption, slides[] (first slide = grid cover). Empty slides[] renders
  // a placeholder — that's the expected state before images are generated/uploaded.
  carousels: [
    {
      id: 1,
      title: "Island Finance — Now on PayWise",
      caption: "",
      slides: [
        `${PIX_BASE}/carousel.1.1.png`,
        `${PIX_BASE}/carousel.1.2.png`,
      ],
    },
    {
      id: 2,
      title: "Still Standing in Payment Lines in 2026?",
      caption: "",
      slides: [],
    },
  ],

  // id, title, preview, banner, story (9:16), docUrl
  blogs: [
    {
      id: 1,
      title: "You Can Now Pay Your Island Finance Loan on PayWise — Here's How",
      preview: "If you have an Island Finance loan, you know the routine...",
      banner: `${PIX_BASE}/blog.1.png`,
      story: `${PIX_BASE}/blog.1-story.png`,
      docUrl: "https://docs.916.coordenadas.co/Brands/PayWise/03_monthly_cycles/2026-09_SEP/02_prompts_and_copy/output/PayWise_Blog_Posts_SEPTEMBER_2026.html#post-1",
    },
  ],

  // id, title, banner, story (9:16), body, ctaUrl, ctaText
  newsletters: [
    {
      id: 1,
      title: "Two big updates: Island Finance & Cash-Out now live",
      banner: `${PIX_BASE}/newsletter.1.png`,
      story: `${PIX_BASE}/email1-story.png`,
      body: "Hi [First Name],\n\nBig month for PayWise...",
      ctaUrl: "https://paywise.co/personal/",
      ctaText: "Download PayWise",
    },
  ],
};
