# Qplumbum

Qplumbum is a Linux desktop client for Xray and V2Ray, built with Qt 6 and QML. It provides a modern graphical interface for importing, editing and running Xray/V2Ray configurations.

## Highlights

- Qt 6 QML interface with light, dark and system themes
- Xray-core and V2Ray-core support
- VMess, VLESS, Shadowsocks, Trojan, HTTP and SOCKS connections
- Subscription management, routing, latency checks and traffic statistics
- Linux system proxy and TUN integration
- X11 and Wayland desktop sessions
- Simplified Chinese, Traditional Chinese, English and Russian translations

## Supported Linux distributions

The CI validation matrix covers Debian, Ubuntu, Fedora, Arch Linux, openSUSE, Gentoo and NixOS. Package names and optional desktop integration may vary between distributions.

## Build

Requirements: Linux, Qt 6.5+, CMake 3.21+, Qt6 QML/Quick Controls and Effects, gRPC, protobuf, libcurl and OpenSSL.

```bash
git clone --recurse-submodules https://github.com/ruizhi-lab/Qplumbum.git
cd Qplumbum
cmake -B build -DPLUMBUM_UI_TYPE=QML -DPLUMBUM_EMBED_TRANSLATIONS=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

The QWidget frontend remains available as an optional Linux Qt 6 build:

```bash
cmake -B build-widget -DPLUMBUM_UI_TYPE=QWidget -DCMAKE_BUILD_TYPE=Release
cmake --build build-widget --parallel
```

## Runtime

Configure the Xray/V2Ray core and geodata paths in Settings, import a supported share link, then start the connection. The Linux system proxy and TUN options require the corresponding desktop tools and, for TUN, root or `CAP_NET_ADMIN` permission.

## License

GPLv3. See [LICENSE](LICENSE).
