# Sphinx configuration
project = "Intro to Digital Design - An End to End Approach"
author = ""
release = ""

extensions = [
    "myst_parser",
]

source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}

html_theme = "furo"
html_title = "Intro to Digital Design"

# Allow SVG and webp in docs
html_static_path = ["_static"]
html_css_files = [
    "custom.css",
    "https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.11.5/css/lightbox.min.css",
]
html_js_files = [
    "https://cdnjs.cloudflare.com/ajax/libs/lightbox2/2.11.5/js/lightbox.min.js",
    "lightbox-init.js",
]

myst_enable_extensions = [
    "colon_fence",
]
