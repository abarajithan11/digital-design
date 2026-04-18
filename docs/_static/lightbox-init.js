(function () {
  // Inject lightbox styles
  const style = document.createElement("style");
  style.textContent = `
    #lbx-overlay {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.88);
      z-index: 9999;
      align-items: center;
      justify-content: center;
      cursor: zoom-out;
    }
    #lbx-overlay.active { display: flex; }
    #lbx-img {
      max-width: 92vw;
      max-height: 92vh;
      object-fit: contain;
      border-radius: 4px;
      box-shadow: 0 8px 40px rgba(0, 0, 0, 0.6);
      cursor: default;
    }
    #lbx-close {
      position: fixed;
      top: 1rem;
      right: 1.5rem;
      color: #fff;
      font-size: 2rem;
      line-height: 1;
      cursor: pointer;
      user-select: none;
      opacity: 0.8;
    }
    #lbx-close:hover { opacity: 1; }
    main img, .content img, .article-container img { cursor: zoom-in; }
  `;
  document.head.appendChild(style);

  // Build overlay DOM
  const overlay = document.createElement("div");
  overlay.id = "lbx-overlay";

  const closeBtn = document.createElement("span");
  closeBtn.id = "lbx-close";
  closeBtn.textContent = "\u00d7";

  const img = document.createElement("img");
  img.id = "lbx-img";
  img.alt = "";

  overlay.appendChild(closeBtn);
  overlay.appendChild(img);
  document.body.appendChild(overlay);

  function openLightbox(src, alt) {
    img.src = src;
    img.alt = alt || "";
    overlay.classList.add("active");
    document.body.style.overflow = "hidden";
  }

  function closeLightbox() {
    overlay.classList.remove("active");
    img.src = "";
    document.body.style.overflow = "";
  }

  overlay.addEventListener("click", function (e) {
    if (e.target !== img) closeLightbox();
  });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") closeLightbox();
  });

  document.addEventListener("DOMContentLoaded", function () {
    const skip = ".sidebar-drawer, .toc-drawer, .header, nav";
    document.querySelectorAll(
      "main img, .content img, .article-container img"
    ).forEach(function (el) {
      if (el.closest(skip)) return;

      const anchor = el.closest("a");
      if (anchor) {
        anchor.addEventListener("click", function (e) {
          e.preventDefault();
          openLightbox(el.currentSrc || el.src, el.alt);
        });
      } else {
        el.addEventListener("click", function () {
          openLightbox(el.currentSrc || el.src, el.alt);
        });
      }
    });
  });
})();
