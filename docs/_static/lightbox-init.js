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

  let scale = 1;
  let offsetX = 0;
  let offsetY = 0;
  let dragging = false;
  let startX = 0;
  let startY = 0;
  let savedScrollY = 0;
  let savedBodyPosition = "";
  let savedBodyTop = "";
  let savedBodyWidth = "";
  let savedBodyOverflow = "";

  function applyTransform() {
    img.style.transform = `translate(${offsetX}px, ${offsetY}px) scale(${scale})`;
  }

  function resetTransform() {
    scale = 1;
    offsetX = 0;
    offsetY = 0;
    applyTransform();
  }

  function openLightbox(src, alt) {
    img.src = src;
    img.alt = alt || "";
    resetTransform();
    overlay.classList.add("active");

    savedScrollY = window.scrollY || window.pageYOffset || 0;
    savedBodyPosition = document.body.style.position;
    savedBodyTop = document.body.style.top;
    savedBodyWidth = document.body.style.width;
    savedBodyOverflow = document.body.style.overflow;

    document.body.style.overflow = "hidden";
    document.body.style.position = "fixed";
    document.body.style.top = `-${savedScrollY}px`;
    document.body.style.width = "100%";
  }

  function closeLightbox() {
    overlay.classList.remove("active");
    img.src = "";
    resetTransform();

    document.body.style.overflow = savedBodyOverflow;
    document.body.style.position = savedBodyPosition;
    document.body.style.top = savedBodyTop;
    document.body.style.width = savedBodyWidth;

    window.scrollTo(0, savedScrollY);
  }

  overlay.addEventListener("click", function (e) {
    if (e.target !== img) closeLightbox();
  });

  img.addEventListener("wheel", function (e) {
    if (!overlay.classList.contains("active")) return;
    e.preventDefault();
    const factor = e.deltaY < 0 ? 1.1 : 0.9;
    scale = Math.max(1, Math.min(8, scale * factor));
    applyTransform();
  });

  img.addEventListener("dblclick", function (e) {
    e.preventDefault();
    if (scale > 1.01) {
      resetTransform();
    } else {
      scale = 2.5;
      applyTransform();
    }
  });

  img.addEventListener("mousedown", function (e) {
    if (scale <= 1) return;
    dragging = true;
    startX = e.clientX - offsetX;
    startY = e.clientY - offsetY;
  });

  document.addEventListener("mousemove", function (e) {
    if (!dragging) return;
    offsetX = e.clientX - startX;
    offsetY = e.clientY - startY;
    applyTransform();
  });

  document.addEventListener("mouseup", function () {
    dragging = false;
  });

  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") {
      closeLightbox();
      return;
    }
    if (!overlay.classList.contains("active")) return;

    if (e.key === "+" || e.key === "=") {
      scale = Math.min(8, scale * 1.15);
      applyTransform();
    }
    if (e.key === "-") {
      scale = Math.max(1, scale / 1.15);
      if (scale === 1) {
        offsetX = 0;
        offsetY = 0;
      }
      applyTransform();
    }
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
