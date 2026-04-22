document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("model-viewer").forEach(function (viewer) {
    const fallback = viewer.querySelector(".hero-model-fallback");
    if (!fallback) return;

    viewer.addEventListener("error", function () {
      viewer.classList.add("is-error");
      fallback.hidden = false;
    });

    viewer.addEventListener("load", function () {
      viewer.classList.remove("is-error");
      fallback.hidden = true;
    });
  });
});
