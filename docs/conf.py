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

myst_enable_extensions = [
    "colon_fence",
]
