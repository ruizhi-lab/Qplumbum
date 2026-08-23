<p align="center">
<img width="210" height="210" align="left" style="float: left; margin: 0 10px 0 0;" src="https://raw.githubusercontent.com/ruizhi-lab/Qplumbum/main/assets/icons/plumbum.png" alt="Qplumbum"/>
</br>
<h1>Qplumbum - Unleash Your Xray & V2Ray</h1>
基于 <b>Qt6</b> 的 Linux <b>Xray / V2Ray</b> 客户端
</br>
现代 Qt6 QML 界面 · Linux 原生集成 · Xray/V2Ray 双内核 · 多语言
</p>

<p align="center">
<a href="https://github.com/ruizhi-lab/Qplumbum/releases"><img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue"/></a>
<a href="https://github.com/ruizhi-lab/Qplumbum/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-GPLv3-green"/></a>
<a href="https://github.com/ruizhi-lab/Qplumbum"><img alt="Qt6" src="https://img.shields.io/badge/Qt-6.5%2B-brightgreen"/></a>
</p>

## ✨ 特性

### 界面
- 🖥️ **现代 Qt6 QML 界面** — 暗色主题、侧边栏导航、卡片式连接列表、圆角分区设计
- 🎨 **浅色 / 深色 / 跟随系统** — 三模式主题，实时跟随系统外观变化
- 🌍 **多语言** — 简体中文、繁體中文、English、Русский，运行时可切换
- 📌 **系统托盘** — 托盘图标 + 快捷菜单（显示/隐藏、连接/断开、退出）
- 🔘 **统一按钮风格** — 自定义 FlatButton 组件，全应用一致

### 核心功能
- 🚀 **双内核支持** — Xray-core / V2Ray-core 自动适配（兼容 Xray 26.x / V2Ray 5.x）
- 🔌 **多协议** — VMess、VLESS、Shadowsocks、Trojan、HTTP、SOCKS 等
- 📡 **订阅管理** — 订阅分组、一键更新
- 📊 **实时流量统计** — gRPC API 实时速度与总流量显示
- ⚡ **延迟测试** — 连接级延迟检测
- 🌐 **PAC 模式** — v2rayN 式白名单（绕过大陆）/ 黑名单（GFWList）/ 全局，切换即时生效
- 🛡️ **TUN 系统代理** — 虚拟网卡接管全系统流量（需 root / CAP_NET_ADMIN）
- 🗂️ **分组管理** — 多分组、连接导入导出、分享链接复制

## 构建

要求：Linux、Qt 6.5+、CMake 3.21+、gRPC、protobuf、libcurl、OpenSSL。

官方验证矩阵覆盖 Debian、Ubuntu、Fedora、Arch Linux、openSUSE、Gentoo 和 NixOS；桌面会话支持 X11 与 Wayland。

```bash
# 克隆并初始化子模块
git clone --recurse-submodules https://github.com/ruizhi-lab/Qplumbum.git
cd Qplumbum

# QML 界面构建（推荐）
cmake -B build \
               -DPLUMBUM_UI_TYPE=QML \
               -DPLUMBUM_EMBED_TRANSLATIONS=ON \
               -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)

# QWidget 界面构建（可选）
cmake -B build-widget -DPLUMBUM_UI_TYPE=QWidget -DCMAKE_BUILD_TYPE=Release
cmake --build build-widget -j$(nproc)
```

## 使用

1. 在「设置」页配置内核路径（如 `/usr/bin/xray` 或 `/usr/bin/v2ray`）与 geo 数据目录
2. 在「连接」页导入分享链接（`vmess://`、`vless://`、`ss://`、`trojan://`）
3. 点击「Connect」即可连接，默认 SOCKS 代理端口 1089、HTTP 端口 8889
4. 状态栏一键切换 PAC 模式（白名单/黑名单/全局）
5. 在「设置」页启用 TUN 系统代理，或在「外观」区切换主题与语言

> **TUN 权限**：TUN 需要 root 或 CAP_NET_ADMIN。可用 `sudo plumbum` 运行，或
> 给内核授权：`sudo setcap cap_net_admin,cap_net_raw+eip $(which xray)`

## 项目结构

```
src/
├── base/            # 基础配置与数据模型
├── core/            # 连接管理、内核交互、配置生成
├── components/      # 插件、订阅、延迟测试等
├── plugins/         # 内置协议插件
└── ui/
    ├── qml/         # 现代 Qt6 QML 界面（推荐）
    ├── widgets/     # 可选 QWidget 界面
    └── cli/         # 命令行界面
```

## 路线图

- [x] Qt6 QML 现代界面
- [x] Xray-core / V2Ray-core 双内核
- [x] PAC 模式（白名单/黑名单/全局）
- [x] TUN 系统级代理
- [x] 多语言（简中/繁中/英/俄）
- [x] 系统托盘
- [ ] 图形化连接编辑器
- [ ] 订阅自动更新调度
- [ ] 系统代理一键切换

## 许可证

GPLv3。详见 [LICENSE](LICENSE)。
