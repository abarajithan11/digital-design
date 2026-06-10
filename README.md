# Course Website and Material (SystemVerilog) for CSE 140

Visit the site: [abapages.com/digital-design](https://abapages.com/digital-design/)

### Set up, start, and enter the Docker container from Ubuntu or WSL2

```bash
make fresh
make enter
```

`make fresh` pulls the latest course image from GHCR and starts the container. To build that same image tag locally from the Dockerfile and start it instead, use:

```bash
make scratch
make enter
```

These default to `ARCH=amd64`, using `ghcr.io/ucsd-cse140-s126/digital-design-amd64:latest`.

### Set up, start, and enter the Docker container on ARM-based PCs (Mac/Windows)

Apple Silicon Macs and ARM-based Windows/WSL2 PCs should use the arm64 image, built natively from source so it runs without emulation:

```bash
make fresh ARCH=arm64
make enter
```

or build it locally from the Dockerfile:

```bash
make scratch ARCH=arm64
make enter
```

This pulls/builds `ghcr.io/ucsd-cse140-s126/digital-design-arm64:latest`.

### Run simulation and the RTL-to-GDS2 flow with ASAP7

From inside the Docker container:

```bash
make sim                DESIGN=alu
make gds                DESIGN=alu
make sim_all
make gds_all
make show_layout        DESIGN=alu
make show_3d            DESIGN=alu
make show_3d_cell       CELL=NAND2x1 
make show_3d_cell       # show all available cells
make show_layout_cells
# exit - to leave the container
```

* The root `Makefile` handles Docker, artifact collection, and site generation. The `material/Makefile` handles the in-container design flows.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/alu/base`

## To locally serve the site

```bash
pip install sphinx furo myst-parser
make 3d_assets
make site
make serve
```

Then open `http://localhost:8000` in your browser.


## To publish the docker container

Publishing is manual. `make publish` builds the image locally as `ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest` (default `ARCH=amd64`) and pushes it. CI and `make fresh` only pull this image.

For arm64, push with `ARCH=arm64`, or trigger the `build-docker-arm` workflow from the GitHub Actions tab, which builds and publishes `digital-design-arm64:latest` automatically.

Get your GHCR token as:

* Log into GitHub, click your profile picture in the top right corner, and select Settings.
* Scroll all the way down the left sidebar and click on Developer settings.  
* In the left menu, expand Personal access tokens, then select Tokens (classic).  
* Click the Generate new token button, and choose Generate new token (classic).  
* Give your token a descriptive name in the "Note" field (like "ghcr-login").  
* Set an expiration date.
* Under Select scopes, check the boxes based on what you need to do:
  * read:packages: Required to download/pull container images.  
  * write:packages: Required to upload/push container images. (Note: Checking this usually auto-selects the full repo scope. If you want to strictly limit the token to just packages for security, you can bypass the auto-select by clicking this specific link to create your token).
  * delete:packages: Required if you need the ability to delete images.  
* Scroll to the bottom and click Generate token.

```bash
GHCR_TOKEN=<github-token> make publish GHCR_USER=<github-username>
# or for arm64:
GHCR_TOKEN=<github-token> make publish ARCH=arm64 GHCR_USER=<github-username>
```
