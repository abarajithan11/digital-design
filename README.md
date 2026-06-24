# Course Website and Material (SystemVerilog) for CSE 140

Visit the site: [abapages.com/digital-design](https://abapages.com/digital-design/)

## Setting up the container and running the examples

To pull our pre-built Docker image (fast), start and use it: 

```bash
make fresh
make enter
```

To build that same image locally from the Dockerfile (slow, might take 3 hours on ARM), start and use it:

```bash
make scratch
make enter
```

The Makefile auto-detects `ARCH` from your machine (`amd64` or `arm64`) and uses the matching `ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest` image. You can still override it explicitly if needed, for example `ARCH=arm64`.

### For ARM-based machines (Mac/Windows)

Check [here](https://docs.google.com/document/d/1l72L8z40apZd3GiiAejpVXLE-SHvmgHlTK4Icwdl5iI/edit?usp=sharing) for prerequisites and tips before proceeding.

### Run simulation and the RTL-to-GDS2 flow with ASAP7

From inside the Docker container (to be run from `material` directory, which is default when doing `make enter`):

```bash
make sim                DESIGN=alu
make gds                DESIGN=alu

make gds                DESIGN=auto_light USE_BASIC_GATES=1
make show_syn_netlist   DESIGN=auto_light
make show_final_nestlist DESIGN=auto_light

make sim_all
make gds_all
make show_layout        DESIGN=alu
make show_3d            DESIGN=alu
make show_3d_cell       CELL=NAND2x1 
make show_3d_cell       # show all available cells
make show_layout_cells

exit                    # to leave the container
```

* The root `Makefile` handles Docker, artifact collection, and site generation. 
* The `material/Makefile` handles the in-container design flows.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/alu/base`

## For Staff

### To locally serve the site

```bash
pip install sphinx furo myst-parser
make 3d_assets
make site
make serve
```

Then open `http://localhost:8000` in your browser.


### To publish the docker container (for instructors)

Publishing is manual. `make publish` builds the image locally as `ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest` using the auto-detected `ARCH` unless overridden, and pushes it. CI and `make fresh` only pull this image.

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
