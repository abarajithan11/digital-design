# FPGA Setup: Our Examples on Tang Nano 20K

An FPGA is a flexible chip whose internal logic can be configured to realize
the digital circuit we want. Unlike an ASIC, which is manufactured for one
fixed design, an FPGA lets us write a circuit in SystemVerilog, load it onto the
chip, test it, and replace it with another circuit later.

For hands-on experience, we highly recommend buying the inexpensive Tang Nano
20K from either [Amazon](https://www.amazon.com/Tang-Nano-20K-Development-Computer/dp/B0GCVFLFPP/ref=sr_1_1?crid=32SUSOZGEPZC6&dib=eyJ2IjoiMSJ9.Ow-0YEuarWedIbDbBtOwJv4xyhVW5_qqUfOOYW4fjGJ99bRBUHdab_BTUgz_6cyVtW1qZHPo8yTWj7sGpRE0HKkyiMDAd1MSCc4Ea5OlgFsarB_M8y7Nu8sm-REsz0zofY8SMuVfBaJi9QecvRpHNlEv532AEdds7yn9hJ7QXQg.ZnVmNGdJX19GAopy9VviKF0bf9yAC0TmHz8vlWZ4xGQ&dib_tag=se&keywords=speed%2Btang%2Bnano%2B20k&qid=1779923800&sprefix=sipeed%2Btang%2Bnano%2B20k%2B%2Caps%2C286&sr=8-1&th=1),
or [AliExpress](https://www.aliexpress.us/item/3256805394833478.html?spm=a2g0o.productlist.main.1.4b04HoNAHoNAIF&algo_pvid=809e9b1f-24a1-4c4b-b135-129d55ab0ff9&algo_exp_id=809e9b1f-24a1-4c4b-b135-129d55ab0ff9-0&pdp_ext_f=%7B%22order%22%3A%22621%22%2C%22eval%22%3A%221%22%2C%22fromPage%22%3A%22search%22%7D&pdp_npi=6%40dis%21USD%2132.39%2131.89%21%21%2132.39%2131.89%21%402103110517799236779054890ef451%2112000033650315249%21sea%21US%210%21ABX%211%210%21n_tag%3A-29910%3Bd%3A4ca8c57d%3Bm03_new_user%3A-29895%3BpisId%3A5000000204886261&curPageLogUid=zXmtXJ517f75&utparam-url=scene%3Asearch%7Cquery_from%3A%7Cx_object_id%3A1005005581148230%7C_p_origin_prod%3A).
On AliExpress, carefully choose **Bundle: Nano 20K No header**, and
triple-check the delivery address before checkout.

## What We Are Doing

We will turn our simulated SystemVerilog circuits into configurations that run
on a real FPGA. The board is described in the official [Tang Nano 20K
datasheet](https://dl.sipeed.com/fileList/TANG/Nano_20K/1_Datasheet/Sipeed%20Tang%20nano%2020K%20Datasheet%20V1.3-en_US.pdf).
It uses a Gowin `GW2AR-18` FPGA; the [board overview](https://wiki.sipeed.com/tangnano20k)
has additional hardware details.

Our flow is:

1. **Design the circuit in SystemVerilog.** See our [SystemVerilog RTL](https://github.com/abarajithan11/digital-design/tree/main/material/rtl).
2. **Test it in simulation** using a [SystemVerilog testbench](https://github.com/abarajithan11/digital-design/tree/main/material/tb):
   `make sim DESIGN=<design>`.
3. **Translate it into a bitstream**—the configuration loaded onto the FPGA—using
   our [`fpga.mk` build flow](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/common/fpga.mk):
   `make bitstream DESIGN=<design>`.
4. **Program the FPGA** with [openFPGALoader
   Web](https://ofl.trabucayre.com/).
5. **Interact with the circuit on the FPGA:** press its buttons, observe its
   LEDs, or send and receive data from your computer.

The examples use two separate environments:

- Build `.fs` bitstreams and train the neural network inside the course Docker
  container.
- Run the Python UART, audio, and camera tools directly on your computer in a
  Conda environment.

If you want to train the neural network from scratch, run this from the repository root.

```bash
make enter
python3 py/nn_model.py
exit
```

Complete the [Docker setup](https://github.com/abarajithan11/digital-design/)
first. If you have not cloned the repository yet, run:

```bash
git clone https://github.com/abarajithan11/digital-design
cd digital-design
```

All commands below assume that your terminal is in this `digital-design`
directory.

## 1. Full Adder on the FPGA

During discussion, we put the `up_counter` on the FPGA. The `full_adder`
follows the same flow.

1. **Design:** Our
   [`full_adder` RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/full_adder.sv)
   is connected to an idealized, active-high FPGA interface through its
   [`board_glue`](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/reference/full_adder.sv).
2. **Test in simulation:** Run its
   [`tb_full_adder.sv`](https://github.com/abarajithan11/digital-design/blob/main/material/tb/reference/tb_full_adder.sv):

   ```bash
   make enter
   make sim DESIGN=full_adder
   exit
   ```

3. **Translate to a bitstream:**

   ```bash
   make enter
   make bitstream DESIGN=full_adder
   exit
   ```

   The build flow in
   [`fpga.mk`](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/common/fpga.mk)
   reads
   [`full_adder.f`](https://github.com/abarajithan11/digital-design/blob/main/material/designs/reference/full_adder.f),
   removes simulation-only sources, adds `board_glue` and the fixed
   [`board_top.sv`](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/common/board_top.sv),
   then runs the open-source Apicula flow
   (`yosys → nextpnr-himbaechel → gowin_pack`) to generate
   `material/fpga/tang_nano_20k/build/full_adder/full_adder.fs`.

   `board_top` gives every design the same clean, active-high interface
   (`clk`, `rst`, `btn`, `led`, UART, and GPIO). It handles:

   - the board pins from [`board.cst`](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/common/board.cst)
     and the system clock;
   - power-on reset;
   - active-low LED inversion;
   - button synchronization and debouncing;
   - UART input synchronization and GPIO.

4. **Program the FPGA:** In Chrome, program
   `material/fpga/tang_nano_20k/build/full_adder/full_adder.fs`.
5. **Interact with the circuit:** Press **S1** and **S2** to change the two
   inputs. LED0 shows the sum and LED1 shows the carry output.

You can try other simple designs in exactly the same way:

- `and_gate`: [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/and_gate.sv) · [board_glue](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/reference/and_gate.sv)
- `not_gate`: [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/not_gate.sv) · [board_glue](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/reference/not_gate.sv)
- `xor_gate`: [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/xor_gate.sv) · [board_glue](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/reference/xor_gate.sv)
- `mux`: [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/mux.sv) · [board_glue](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/reference/mux.sv)
- `decoder`: [RTL](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/decoder.sv) · [board_glue](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/reference/decoder.sv)

You can wrap your own module in the same way: add its `.f` file and copy
[`top_glue/_skeleton.sv`](https://github.com/abarajithan11/digital-design/blob/main/material/fpga/tang_nano_20k/top_glue/_skeleton.sv)
to create its matching `board_glue`.

The reusable FPGA files are organized as follows:

```text
material/fpga/tang_nano_20k/
  common/board_top.sv                    fixed board wrapper
  common/board.cst                       fixed pin constraints
  common/fpga.mk                         bitstream build rules
  top_glue/{cpu,reference,system}/       one board_glue per design
  build/<design>/                        generated files; not committed
material/designs/{cpu,reference,systems}/<design>.f
```

`FPGA` defaults to `tang_nano_20k`. A design can be built when it has both a matching `.f` source list and `board_glue`.
The build ignores `tb_*` and `vip_*`
simulation sources. From inside the container, `make bitstream_all` builds every design that has both files.

## 2. Make Your Design and Your Computer Communicate

We will now put more advanced designs on the FPGA and communicate with them
from the computer. We use UART (**Universal Asynchronous Receiver/Transmitter**),
a simple serial protocol supported by almost every system. UART is easy to use
but relatively slow. We will cover the protocol and its circuits in the
lectures.

On the computer, Python can send and receive UART data through the
[`pyserial` library](https://pyserial.readthedocs.io/en/latest/). Later examples
also need numerical and audio libraries, so we install everything together in
a Conda environment.

The board's USB-to-UART bridge operates at **2 Mbaud**, has a **32-byte buffer**, and has no hardware flow control.
At the board's 54 MHz system clock,
the UART circuits use `CLKS_PER_BIT=27`.
The echo and FIR designs use a two-entry
[`skid_buffer`](https://github.com/abarajithan11/digital-design/blob/main/material/rtl/reference/skid_buffer.sv),
while the host scripts transfer at most 32 bytes at a time and drain replies so
the bridge does not silently drop data.

### 2.1 Install Miniconda

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

### 2.2 Create the Environment

On Windows, run the `conda env create` command below from the Administrator
Anaconda Prompt opened in the previous section. Ubuntu and macOS users should
use their regular terminal.

```bash
conda env create -f python-setup/tang-basic.yml
conda activate tang-basic
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

### 2.3 Program the FPGA

Program the matching `.fs` file with [openFPGALoader
Web](https://ofl.trabucayre.com/) in Google Chrome before running a UART script.
Firefox does not provide the WebUSB access used by the programmer.

```{raw} html
<details>
<summary><strong>Windows 11: one-time WebUSB setup</strong></summary>
```

There are two interfaces on the board: interface 0/A is JTAG programming, and
interface 1/B is UART. Keep them separate during the setup.

One-time WebUSB setup:

1. Download and run [Zadig](https://zadig.akeo.ie/). It is portable and does
   not need to be installed.
2. Connect the Tang Nano 20K to Windows.
3. In Zadig, select **Options → List All Devices**.
4. Select **Dual RS232-HS (Interface 0)** or **Interface A**.
5. Select **WinUSB**, then click **Replace Driver**.

Do not replace the driver for interface 1/B; that is the UART used by the
Python scripts.

```{raw} html
</details>
```

To program a bitstream:

1. Open [openFPGALoader Web](https://ofl.trabucayre.com/) in Chrome and select
   **Automatic Operations**.
2. Select **Tang Nano 20K**.
3. Select **SRAM** for a temporary configuration or **Flash** to keep the
   configuration after power is removed.
4. Select the design's `.fs` file and click **Program FPGA**. A successful run
   ends with `Done`, `DONE`, and `Execution completed`.

### 2.4 Run the UART Echo Test

This test checks if your computer can talk to your hardware in the FPGA.

1. Simulate `uart_echo`, then build its bitstream inside the Docker container:

   ```bash
   make enter
   make sim DESIGN=uart_echo
   make bitstream DESIGN=uart_echo
   exit
   ```

2. In Chrome, program
   `material/fpga/tang_nano_20k/build/uart_echo/uart_echo.fs`.
3. Activate the basic environment and run the loopback test:

   ```bash
   conda activate tang-basic
   python material/py/fpga_uart_echo.py
   ```

   If the Python script cannot find or open the board, see [UART access
   troubleshooting](#uart-access-troubleshooting).

The test should finish with:

```text
PASS: echoed 4096 bytes with no loss.
```

## 3. FIR Filter

The FIR filter examples send audio samples to `sys_fir_filter` over UART and
receive the filtered samples back. Start with a saved audio file, then try the
same circuit with live microphone audio.

### 3.1 Offline File Test

This test sends the included audio file through the FPGA and compares every
output sample with the reference file. The script reads (or downloads)
`material/data/chill_sub.wav`, writes `material/data/fpga_out.wav`, and compares
it with `material/data/bass_only_8bit.wav`. These paths are resolved relative
to the script, so it can also be invoked from another directory.

1. Simulate `sys_fir_filter`, then build its bitstream inside the Docker
   container. The simulation generates the files needed by the example:

   ```bash
   make enter
   make sim DESIGN=sys_fir_filter
   make bitstream DESIGN=sys_fir_filter
   exit
   ```

2. In Chrome, program
   `material/fpga/tang_nano_20k/build/sys_fir_filter/sys_fir_filter.fs`.
3. Activate the basic environment and process the included WAV file:

   ```bash
   conda activate tang-basic
   python material/py/fpga_fir_offline.py
   ```

   If the Python script cannot find or open the board, see [UART access
   troubleshooting](#uart-access-troubleshooting).

The test should finish with a message similar to:

```text
PASS: all 735000 samples match .../material/data/bass_only_8bit.wav.
```

Both scripts detect the Tang Nano UART port automatically. If more than one
serial port is connected, select it explicitly:

```bash
python material/py/fpga_fir_offline.py --port /dev/ttyUSB1
```

Use the path printed by your system; on macOS it will usually begin with
`/dev/cu.usbserial-`, and on Windows it will look like `COM5`.

### 3.2 Live Audio Test

This example records your microphone, sends the audio through the FPGA, and
plays the filtered result through your selected output device. You should hear
mostly bass because the FPGA is running a low-pass filter.

1. Simulate `sys_fir_filter`, then build its bitstream inside the Docker
   container. The simulation generates the files needed by the example:

   ```bash
   make enter
   make sim DESIGN=sys_fir_filter
   make bitstream DESIGN=sys_fir_filter
   exit
   ```

2. In Chrome, program
   `material/fpga/tang_nano_20k/build/sys_fir_filter/sys_fir_filter.fs`.
3. Connect headphones and start at a low volume. Using speakers near the
   microphone can create loud feedback.
4. Activate the basic environment and list the available audio devices:

   ```bash
   conda activate tang-basic
   python material/py/fpga_fir_live_audio.py --list
   ```

5. If your default microphone and output are correct, start the live filter:

   ```bash
   python material/py/fpga_fir_live_audio.py
   ```

   If the Python script cannot find or open the board, see [UART access
   troubleshooting](#uart-access-troubleshooting).

   Press **Ctrl+C** to stop.

To select different devices, pass the number shown by `--list` or a unique part
of each device name:

```bash
python material/py/fpga_fir_live_audio.py --input 2 --output 5
```

The UART port can be selected in the same command when automatic detection is
not possible. For example, on native Windows:

```powershell
python material/py/fpga_fir_live_audio.py --port COM5 --input 2 --output 5
```

```{raw} html
<details>
<summary><strong>Live-audio troubleshooting by operating system</strong></summary>
```

**Ubuntu:** Select the intended microphone and headphones in [**Settings →
Sound**](https://help.ubuntu.com/stable/ubuntu-help/sound-usemic.html.en). If
`--list` reports that PortAudio sees no devices, install the system audio
support and try again:

```bash
sudo apt update
sudo apt install libportaudio2 libasound2-plugins
```

If the Conda interpreter still cannot see the devices, install the Ubuntu
Python audio packages and run only the live-audio script with the system
interpreter:

```bash
sudo apt install python3-numpy python3-serial python3-sounddevice
/usr/bin/python3 material/py/fpga_fir_live_audio.py --list
/usr/bin/python3 material/py/fpga_fir_live_audio.py
```

**macOS:** The first run may request microphone access. If it was denied, open
[**System Settings → Privacy & Security →
Microphone**](https://support.apple.com/guide/mac-help/control-access-to-the-microphone-on-mac-mchla1b1e1fe/mac)
and allow access for the terminal application you are using. Run the `--list`
command again after changing the permission.

**Windows 11:** Open [**Settings → Privacy & security →
Microphone**](https://support.microsoft.com/en-us/windows/privacy/turn-on-app-permissions-for-your-microphone-in-windows)
and enable **Microphone access** and **Let desktop apps access your
microphone**. Select the intended microphone and headphones in **Settings →
System → Sound**, then run the `--list` command again.

```{raw} html
</details>
```

## 4. Run the CPU

This example loads a small program into the CPU on the FPGA over UART, runs it,
and sends the data memory back to the computer. The program computes
`1 + ... + 10` and stores the result in `dmem[4]`.

1. Simulate `cpu_fpga`, then build its bitstream inside the Docker container:

   ```bash
   make enter
   make sim DESIGN=cpu_fpga
   make bitstream DESIGN=cpu_fpga
   exit
   ```

2. In Chrome, program
   `material/fpga/tang_nano_20k/build/cpu_fpga/cpu_fpga.fs`.
3. Activate the basic environment and load the example program:

   ```bash
   conda activate tang-basic
   python material/py/fpga_program_cpu.py
   ```

   If the Python script cannot find or open the board, see [UART access
   troubleshooting](#uart-access-troubleshooting).

4. Press **S1** when prompted. The CPU runs at about one instruction per
   second, and the LEDs show the opcode. Hold **S2** to show the low six bits of
   `dmem[4]` instead.

When the run finishes, the script prints the returned data memory. The final
line should be:

```text
dmem[4] = 55  (sum(1..10) should be 55)
```

## Common fixes

- **`conda: command not found`:** close and reopen the terminal. If that does
  not help, return to the Miniconda guide for your operating system and run its
  shell-initialization step.
- **The environment already exists:** activate it instead of creating it again.
  To bring it up to date, run `conda env update -f
  python-setup/tang-basic.yml --prune`.
- **No serial port is found:** see [UART access
  troubleshooting](#uart-access-troubleshooting).
- **The wrong serial port is selected:** rerun the script with `--port PORT`.
- **The live-audio script uses the wrong microphone or output:** run it with
  `--list`, then pass the desired device numbers to `--input` and `--output`.

(uart-access-troubleshooting)=
## UART Access Troubleshooting

macOS and native Windows normally require no UART handoff after programming.
Ubuntu may need its FTDI driver released before Chrome programs the board and
restored afterward.

First, check which serial ports Python can see:

```bash
python -m serial.tools.list_ports -v
```

```{raw} html
<details>
<summary><strong>Ubuntu</strong></summary>
```

If Chrome cannot claim the board, close any programs using `/dev/ttyUSB*` and
release the FTDI serial driver before programming:

```bash
sudo modprobe -r ftdi_sio
```

After programming, restore the driver and check that the ports appear:

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

No driver restore is normally needed. The board's UART should appear as
`/dev/cu.usbserial-*` or `/dev/tty.usbserial-*`:

```bash
ls /dev/cu.usbserial-* /dev/tty.usbserial-* 2>/dev/null
```

If the script finds more than one possible port, pass the `/dev/cu.*` port
explicitly with `--port`.

```{raw} html
</details>
```

```{raw} html
<details>
<summary><strong>Windows 11</strong></summary>
```

No driver restore is normally needed. Interface 1/B should remain available to
native Windows Python as a `COM` port:

```powershell
python -m serial.tools.list_ports -v
```

If the board is not listed, make sure Zadig replaced the driver for interface
0/A only. Do not replace interface 1/B, and do not attach the board to WSL with
`usbipd`. If automatic detection is ambiguous, pass the port explicitly, for
example `--port COM5`.

```{raw} html
</details>
```
