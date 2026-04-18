document.addEventListener("DOMContentLoaded", () => {
  const contentImages = document.querySelectorAll(
    "main img, .content img, .article-container img"
  );

  contentImages.forEach((img, index) => {
    if (img.closest(".sidebar-drawer, .toc-drawer")) return;

    const enclosingAnchor = img.closest("a");
    if (enclosingAnchor) {
      enclosingAnchor.setAttribute("data-lightbox", "doc-images");
      enclosingAnchor.setAttribute("data-title", img.alt || `Image ${index + 1}`);
      if (!enclosingAnchor.getAttribute("href")) {
        enclosingAnchor.setAttribute("href", img.currentSrc || img.src);
      }
      return;
    }

    const link = document.createElement("a");
    link.href = img.currentSrc || img.src;
    link.setAttribute("data-lightbox", "doc-images");
    link.setAttribute("data-title", img.alt || `Image ${index + 1}`);

    img.parentNode.insertBefore(link, img);
    link.appendChild(img);
  });

  if (window.lightbox) {
    window.lightbox.option({
      resizeDuration: 150,
      imageFadeDuration: 150,
      wrapAround: true,
      disableScrolling: true,
      fitImagesInViewport: true,
      showImageNumberLabel: false,
    });
  }
});
