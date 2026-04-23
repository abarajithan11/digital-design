(function () {
  function inlineWaveform(container) {
    const src = container.dataset.svgSrc;
    if (!src || container.dataset.waveformLoaded === "true") {
      return;
    }

    fetch(src)
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Failed to load waveform SVG");
        }
        return response.text();
      })
      .then(function (svgText) {
        const parser = new DOMParser();
        const doc = parser.parseFromString(svgText, "image/svg+xml");
        const svg = doc.documentElement;
        if (!svg || svg.nodeName.toLowerCase() !== "svg") {
          throw new Error("Invalid waveform SVG");
        }

        svg.removeAttribute("width");
        svg.style.width = "100%";
        svg.style.height = "auto";
        svg.style.display = "block";
        svg.setAttribute("preserveAspectRatio", "xMinYMin meet");

        container.replaceChildren(svg);
        container.dataset.waveformLoaded = "true";
      })
      .catch(function () {
        container.dataset.waveformLoaded = "error";
      });
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".waveform-svg[data-svg-src]").forEach(inlineWaveform);
  });
})();
