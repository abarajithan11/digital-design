# Course Website and Material (SystemVerilog) for CSE 140

Visit the site: [abapages.com/digital-design](https://abapages.com/digital-design/)

## Quickstart on Examples

* Please do these three steps before the first lecture. If you need any support, we will help you during the office hours on Wednesday.
* You need a machine with either Ubuntu, Windows 11 or macOS and about 3–4 GB of space.

### 1. Install Docker on your system.

   <details>
   <summary><strong>Ubuntu</strong></summary>

   * If you prefer detailed instructions, or if anything goes wrong, [follow this instead.](https://docs.docker.com/engine/install/ubuntu/).

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
   <summary><strong>macOS</strong></summary>

   - If you prefer detailed instructions, or if anything goes wrong, [follow this instead.](https://docs.docker.com/desktop/setup/install/mac-install/)
   1. Download Docker Desktop for Mac [from here](https://docs.docker.com/desktop/setup/install/mac-install/) for your CPU architecture: Apple Silicon vs Intel.
   1. Open the `.dmg` file.
   1. Drag Docker into **Applications**.
   1. Start Docker Desktop.
   1. Test Docker:

      ```bash
      docker run --rm hello-world
      ```

   </details>

   <details>
   <summary><strong>Windows 11</strong></summary>

   - If you prefer detailed instructions, or if anything goes wrong, [follow this instead.](https://docs.docker.com/desktop/setup/install/windows-install/)

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
          1. Under **Choose how to Run Docker Containers**, select **WSL2**
          1. Click **Apply & restart**.

   4. Test whether Docker works correctly from PowerShell (use a regular terminal without administrator for everything now):

      ```powershell
      wsl  # Enter WSL Ubuntu from a non-administrator powershell
      docker run --rm hello-world
      ```

   </details>

### 2. Set up our Docker container:

Clone the repo, pull the docker image & start the container, and if you use macOS, do the extra step of setting up GUI.

```bash
git clone https://github.com/abarajithan11/digital-design
cd digital-design
make fresh         # This pulls the image and starts the container
```

<details>
<summary><strong>For macOS, set up GUI forwarding</strong></summary> 


* If you prefer detailed instructions, or if anything goes wrong, [follow this instead.](https://docs.google.com/document/d/1l72L8z40apZd3GiiAejpVXLE-SHvmgHlTK4Icwdl5iI/)
* After running `make fresh`: 

   1. Visit `vnc://localhost:5901` in a web browser. 
   1. Allow the website to open **Screen Sharing**. 
   1. You will see a black window. This is where any GUI from the Docker container will appear.
   1. Go back to the terminal to run other commands. The VNC window is for displaying GUI apps only.

</details>

### 3. Test one example with GUI:

   ```bash
   make enter                            # Enter the container from the terminal while Docker is running
   make sim gds show_layout DESIGN=alu   # This should run for a minute or two and show the KLayout GUI
   # Ctrl+C                              # To exit KLayout
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

## Run on real hardware (Tang Nano 20K FPGA)

Implement any design (except the CPU) onto a [Sipeed Tang Nano 20K](https://wiki.sipeed.com/tangnano20k).

### 1. Build the bitstream in the container:

First you need to "compile" or implement your SystemVerilog code into a bitstream, which is a stream of bits that configures the FPGA to implement the digital logic you wanted.

```bash
make enter
make bitstream DESIGN=up_counter
exit
```

### 2. Program it via the web programmer

<details>
<summary><strong>Windows: install the WebUSB driver through Zadig first</strong></summary>

1. Download and run [Zadig](https://zadig.akeo.ie/). It is portable and does not need to be installed.
2. Connect the Tang Nano 20K to Windows. Do not attach it to WSL yet.
3. In Zadig, select **Options → List All Devices**.
4. Select the Tang Nano JTAG interface, usually **Dual RS232-HS (Interface 0)** or **Interface A**.
5. Select **WinUSB** and click **Replace Driver**.
6. Close Zadig when the replacement finishes.

Only replace **Interface 0/A**. 
Do not replace **Interface 1/B**: it is the USB-UART interface used by `uart_echo.py` and `fir_audio.py`.

</details>

Next you need to send the bitstream to your FPGA (called programming the FPGA). 
Connect your FPGA to your machine, then visit [openFPGALoader Web](https://ofl.trabucayre.com/) via Google Chrome. 
Note, Firefox does not support the required WebUSB access.

1. Visit the site, then choose  
   - Automatic Operations
   - Tang Nano 20K
   - SRAM or Flash (SRAM is volatile, Flash persists after power-off)

2. and select the file:
   ```text
   material/fpga/tang_nano_20k/build/up_counter/up_counter.fs
   ```
3. Then click **Program FPGA**. You will see this and the lights lighting up as a counter.
   ```
   Done
   DONE
   Execution completed in ---ms
   ```

### 3. UART Serial Examples - Sending data between your computer and FPGA

For UART examples, you need to switch the ownership of the USB port between Chrome, and your OS.

<details>
<summary><strong>Ubuntu</strong></summary>

Chrome cannot claim the board while the Linux FTDI serial driver owns it. 
Before programming, close programs using `/dev/ttyUSB*` and run:

```bash
sudo modprobe -r ftdi_sio
```

After programming, restore the serial ports for UART examples:

```bash
sudo modprobe ftdi_sio
```

</details>

<details>
<summary><strong>Windows (WSL)</strong></summary>

First connect the board to your computer.
Now Windows owns it. 
Program from Chrome. 
For UART examples, switch the ownership to WSL after you program from Chrome.

To do this, open Powershell as Administrator. Then:

```powershell
usbipd list
usbipd bind --busid <BUSID>
usbipd attach --wsl --busid <BUSID>
```

Run `bind` once from Administrator PowerShell. 
Run `attach` from a regular PowerShell each time the device is reconnected.

</details>

<details>
<summary><strong>MacOS</strong></summary>

Open the web programmer in Chrome, select the generated `.fs` file, and program the board. 
For UART examples, set the Python script's `PORT` to the board's `/dev/tty.usbserial-*` device.

</details>

More FPGA details are in
[`material/fpga/tang_nano_20k/README.md`](material/fpga/tang_nano_20k/README.md).

### 4. Run the FIR audio example

The following commands build `sys_fir_filter`, load it into volatile FPGA SRAM,
stream `material/data/chill_sub.wav` through the board, write
`material/data/fpga_out.wav`, and compare it with the reference output.

1. From the `digital-design` repository root, build the bitstream inside the container:

   ```bash
   make enter
   make bitstream DESIGN=sys_fir_filter
   exit
   ```

2. Install the Python packages on the host once:

   ```bash
   python3 -m pip install --user numpy scipy pyserial
   ```

3. Program `sys_fir_filter.fs` into SRAM with openFPGALoader Web as described above. Restore or attach the serial device using the relevant OS section, then run the Python script. It resolves its WAV paths relative to itself, so it also works when invoked by absolute path from another directory.

   ```bash
   python3 material/py/fir_audio.py
   ```

Expected final output:

```text
PASS: all 735000 samples match .../material/data/bass_only_8bit.wav.
```

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
make scratch   # build from Dockerfile for your $ARCH & start
make enter     # Enter the container
# -------------- do the testing
exit           # Leave the container

# Publish the image your build & tested to ghcr.io/ucsd-cse140-s126/digital-design-$(ARCH):latest
GHCR_TOKEN=<github-token> GHCR_USER=<github-username> make publish   
```

The Makefile auto-detects `ARCH` from your machine (`amd64` or `arm64`). You can still override it explicitly if needed, for example `ARCH=arm64`.

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

</details>
