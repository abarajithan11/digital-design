document.addEventListener("DOMContentLoaded", function () {
  document.querySelectorAll("model-viewer").forEach(function (viewer) {
    const fallback = viewer.querySelector(".hero-model-fallback");
    if (!fallback) return;
    const isLocalHost = ["localhost", "127.0.0.1"].includes(window.location.hostname);
    const localSrc = viewer.dataset.localSrc;
    const remoteSrc = viewer.dataset.remoteSrc;

    if (isLocalHost && localSrc) {
      viewer.setAttribute("src", localSrc);
    } else if (remoteSrc) {
      viewer.setAttribute("src", remoteSrc);
    }

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
