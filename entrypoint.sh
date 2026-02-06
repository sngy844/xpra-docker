#!/usr/bin/env bash
set -euo pipefail

PW_FILE="/run/secrets/xpra_password"
export XDG_RUNTIME_DIR=/tmp/xdg-runtime
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
# Xpra server options:
# - bind-tcp on 0.0.0.0:14500
# - html5 enabled
# - password required (server will reject clients without it)
# The --password-file behavior is documented in xpra man pages. :contentReference[oaicite:4]{index=4}
exec xpra start :100 \
  --bind-tcp=0.0.0.0:14500 \
  --html=on \
  --daemon=no \
  --mdns=no \
  --dbus=no \
  --pulseaudio=no \
  --notifications=no \
  --printing=no \
  --file-transfer=no \
  --webcam=no \
  --bell=no \
  --system-tray=no \
  --clipboard=yes \
  --exit-with-children \
  --start-child="xterm" \
  --password-file="${PW_FILE}"
  #--start-child="firefox --no-remote --new-instance about:blank" \
