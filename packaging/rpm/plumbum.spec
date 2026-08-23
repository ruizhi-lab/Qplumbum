Name:           plumbum
Version:        1.0.0
Release:        1%{?dist}
Summary:        Linux Qt 6 GUI client for Xray and V2Ray
License:        GPL-3.0-or-later
URL:            https://github.com/ruizhi-lab/Qplumbum
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  ninja-build
BuildRequires:  pkgconfig
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel
BuildRequires:  qt6-qtsvg-devel
BuildRequires:  qt6-qttools-devel
BuildRequires:  grpc-devel
BuildRequires:  protobuf-devel
BuildRequires:  protobuf-compiler
BuildRequires:  libcurl-devel
BuildRequires:  openssl-devel

%description
Qplumbum is a modern Linux Qt 6 GUI client for Xray and V2Ray compatible
protocols, including VMess, VLESS, Trojan and Shadowsocks.

%prep
%autosetup -n %{name}-%{version}

%build
%cmake -G Ninja \
    -DPLUMBUM_EMBED_TRANSLATIONS=ON \
    -DPLUMBUM_DISABLE_AUTO_UPDATE=ON
%cmake_build

%install
%cmake_install

%files
%license LICENSE
%doc README.md
/usr/bin/plumbum
/usr/share/applications/plumbum.desktop
/usr/share/metainfo/plumbum.metainfo.xml
/usr/share/icons/hicolor/*/apps/plumbum.*

%changelog
* Thu Jan 01 2026 Qplumbum contributors - 1.0.0-1
- Initial Qt 6 Linux package
