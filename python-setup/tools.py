#!/usr/bin/env python3
"""Install and run the host-side digital-design Python tools.

Dependencies are installed with ``pip --target`` under python-setup/.python-packages.
Nothing is installed into the system or user Python environment, and there is no
virtual environment to activate.

Examples:
    # Windows
    py -3.11 python-setup/tools.py setup host
    py -3.11 python-setup/tools.py uart-echo

    # macOS/Linux
    python3.11 python-setup/tools.py setup host
    python3.11 python-setup/tools.py uart-echo

Use ``setup audio`` for fir-live, ``setup train-nn`` for training, and
``setup webcam-nn`` for webcam-to-FPGA inference. ``setup all`` installs all
four independent dependency sets.
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import sys


SETUP_DIR = Path(__file__).resolve().parent
REPO_DIR = SETUP_DIR.parent
MATERIAL_DIR = REPO_DIR / "material"
PACKAGE_DIR = SETUP_DIR / ".python-packages"

ENVIRONMENTS = {
    "host": SETUP_DIR / "requirements-host.txt",
    "audio": SETUP_DIR / "requirements-audio.txt",
    "train-nn": SETUP_DIR / "requirements-train-nn.txt",
    "webcam-nn": SETUP_DIR / "requirements-webcam-nn.txt",
}

COMMANDS = {
    "cpu-program": ("host", MATERIAL_DIR / "py" / "fpga_program_cpu.py"),
    "fir-generate": ("host", MATERIAL_DIR / "py" / "sys_fir_filter_gen.py"),
    "fir-live": ("audio", MATERIAL_DIR / "py" / "fpga_fir_live_audio.py"),
    "fir-offline": ("host", MATERIAL_DIR / "py" / "fpga_fir_offline.py"),
    "train-nn": ("train-nn", MATERIAL_DIR / "py" / "nn_model.py"),
    "uart-echo": ("host", MATERIAL_DIR / "py" / "fpga_uart_echo.py"),
}


def check_python() -> None:
    """Fail early instead of letting binary-wheel errors confuse students."""
    version = sys.version_info[:2]
    if not (3, 10) <= version < (3, 13):
        raise SystemExit(
            "Python 3.10, 3.11, or 3.12 is required; "
            f"this interpreter is Python {version[0]}.{version[1]}."
        )


def install_environment(name: str) -> None:
    """Install one complete dependency set into a fresh local directory."""
    requirements = ENVIRONMENTS[name]
    target = PACKAGE_DIR / name
    staging = PACKAGE_DIR / f".{name}.staging"

    shutil.rmtree(staging, ignore_errors=True)
    staging.mkdir(parents=True, exist_ok=True)

    command = [
        sys.executable,
        "-m",
        "pip",
        "install",
        "--disable-pip-version-check",
        "--ignore-installed",
        # The target is isolated from globally installed packages, so conflicts
        # in the invoking Python installation are irrelevant to this install.
        "--no-warn-conflicts",
        "--only-binary=:all:",
        "--target",
        str(staging),
        "--requirement",
        str(requirements),
    ]
    print(f"Installing {name} dependencies into {target}", flush=True)
    try:
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError:
        shutil.rmtree(staging, ignore_errors=True)
        raise SystemExit(f"Failed to install the {name} dependencies.") from None

    shutil.rmtree(target, ignore_errors=True)
    staging.replace(target)
    print(f"Installed {name} dependencies.")

    if name == "audio" and sys.platform.startswith("linux"):
        print(
            "Linux note: fir-live also needs the PortAudio runtime supplied by "
            "your Linux distribution (for example, libportaudio2 on Debian/Ubuntu)."
        )


def setup(name: str) -> None:
    names = ENVIRONMENTS if name == "all" else (name,)
    for environment in names:
        install_environment(environment)


def run_command(name: str, arguments: list[str]) -> None:
    environment, script = COMMANDS[name]
    dependencies = PACKAGE_DIR / environment
    if not dependencies.is_dir():
        raise SystemExit(
            f"The {environment} dependencies are not installed. Run:\n"
            f"  {Path(sys.executable).name} {Path(__file__).name} setup {environment}"
        )

    # Put project-local dependencies and sibling helper modules ahead of any
    # globally installed packages, then give scripts their expected material/ cwd.
    sys.path.insert(0, str(dependencies))
    sys.path.insert(0, str(script.parent))
    os.chdir(MATERIAL_DIR)
    sys.argv = [str(script), *arguments]
    runpy.run_path(str(script), run_name="__main__")


def parser() -> argparse.ArgumentParser:
    command_parser = argparse.ArgumentParser(description=__doc__)
    subparsers = command_parser.add_subparsers(dest="command", required=True)

    setup_parser = subparsers.add_parser(
        "setup", help="install a project-local dependency set"
    )
    setup_parser.add_argument(
        "environment",
        nargs="?",
        default="host",
        choices=[*ENVIRONMENTS, "all"],
        help="dependency set to install (default: host)",
    )

    for name, (environment, _) in COMMANDS.items():
        subparsers.add_parser(
            name,
            add_help=False,
            help=f"run with the {environment} dependency set",
        )

    return command_parser


def main() -> None:
    check_python()
    command_parser = parser()
    args, tool_arguments = command_parser.parse_known_args()
    if args.command == "setup":
        if tool_arguments:
            command_parser.error(
                f"unrecognized arguments: {' '.join(tool_arguments)}"
            )
        setup(args.environment)
    else:
        run_command(args.command, tool_arguments)


if __name__ == "__main__":
    main()
