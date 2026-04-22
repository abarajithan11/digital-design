document.addEventListener("DOMContentLoaded", function () {
  const upgradeTimeoutMs = 2500;

  document.querySelectorAll("model-viewer").forEach(function (viewer) {
    const fallback = viewer.querySelector(".hero-model-fallback");
    if (!fallback) return;

    const showFallback = function () {
      viewer.classList.add("is-error");
      fallback.hidden = false;
    };

    const hideFallback = function () {
      viewer.classList.remove("is-error");
      fallback.hidden = true;
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
  });
});
