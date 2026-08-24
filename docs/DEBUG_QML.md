# QPlumbum QML Debug Workflow

This project uses a direct `nohup` process for Debug GUI testing. Do not use
systemd for this workflow.

## Build and install

```bash
cmake --build /tmp/plumbum-build --parallel 4
cmake --install /tmp/plumbum-build --prefix /tmp/plumbum-debug-install
git diff --check
```

The Debug build is configured with the QML UI and embedded translations:

```bash
cmake -S . -B /tmp/plumbum-build \
  -DPLUMBUM_UI_TYPE=QML \
  -DPLUMBUM_EMBED_TRANSLATIONS=ON \
  -DCMAKE_BUILD_TYPE=Debug
```

## Stop and start Debug safely

Only terminate exact QPlumbum process names. Never use a broad `pkill` for
`xray` or `v2ray`, because v2rayN owns separate core instances.

```bash
pkill -TERM -x plumbum 2>/dev/null || true
pkill -TERM -x qplumbum 2>/dev/null || true

setsid nohup env \
  DISPLAY=:0 \
  WAYLAND_DISPLAY=wayland-0 \
  XAUTHORITY=/run/user/1000/xauth_kQrWTs \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  /tmp/plumbum-debug-install/bin/plumbum \
  >/tmp/plumbum-debug.log 2>&1 </dev/null &
started=$!
disown "$started" 2>/dev/null || true
```

Verify that QPlumbum is alive and v2rayN's core is still present:

```bash
ps -eo pid=,ppid=,stat=,comm=,args= | \
  awk '$4 == "plumbum" || $4 == "qplumbum" || $4 == "xray" || $4 == "v2ray" { print }'
rg -i 'QQml|failed to load|referenceerror|typeerror|module|syntax' \
  /tmp/plumbum-debug.log || true
```

## Wayland screenshots

Keep the QPlumbum window in the foreground, then capture only the active
window with Plasma's `spectacle`:

```bash
spectacle --background --nonotify --activewindow \
  --output /tmp/qplumbum-active.png
```

Do not use a full-screen capture when reviewing layout. The screenshot must
contain the QPlumbum window itself so dialog geometry, rounded corners, and
scrollbar placement can be checked.

For automated dialog screenshots when Wayland does not accept synthetic
mouse events, run the same installed Debug binary temporarily with
`QT_QPA_PLATFORM=xcb`, bring its XWayland window to the foreground, capture
with the same `spectacle --activewindow` command, then terminate only that
temporary QPlumbum process and restart the normal Wayland instance.

After every UI task, leave the normal Wayland Debug build running with
`nohup` for manual retesting.
