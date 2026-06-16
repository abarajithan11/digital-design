#!/usr/bin/env bash
# Bring up an in-container virtual X display (Xvfb) + window manager + VNC server,
# so GL GUIs (openscad, klayout 3D) render with llvmpipe (full OpenGL) and can be
# viewed over VNC at vnc://localhost:$VNC_PORT. Used on macOS, where XQuartz only
# offers indirect OpenGL 1.4 (too old for openscad's Qt5 GL widget). Launched by
# basic_docker.mk on macOS hosts only. Idempotent; safe to run more than once.
set -u
VNC_DISPLAY="${VNC_DISPLAY:-:99}"
VNC_PORT="${VNC_PORT:-5901}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080x24}"
VNC_PASSWORD="${VNC_PASSWORD:-cse140}"
dnum="${VNC_DISPLAY#:}"

command -v Xvfb >/dev/null 2>&1 || { echo "start-vnc: Xvfb not installed (non-GUI image)" >&2; exit 0; }

# x11vnc treats any WAYLAND_DISPLAY in the environment (the container is started
# with an empty one) as a Wayland session and refuses to run; we only serve the
# X11 Xvfb display, so clear these first.
unset WAYLAND_DISPLAY XDG_SESSION_TYPE

# Already up? (Xvfb owns the display socket)
if pgrep -x Xvfb >/dev/null 2>&1 && [ -e "/tmp/.X11-unix/X${dnum}" ]; then
    echo "start-vnc: already running on ${VNC_DISPLAY} (port ${VNC_PORT})"
    exit 0
fi

Xvfb "$VNC_DISPLAY" -screen 0 "$VNC_GEOMETRY" +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
for _ in $(seq 1 100); do
    DISPLAY="$VNC_DISPLAY" xdpyinfo >/dev/null 2>&1 && break
    sleep 0.1
done
DISPLAY="$VNC_DISPLAY" fluxbox >/tmp/fluxbox.log 2>&1 &

mkdir -p "$HOME/.vnc"
x11vnc -storepasswd "$VNC_PASSWORD" "$HOME/.vnc/passwd" >/dev/null 2>&1
x11vnc -display "$VNC_DISPLAY" -rfbauth "$HOME/.vnc/passwd" -rfbport "$VNC_PORT" \
       -forever -shared -bg -quiet -noxdamage >/tmp/x11vnc.log 2>&1

echo "start-vnc: VNC ready -> vnc://localhost:${VNC_PORT}  (display ${VNC_DISPLAY}, password ${VNC_PASSWORD})"
