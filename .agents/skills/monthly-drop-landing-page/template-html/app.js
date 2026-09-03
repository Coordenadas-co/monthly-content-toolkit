// Monthly Drop — vanilla JS render layer. No build step, no framework.
// Reads the global CONTENT object (see content.js / content.example.js) and
// renders the page. Every image src in CONTENT must already be an absolute
// URL under docs.coordenadas.co/pix/{brand}/{cycle}/{filename} — this file
// never rewrites or resolves image paths, it only renders what it's given.

(function () {
  "use strict";

  // ---- small "component" helpers -----------------------------------------

  function el(tag, attrs, children) {
    const node = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs || {})) {
      if (k === "class") node.className = v;
      else if (k === "html") node.innerHTML = v;
      else if (k.startsWith("on") && typeof v === "function") node.addEventListener(k.slice(2), v);
      else if (v !== undefined && v !== null && v !== false) node.setAttribute(k, v === true ? "" : v);
    }
    for (const child of [].concat(children || [])) {
      if (child === null || child === undefined || child === false) continue;
      node.appendChild(typeof child === "string" ? document.createTextNode(child) : child);
    }
    return node;
  }

  function downloadImage(url, filename) {
    const a = document.createElement("a");
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  // aspect: "square" | "portrait" | "landscape" | "post"
  function imageOrPlaceholder({ src, alt, aspect = "square", label, downloadFilename, onClick }) {
    const box = el("div", { class: `img-box aspect-${aspect}` });
    if (src) {
      box.appendChild(el("img", { src, alt, loading: "lazy" }));
      if (downloadFilename) {
        box.appendChild(
          el("button", {
            type: "button",
            class: "icon-btn top-right",
            "aria-label": `Download ${alt}`,
            onclick: (e) => {
              e.stopPropagation();
              e.preventDefault();
              downloadImage(src, downloadFilename);
            },
          }, "⬇"),
        );
      }
    } else {
      box.appendChild(el("div", { class: "placeholder" }, label || "Upload pending"));
    }
    if (onClick) {
      // A real <button> can't legally contain another <button> (the download
      // icon-btn above), and browsers silently mis-parse that nesting — which
      // breaks the outer click handler. Use a div with button semantics instead.
      const wrap = el("div", {
        class: "img-clickable",
        role: "button",
        tabindex: "0",
        "aria-label": alt,
        onclick: onClick,
        onkeydown: (e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            onClick(e);
          }
        },
      }, box);
      return wrap;
    }
    return box;
  }

  // ---- lightbox ------------------------------------------------------------

  const lightboxEl = document.getElementById("lightbox");
  const lightboxImg = document.getElementById("lightbox-img");
  const lightboxDownload = document.getElementById("lightbox-download");
  const lightboxClose = document.getElementById("lightbox-close");

  function openLightbox({ src, alt, downloadFilename }) {
    if (!src) return;
    lightboxImg.src = src;
    lightboxImg.alt = alt || "";
    if (downloadFilename) {
      lightboxDownload.hidden = false;
      lightboxDownload.onclick = () => downloadImage(src, downloadFilename);
    } else {
      lightboxDownload.hidden = true;
      lightboxDownload.onclick = null;
    }
    lightboxEl.showModal();
  }
  lightboxClose.addEventListener("click", () => lightboxEl.close());
  lightboxEl.addEventListener("click", (e) => {
    if (e.target === lightboxEl) lightboxEl.close();
  });

  // ---- carousel scroller (CSS scroll-snap, no library) --------------------

  function carouselScroller(slides, onSlideClick, filenamePrefix) {
    const scroller = el("div", { class: "carousel-scroller" });
    slides.forEach((src, i) => {
      scroller.appendChild(
        imageOrPlaceholder({
          src,
          alt: `slide ${i + 1}`,
          aspect: "post",
          downloadFilename: `${filenamePrefix}-slide-${i + 1}.png`,
          onClick: () => onSlideClick(src, i),
        }),
      );
    });
    const prev = el("button", { type: "button", "aria-label": "Previous slide", onclick: () => scroller.scrollBy({ left: -240, behavior: "smooth" }) }, "‹");
    const next = el("button", { type: "button", "aria-label": "Next slide", onclick: () => scroller.scrollBy({ left: 240, behavior: "smooth" }) }, "›");
    const wrap = el("div", {}, [scroller, el("div", { class: "carousel-nav" }, [prev, next])]);
    return wrap;
  }

  // ---- sections --------------------------------------------------------------

  function renderHero(meta) {
    document.title = `${meta.client} — Monthly Drop`;
    document.getElementById("meta-client").textContent = meta.client;
    document.getElementById("meta-period").textContent = `/ ${meta.period}`;
    document.getElementById("hero-title").textContent = `${meta.client} — Monthly Drop`;
    document.getElementById("hero-lede").textContent =
      meta.lede || "A quick walk-through of everything going out this month.";
    document.getElementById("footer-client").textContent = meta.client;

    const linksHost = document.getElementById("hero-links");
    (meta.links || []).forEach((link) => {
      linksHost.appendChild(
        el("a", {
          href: link.url,
          target: "_blank",
          rel: "noopener noreferrer",
          class: `btn ${link.variant === "outline" ? "btn-outline" : ""}`,
        }, `${link.label} ↗`),
      );
    });
  }

  function renderGrid(carousels) {
    const host = document.getElementById("grid-preview");
    carousels.forEach((c) => {
      const cover = c.slides[0];
      host.appendChild(
        imageOrPlaceholder({
          src: cover,
          alt: c.title,
          aspect: "post",
          label: `C${c.id}`,
          downloadFilename: `carousel-${c.id}-slide-1.png`,
          onClick: () => openLightbox({ src: cover, alt: c.title, downloadFilename: `carousel-${c.id}-slide-1.png` }),
        }),
      );
    });
  }

  function renderCarousels(carousels) {
    document.getElementById("carousels-subtitle").textContent =
      `${carousels.length} carousel${carousels.length === 1 ? "" : "s"} for Instagram, Facebook and LinkedIn.`;
    const host = document.getElementById("carousels-list");
    carousels.forEach((c) => {
      const head = el("div", { class: "carousel-block-head" }, [
        el("div", {}, [
          el("p", { class: "eyebrow" }, `Carousel ${c.id}`),
          el("h3", {}, c.title),
        ]),
        el("span", { class: "count" }, `${c.slides.length} ${c.slides.length === 1 ? "slide" : "slides"}`),
      ]);
      const body =
        c.slides.length > 0
          ? carouselScroller(
              c.slides,
              (src, i) => openLightbox({ src, alt: `${c.title} slide ${i + 1}`, downloadFilename: `carousel-${c.id}-slide-${i + 1}.png` }),
              `carousel-${c.id}`,
            )
          : el("div", { class: "grid-2" }, [imageOrPlaceholder({ alt: "slide placeholder", aspect: "post", label: "Upload pending" })]);
      const article = el("article", { class: "carousel-block" }, [head, body]);
      if (c.caption) article.appendChild(el("p", { class: "caption" }, c.caption));
      host.appendChild(article);
    });
  }

  function renderBlogs(blogs) {
    const host = document.getElementById("blogs-list");
    blogs.forEach((b) => {
      const row = el("div", { class: "row" }, [
        el("div", { class: "banner-col" }, imageOrPlaceholder({
          src: b.banner, alt: b.title, aspect: "landscape", downloadFilename: `blog-${b.id}-banner.png`,
        })),
        el("button", {
          type: "button", class: "story-col", "aria-label": `Open ${b.title} story`,
          onclick: () => b.story && openLightbox({ src: b.story, alt: `${b.title} story`, downloadFilename: `blog-${b.id}-story.png` }),
        }, imageOrPlaceholder({ src: b.story, alt: `${b.title} story`, aspect: "portrait", label: "Story" })),
      ]);
      const body = el("div", { class: "body" }, [
        el("p", { class: "eyebrow" }, `Blog ${b.id}`),
        el("h3", {}, b.title),
        b.preview ? el("p", { class: "preview" }, b.preview) : null,
        b.docUrl ? el("a", { href: b.docUrl, target: "_blank", rel: "noreferrer", class: "btn btn-outline" }, "Read full post ↗") : null,
      ]);
      host.appendChild(el("article", { class: "blog-card" }, [row, body]));
    });
  }

  function renderNewsletters(newsletters) {
    const host = document.getElementById("newsletters-list");
    newsletters.forEach((n) => {
      const parts = [
        el("p", { class: "eyebrow" }, `Email ${n.id}`),
        el("h3", {}, n.title),
      ];

      // div, not <button> — it contains a real download <button> below, and a
      // <button> can't legally nest another <button> (see imageOrPlaceholder).
      const bannerBtn = el("div", {
        class: "banner-btn", role: "button", tabindex: "0", "aria-label": `Open ${n.title} preview`,
        onclick: () => n.banner && openLightbox({ src: n.banner, alt: n.title, downloadFilename: `newsletter-${n.id}-banner.png` }),
        onkeydown: (e) => {
          if ((e.key === "Enter" || e.key === " ") && n.banner) {
            e.preventDefault();
            openLightbox({ src: n.banner, alt: n.title, downloadFilename: `newsletter-${n.id}-banner.png` });
          }
        },
      });
      if (n.banner) {
        bannerBtn.appendChild(el("img", { src: n.banner, alt: n.title, loading: "lazy" }));
        bannerBtn.appendChild(
          el("button", {
            type: "button", class: "icon-btn top-right", "aria-label": `Download ${n.title}`,
            onclick: (e) => { e.stopPropagation(); e.preventDefault(); downloadImage(n.banner, `newsletter-${n.id}-banner.png`); },
          }, "⬇"),
        );
      } else {
        bannerBtn.appendChild(imageOrPlaceholder({ alt: n.title, aspect: "landscape" }));
      }
      parts.push(bannerBtn);

      if (n.body) {
        const copyBtn = el("button", { type: "button", onclick: (e) => {
          navigator.clipboard.writeText(n.body);
          const btn = e.currentTarget;
          const original = btn.textContent;
          btn.textContent = "Copied!";
          setTimeout(() => { btn.textContent = original; }, 2000);
        } }, "Copy to clipboard");
        parts.push(
          el("div", { class: "email-preview" }, [
            el("div", { class: "email-head" }, [el("span", {}, "Email preview"), copyBtn]),
            el("div", { class: "email-body" }, n.body),
          ]),
        );
      }

      if (n.ctaUrl) {
        parts.push(el("a", { href: n.ctaUrl, target: "_blank", rel: "noopener noreferrer", class: "btn" }, `${n.ctaText || "Learn more"} ↗`));
      }

      if (n.story) {
        parts.push(
          el("div", { class: "story-row" }, [
            el("p", {}, "Instagram Story"),
            el("button", {
              type: "button", "aria-label": `Open ${n.title} story`,
              onclick: () => openLightbox({ src: n.story, alt: `${n.title} story`, downloadFilename: `newsletter-${n.id}-story.png` }),
            }, imageOrPlaceholder({ src: n.story, alt: `${n.title} story`, aspect: "portrait", label: "Story" })),
          ]),
        );
      }

      host.appendChild(el("article", { class: "newsletter-card" }, parts));
    });
  }


  function renderInfographics(items) {
    const host = document.getElementById("infographics-list");
    if (!host) return;
    (items || []).forEach((g) => {
      const card = el("article", { class: "info-card" }, [
        el("button", {
          type: "button", class: "banner-col", "aria-label": "Open " + g.title,
          onclick: () => g.image && openLightbox({ src: g.image, alt: g.title, downloadFilename: "infographic-" + g.id + ".png" }),
        }, imageOrPlaceholder({ src: g.image, alt: g.title, aspect: "portrait", downloadFilename: "infographic-" + g.id + ".png" })),
        el("div", { class: "body" }, [
          el("p", { class: "eyebrow" }, "Infografia " + g.id),
          el("h3", {}, g.title),
          g.detail ? el("p", { class: "preview" }, g.detail) : null,
        ]),
      ]);
      host.appendChild(card);
    });
  }

  // ---- boot ------------------------------------------------------------------

  function init() {
    if (typeof CONTENT === "undefined") {
      console.error("content.js did not define a global CONTENT object — nothing to render.");
      return;
    }
    renderHero(CONTENT.meta || {});
    renderGrid(CONTENT.carousels || []);
    renderCarousels(CONTENT.carousels || []);
    renderBlogs(CONTENT.blogs || []);
    renderNewsletters(CONTENT.newsletters || []);
    renderInfographics(CONTENT.infographics || []);
  }

  document.addEventListener("DOMContentLoaded", init);
})();
