document.addEventListener("DOMContentLoaded", function () {
  const upgradeTimeoutMs = 2500;
  const modelViewerTag = "model-viewer";

  document.querySelectorAll("model-viewer").forEach(function (viewer) {
    const fallback = viewer.querySelector(".hero-model-fallback");
    if (!fallback) return;

    const fallbackHost = document.createElement("div");
    fallbackHost.className = viewer.className + " model-viewer-fallback-host";
    fallbackHost.hidden = true;

    const fallbackClone = fallback.cloneNode(true);
    fallbackClone.hidden = false;
    const fallbackText = fallbackClone.querySelector("p");
    if (fallbackText) {
      fallbackText.remove();
    }
    fallbackHost.appendChild(fallbackClone);
    viewer.insertAdjacentElement("afterend", fallbackHost);

    const showFallback = function () {
      viewer.hidden = true;
      fallback.hidden = true;
      fallbackHost.hidden = false;
    };

    const hideFallback = function () {
      viewer.hidden = false;
      fallback.hidden = true;
      fallbackHost.hidden = true;
    };

    viewer.addEventListener("error", function () {
      showFallback();
    });

    viewer.addEventListener("load", function () {
      hideFallback();
    });

    window.setTimeout(function () {
      if (!viewer.matches(":defined")) {
        showFallback();
      }
    }, upgradeTimeoutMs);

    if (window.customElements && typeof window.customElements.whenDefined === "function") {
      window.customElements.whenDefined(modelViewerTag).then(function () {
        hideFallback();
      });
    }
  });
});
