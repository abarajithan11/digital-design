# Sphinx configuration
project = "Digital Design with SystemVerilog"
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
html_title = "Digital Design"

# Allow SVG and webp in docs
html_static_path = ["_static"]
html_css_files = ["custom.css"]
html_js_files = ["lightbox-init.js", "model-viewer-init.js", "waveform-svg-init.js"]


def setup(app):
    app.add_js_file(
        "https://cdn.jsdelivr.net/npm/@google/model-viewer@4.2.0/dist/model-viewer.min.js",
        type="module",
    )

myst_enable_extensions = [
    "colon_fence",
    "tasklist",
]
