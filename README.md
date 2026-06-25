# Course Website and Material (SystemVerilog) for CSE 140

Visit the site: [abapages.com/digital-design](https://abapages.com/digital-design/)

## Quickstart on Examples

You need a machine with either Ubuntu, Windows 11 or macOS and about 3–4 GB of space.

1. Install Docker on your system.

   <details>
   <summary><strong>Ubuntu</strong> — <a href="https://docs.docker.com/engine/install/ubuntu/">Full instructions here</a></summary>

   1. Install Docker:

      ```bash
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      sudo usermod -aG docker "$USER"
      ```

   2. Test Docker:

      ```bash
      docker run --rm hello-world
      ```

   </details>

   <details>
   <summary><strong>macOS</strong> — <a href="https://docs.docker.com/desktop/setup/install/mac-install/">Full instructions here</a></summary>

   1. Download Docker Desktop for Mac [from here](https://docs.docker.com/desktop/setup/install/mac-install/) for your right architecture (Apple Silicon vs Intel).
   1. Open the `.dmg` file.
   1. Drag Docker into **Applications**.
   1. Start Docker Desktop.
   1. Test Docker:

      ```bash
      docker run --rm hello-world
      ```

   </details>

   <details>
   <summary><strong>Windows 11</strong> — <a href="https://docs.docker.com/desktop/setup/install/windows-install/">Full instructions here</a></summary>

   1. Open PowerShell as Administrator.

   2. Install WSL if you have not already:

      ```powershell
      # Replace D:\WSL\Ubuntu with the desired location
      wsl --install -d Ubuntu --location D:\WSL\Ubuntu
      ```

   3. Install Docker Desktop on Windows, not from WSL:

      1. Download and install [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
      1. Open Docker Desktop once and accept the license.
      1. Ensure **Use the WSL 2 based engine** is enabled; it is normally enabled automatically:
          1. Click the gear icon in the upper-right.
          1. Go to **General**.
          1. Check **Use the WSL 2 based engine**.
          1. Click **Apply & restart**.

   4. Test whether Docker works correctly from PowerShell:

      ```powershell
      wsl  # Enter WSL Ubuntu
      docker run --rm hello-world
      ```

   </details>

2. Set up our Docker container:

   - Pull and start the container:

     ```bash
     git clone https://github.com/abarajithan11/digital-design
     cd digital-design
     make fresh         # This pulls the image and starts the container
     ```

    <details>
    <summary><strong>macOS GUI setup</strong> — <a href="https://docs.google.com/document/d/1l72L8z40apZd3GiiAejpVXLE-SHvmgHlTK4Icwdl5iI/edit?usp=sharing">Detailed instructions here</a></summary> 
    
    After running `make fresh`: 
    
    1. Visit `vnc://localhost:5901` in a web browser. 
    2. Allow the website to open **Screen Sharing**. 
    3. You will see a black window. This is where any GUI from the Docker container will appear. 
    
    </details>

3. Test our Docker container and GUI:

   ```bash
   make enter                            # Enter the container from the terminal while Docker is running
   make sim gds show_layout DESIGN=alu   # This should run for a minute or two and show the KLayout GUI
   exit                                  # Exit the container; you can run make enter again later
   ```


## Run Examples

From inside the Docker container (to be run from `material` directory, which is default when doing `make enter`):

```bash
make sim                 DESIGN=alu
make gds                 DESIGN=alu

make gds                 DESIGN=auto_light USE_BASIC_GATES=1
make show_syn_netlist    DESIGN=auto_light
make show_final_nestlist DESIGN=auto_light

make sim_all
make gds_all
make show_layout         DESIGN=alu
make show_3d             DESIGN=alu
make show_3d_cell        CELL=NAND2x1 
make show_3d_cell        # show all available cells
make show_layout_cells   

exit                     # to leave the container
```

* The root `Makefile` handles Docker, artifact collection, and site generation. 
* The `material/Makefile` handles the in-container design flows.
* Reports and layout images are stored in `material/openroad/work/reports/asap7/alu/base`

## For Staff

<details>
   <summary><strong>To locally serve the site</strong></summary>

```bash
pip install sphinx furo myst-parser
make 3d_assets
make site
make serve
```

Then open `http://localhost:8000` in your browser.

</details>

<details>
   <summary><strong>To build and publish the docker container (for instructors)</strong></summary>

To build that same image locally from the Dockerfile (slow, might take 3 hours on ARM), start and use it:

```bash
make scratch
make enter
```

The Makefile auto-detects `ARCH` from your machine (`amd64` or `arm64`) and uses the matching `ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest` image. You can still override it explicitly if needed, for example `ARCH=arm64`.

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
```

</details>

