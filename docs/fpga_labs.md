# FPGA Labs: Python Setup

The FPGA tools use two separate environments:

- Build the `.fs` bitstream inside the course Docker container.
- Run the Python UART, audio, and neural-network tools on your computer in a
  Conda environment.

Complete the [Docker setup](https://github.com/abarajithan11/digital-design/)
first. If you have not cloned the repository yet, run:

```bash
git clone https://github.com/abarajithan11/digital-design
cd digital-design
```

All commands below assume that your terminal is in this `digital-design`
directory.

## 1. Install Miniconda

Open the instructions for your operating system. If Conda is already installed
and `conda --version` works, skip to the next section.

```{raw} html
<details>
<summary><strong>Ubuntu</strong></summary>
```

1. Follow the official [Miniconda Linux installation
   guide](https://www.anaconda.com/docs/getting-started/miniconda/install/linux-install).
   Download the installer that matches your processor.
2. Accept the default install location. When asked whether to initialize
   Conda, answer `yes`.
3. Close and reopen the terminal, then check the installation:

   ```bash
   conda --version
   ```

```{raw} html
</details>
```

```{raw} html
<details>
<summary><strong>macOS</strong></summary>
```

1. Follow the official [Miniconda macOS installation
   guide](https://www.anaconda.com/docs/getting-started/miniconda/install/mac-cli-install).
   Choose the installer that matches your Mac's processor.
2. When asked whether to initialize Conda, answer `yes`.
3. Close and reopen Terminal, then check the installation:

   ```bash
   conda --version
   ```

```{raw} html
</details>
```

```{raw} html
<details>
<summary><strong>Windows 11</strong></summary>
```

Install and run Conda directly on Windows. WSL is still used for the course
Docker container, but it is not used for the Python environment or UART
scripts.

1. Follow the official [Miniconda Windows installation
   guide](https://www.anaconda.com/docs/getting-started/miniconda/install/windows-gui-install).
2. Choose **Just Me**, keep the default install location, and do not select
   **Add Miniconda3 to my PATH environment variable**.
3. Find **Anaconda Prompt (Miniconda3)** in the Start menu, right-click it, and
   select **Run as administrator**. Check the installation:

   ```powershell
   conda --version
   ```

Use the Administrator prompt when creating or updating the environment. After
that, use a regular Anaconda Prompt to activate the environment and run Python
scripts. Change to the Windows location of your `digital-design` checkout
first.

```{raw} html
</details>
```

## 2. Create the environment

On Windows, run the `conda env create` command below from the Administrator
Anaconda Prompt opened in the previous section. Ubuntu and macOS users should
use their regular terminal.

For the UART, CPU, FIR filter, and other labs that do not train a neural
network, use the smaller `tang-basic` environment:

```bash
conda env create -f python-setup/tang-basic.yml
conda activate tang-basic
```

If the lab includes neural-network training, use `tang-training` instead. It
includes the basic packages as well as PyTorch, Torchvision, and Brevitas:

```bash
conda env create -f python-setup/tang-training.yml
conda activate tang-training
```

You only need to create an environment once. You do need to activate it in each
new terminal before running a lab script.

Check that the basic packages and the expected Python version are available:

```bash
python --version
python -c "import numpy, scipy, serial; print('FPGA Python environment is ready')"
```

The version should be Python 3.11, and the second command should print the
ready message without an error.

## 3. Give the Python tools access to the board

Program the matching `.fs` file with [openFPGALoader
Web](https://ofl.trabucayre.com/) in Google Chrome before running a UART script.
Firefox does not provide the WebUSB access used by the programmer.

USB setup differs by operating system. Follow the relevant steps after
programming the board.

```{raw} html
<details>
<summary><strong>Ubuntu</strong></summary>
```

Before programming, close any serial programs that are using the board and
release the FTDI serial driver:

```bash
sudo modprobe -r ftdi_sio
```

After programming, restore the driver and check that the serial ports appear:

```bash
sudo modprobe ftdi_sio
ls /dev/ttyUSB*
```

If Python reports `Permission denied`, add your user to the `dialout` group,
then sign out and back in:

```bash
sudo usermod -aG dialout "$USER"
```

```{raw} html
</details>
```

```{raw} html
<details>
<summary><strong>macOS</strong></summary>
```

No driver handoff is normally needed. After programming the board, its UART
port should look like `/dev/cu.usbserial-*` or `/dev/tty.usbserial-*`.

To list both forms, run:

```bash
ls /dev/cu.usbserial-* /dev/tty.usbserial-* 2>/dev/null
```

The Python tools usually detect the correct port automatically. If they find
more than one possible serial port, pass the one beginning with `/dev/cu.` to
`--port`.

```{raw} html
</details>
```

```{raw} html
<details>
<summary><strong>Windows 11</strong></summary>
```

There are two interfaces on the board: interface 0/A is JTAG programming, and
interface 1/B is UART. Keep them separate during the setup.

One-time WebUSB setup:

1. Download and run [Zadig](https://zadig.akeo.ie/).
2. Connect the Tang Nano 20K to Windows.
3. In Zadig, select **Options → List All Devices**.
4. Select **Dual RS232-HS (Interface 0)** or **Interface A**.
5. Select **WinUSB**, then click **Replace Driver**.

Do not replace the driver for interface 1/B; that is the UART used by the
Python scripts.

Program the board from Chrome. Then open **Anaconda Prompt (Miniconda3)** and
list the serial ports visible to native Windows Python:

```powershell
python -m serial.tools.list_ports -v
```

The UART interface should appear as a `COM` port. The lab scripts normally
detect it automatically; if needed, pass it explicitly, for example
`--port COM5`. Do not attach the board to WSL with `usbipd` when running the
Python tools on Windows.

```{raw} html
</details>
```

## 4. Run a lab script

Activate the environment, program the bitstream that matches the script, and
run the script from the repository root. For example:

```bash
conda activate tang-basic
python material/py/fpga_uart_echo.py
python material/py/fpga_fir_offline.py
```

The scripts detect the Tang Nano UART port automatically. If more than one
serial port is connected, select it explicitly:

```bash
python material/py/fpga_uart_echo.py --port /dev/ttyUSB1
```

Use the path printed by your system; on macOS it will usually begin with
`/dev/cu.usbserial-`, and on Windows it will look like `COM5`.

## Common fixes

- **`conda: command not found`:** close and reopen the terminal. If that does
  not help, return to the Miniconda guide for your operating system and run its
  shell-initialization step.
- **The environment already exists:** activate it instead of creating it again.
  To bring it up to date, run `conda env update -f
  python-setup/tang-basic.yml --prune` (or use the training YAML).
- **No serial port is found:** make sure the board is programmed, Chrome has
  released it, and you completed the operating-system setup above. List what
  Python can see with `python -m serial.tools.list_ports -v`.
- **The wrong serial port is selected:** rerun the script with `--port PORT`.
