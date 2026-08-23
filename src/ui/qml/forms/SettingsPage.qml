import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Settings page
Rectangle {
    id: root
    color: "transparent"

    // Compact controls keep the dense settings form visually balanced.
    component CompactTextField: TextField {
        implicitHeight: 36
        padding: 8
    }
    component CompactTextArea: TextArea {
        implicitHeight: 36
        padding: 8
    }
    component CompactComboBox: ComboBox {
        implicitHeight: 36
    }
    component CompactSpinBox: SpinBox {
        implicitHeight: 36
    }
    component CompactButton: Button {
        implicitHeight: 36
        padding: 10
    }
    component CompactSwitch: Switch {
        id: compactSwitch
        implicitHeight: 32
        spacing: 7

        indicator: Rectangle {
            x: compactSwitch.leftPadding
            y: (compactSwitch.height - height) / 2
            implicitWidth: 34
            implicitHeight: 18
            radius: height / 2
            color: compactSwitch.checked ? window.cPrimary : window.cBorder

            Rectangle {
                width: 14
                height: 14
                y: 2
                x: compactSwitch.checked ? parent.width - width - 2 : 2
                radius: width / 2
                color: compactSwitch.checked ? "#ffffff" : window.cTextDim
                Behavior on x { NumberAnimation { duration: 100 } }
            }
        }
        contentItem: Text {
            text: compactSwitch.text
            font: compactSwitch.font
            color: window.cText
            verticalAlignment: Text.AlignVCenter
            leftPadding: compactSwitch.indicator.width + compactSwitch.spacing
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        contentWidth: availableWidth
        contentHeight: settingsColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: settingsColumn
            width: Math.min(parent.width, 920)
            x: Math.max(0, (parent.width - width) / 2)
            spacing: 12

            Text {
                text: qsTr("Settings")
                font.pixelSize: 24
                font.bold: true
                color: window.cText
                Layout.bottomMargin: 2
            }

            // -------- Appearance / theme card --------
            Rectangle {
                id: appearanceCard
                Layout.fillWidth: true
                implicitHeight: appearanceLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: appearanceLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Text {
                        text: qsTr("Appearance")
                        font.pixelSize: 13
                        font.bold: true
                        color: window.cPrimaryAlt
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        // Follow system
                        Rectangle {
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 36
                            radius: 6
                            color: plumbum.themeMode === 0 ? window.cPrimary : window.cSurfaceAlt
                            border.color: plumbum.themeMode === 0 ? window.cPrimary : window.cBorder

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Follow System")
                                font.pixelSize: 11
                                font.bold: plumbum.themeMode === 0
                                color: plumbum.themeMode === 0 ? "#ffffff" : window.cTextDim
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: plumbum.setThemeMode(0)
                            }
                        }
                        // Light
                        Rectangle {
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 36
                            radius: 6
                            color: plumbum.themeMode === 1 ? window.cPrimary : window.cSurfaceAlt
                            border.color: plumbum.themeMode === 1 ? window.cPrimary : window.cBorder

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Light")
                                font.pixelSize: 11
                                font.bold: plumbum.themeMode === 1
                                color: plumbum.themeMode === 1 ? "#ffffff" : window.cTextDim
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: plumbum.setThemeMode(1)
                            }
                        }
                        // Dark
                        Rectangle {
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 36
                            radius: 6
                            color: plumbum.themeMode === 2 ? window.cPrimary : window.cSurfaceAlt
                            border.color: plumbum.themeMode === 2 ? window.cPrimary : window.cBorder

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Dark")
                                font.pixelSize: 11
                                font.bold: plumbum.themeMode === 2
                                color: plumbum.themeMode === 2 ? "#ffffff" : window.cTextDim
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: plumbum.setThemeMode(2)
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text {
                            text: qsTr("Language")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.fillWidth: true
                        }
                        CompactComboBox {
                            id: langSelector
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 36
                            model: [
                                { code: "system", label: qsTr("System (Auto)") },
                                { code: "en_US", label: "English" },
                                { code: "zh_CN", label: "简体中文" },
                                { code: "zh_TW", label: "繁體中文" },
                                { code: "ru_RU", label: "Русский" }
                            ]
                            textRole: "label"
                            Component.onCompleted: {
                                for (var i = 0; i < model.length; i++) {
                                    if (model[i].code === plumbum.language)
                                        currentIndex = i
                                }
                            }
                            onActivated: function(index) {
                                plumbum.setLanguage(model[index].code)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Text {
                            text: qsTranslate("PreferencesWindow", "Start with boot")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.fillWidth: true
                        }
                        CompactSwitch {
                            checked: plumbum.autoStartEnabled
                            onToggled: plumbum.setAutoStartEnabled(checked)
                        }
                    }
                }
            }

            // -------- Core settings card --------
            Rectangle {
                id: coreCard
                Layout.fillWidth: true
                implicitHeight: coreLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: coreLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Text {
                        text: qsTr("V2Ray / Xray Core")
                        font.pixelSize: 13
                        font.bold: true
                        color: window.cPrimaryAlt
                    }

                    GridLayout {
                        id: coreGrid
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10

                        Text {
                            text: qsTr("Core executable:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            CompactTextField {
                                id: corePathInput
                                Layout.fillWidth: true
                                text: plumbum.v2rayCorePath
                                placeholderText: qsTr("e.g. /usr/local/bin/xray or v2ray")
                            }
                            CompactButton {
                                text: qsTr("Apply")
                                enabled: corePathInput.text !== plumbum.v2rayCorePath
                                onClicked: plumbum.setV2rayCorePath(corePathInput.text)
                            }
                        }

                        Text {
                            text: qsTr("Assets directory:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            CompactTextField {
                                id: assetsPathInput
                                Layout.fillWidth: true
                                text: plumbum.v2rayAssetsPath
                                placeholderText: qsTr("geoip.dat / geosite.dat directory")
                            }
                            CompactButton {
                                text: qsTr("Apply")
                                enabled: assetsPathInput.text !== plumbum.v2rayAssetsPath
                                onClicked: plumbum.setV2rayAssetsPath(assetsPathInput.text)
                            }
                        }

                        Text {
                            text: qsTr("API Statistics:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        CompactSwitch {
                            checked: plumbum.kernelApiEnabled
                            onToggled: plumbum.setKernelApiEnabled(checked)
                        }

                        Text {
                            text: qsTr("Stats port:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        CompactSpinBox {
                            from: 1024
                            to: 65535
                            value: plumbum.statsPort
                            editable: true
                            onValueModified: plumbum.setStatsPort(value)
                        }
                    }
                }
            }

            // -------- Local proxy / inbound card --------
            Rectangle {
                id: inboundCard
                Layout.fillWidth: true
                implicitHeight: inboundLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: inboundLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Text {
                        text: qsTr("Local Proxy / Inbound")
                        font.pixelSize: 13
                        font.bold: true
                        color: window.cPrimaryAlt
                    }
                    Text {
                        text: qsTr("Configure the local SOCKS, HTTP and transparent proxy listeners used by Xray/V2Ray.")
                        font.pixelSize: 11
                        color: window.cTextDim
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10

                        Text { text: qsTr("Listen address"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactTextField {
                            Layout.fillWidth: true
                            text: plumbum.inboundListenAddress
                            placeholderText: "127.0.0.1"
                            onEditingFinished: plumbum.setInboundListenAddress(text)
                        }

                        Text { text: qsTr("SOCKS inbound"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.socksInboundEnabled; onToggled: plumbum.setSocksInboundEnabled(checked) }

                        Text { text: qsTr("SOCKS port"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSpinBox { from: 1; to: 65535; value: plumbum.socksPort; editable: true; onValueModified: plumbum.setSocksPort(value) }

                        Text { text: qsTr("SOCKS listen address"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactTextField { Layout.fillWidth: true; text: plumbum.socksListenAddress; onEditingFinished: plumbum.setSocksListenAddress(text) }

                        Text { text: qsTr("SOCKS UDP"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.socksUdpEnabled; onToggled: plumbum.setSocksUdpEnabled(checked) }

                        Text { text: qsTr("SOCKS authentication"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.socksAuthEnabled; onToggled: plumbum.setSocksAuthEnabled(checked) }

                        Text { text: qsTr("HTTP inbound"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.httpInboundEnabled; onToggled: plumbum.setHttpInboundEnabled(checked) }

                        Text { text: qsTr("HTTP port"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSpinBox { from: 1; to: 65535; value: plumbum.httpPort; editable: true; onValueModified: plumbum.setHttpPort(value) }

                        Text { text: qsTr("HTTP authentication"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.httpAuthEnabled; onToggled: plumbum.setHttpAuthEnabled(checked) }

                        Text { text: qsTr("TProxy inbound"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.tproxyInboundEnabled; onToggled: plumbum.setTproxyInboundEnabled(checked) }

                        Text { text: qsTr("TProxy port"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSpinBox { from: 1; to: 65535; value: plumbum.tproxyPort; editable: true; onValueModified: plumbum.setTproxyPort(value) }

                        Text { text: qsTr("TProxy IPv4"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactTextField { Layout.fillWidth: true; text: plumbum.tproxyListenAddress; onEditingFinished: plumbum.setTproxyListenAddress(text) }

                        Text { text: qsTr("TProxy IPv6"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactTextField { Layout.fillWidth: true; text: plumbum.tproxyListenAddressV6; onEditingFinished: plumbum.setTproxyListenAddressV6(text) }

                        Text { text: qsTr("TProxy TCP / UDP"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        RowLayout {
                            spacing: 12
                            CompactSwitch { text: qsTr("TCP"); checked: plumbum.tproxyTcpEnabled; onToggled: plumbum.setTproxyTcpEnabled(checked) }
                            CompactSwitch { text: qsTr("UDP"); checked: plumbum.tproxyUdpEnabled; onToggled: plumbum.setTproxyUdpEnabled(checked) }
                        }

                        Text { text: qsTr("Set system proxy"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.systemProxyEnabled; onToggled: plumbum.setSystemProxyEnabled(checked) }

                        Text { text: qsTr("Browser forwarder"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignVCenter }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            CompactTextField { Layout.fillWidth: true; text: plumbum.browserForwarderAddress; onEditingFinished: plumbum.setBrowserForwarderAddress(text) }
                            CompactSpinBox { from: 1; to: 65535; value: plumbum.browserForwarderPort; editable: true; onValueModified: plumbum.setBrowserForwarderPort(value) }
                        }
                    }
                }
            }

            // -------- Routing / DNS card --------
            Rectangle {
                id: routingCard
                Layout.fillWidth: true
                implicitHeight: routingLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: routingLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Text { text: qsTr("Routing / DNS"); font.pixelSize: 13; font.bold: true; color: window.cPrimaryAlt }
                    GridLayout {
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10
                        Text { text: qsTr("Routing mode"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactComboBox {
                            model: [qsTr("Whitelist (CN direct)"), qsTr("Blacklist (GFW proxy)"), qsTr("Global proxy")]
                            currentIndex: plumbum.pacMode
                            onActivated: plumbum.setPacMode(currentIndex)
                        }
                        Text { text: qsTr("Domain strategy"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactComboBox {
                            model: ["AsIs", "UseIP", "UseIPv4", "UseIPv6"]
                            currentIndex: Math.max(0, model.indexOf(plumbum.domainStrategy))
                            onActivated: plumbum.setDomainStrategy(model[currentIndex])
                        }
                        Text { text: qsTr("Domain matcher"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactComboBox {
                            model: ["mph", "linear"]
                            currentIndex: Math.max(0, model.indexOf(plumbum.domainMatcher))
                            onActivated: plumbum.setDomainMatcher(model[currentIndex])
                        }
                        Text { text: qsTr("Force direct"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.forceDirect; onToggled: plumbum.setForceDirect(checked) }
                        Text { text: qsTr("Bypass CN mainland"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.bypassCN; onToggled: plumbum.setBypassCN(checked) }
                        Text { text: qsTr("Bypass private LAN"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.bypassLAN; onToggled: plumbum.setBypassLAN(checked) }
                        Text { text: qsTr("Bypass BitTorrent"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.bypassBT; onToggled: plumbum.setBypassBT(checked) }
                        Text { text: qsTr("Use V2Ray DNS for direct"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.v2rayFreedomDNS; onToggled: plumbum.setV2rayFreedomDNS(checked) }
                        Text { text: qsTr("DNS intercept"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.dnsIntercept; onToggled: plumbum.setDnsIntercept(checked) }
                        Text { text: qsTr("DNS servers"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignTop }
                        CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.dnsServers; placeholderText: qsTr("One server per line, e.g. 1.1.1.1"); onFocusChanged: if (!focus) plumbum.setDnsServers(text) }
                        Text { text: qsTr("Domain direct / block / proxy"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignTop }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.domainDirectRules; placeholderText: qsTr("Direct rules"); onFocusChanged: if (!focus) plumbum.setDomainDirectRules(text) }
                            CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.domainBlockRules; placeholderText: qsTr("Block rules"); onFocusChanged: if (!focus) plumbum.setDomainBlockRules(text) }
                            CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.domainProxyRules; placeholderText: qsTr("Proxy rules"); onFocusChanged: if (!focus) plumbum.setDomainProxyRules(text) }
                        }
                        Text { text: qsTr("IP direct / block / proxy"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150; Layout.alignment: Qt.AlignTop }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.ipDirectRules; placeholderText: qsTr("Direct rules"); onFocusChanged: if (!focus) plumbum.setIpDirectRules(text) }
                            CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.ipBlockRules; placeholderText: qsTr("Block rules"); onFocusChanged: if (!focus) plumbum.setIpBlockRules(text) }
                            CompactTextArea { Layout.fillWidth: true; Layout.preferredHeight: 64; text: plumbum.ipProxyRules; placeholderText: qsTr("Proxy rules"); onFocusChanged: if (!focus) plumbum.setIpProxyRules(text) }
                        }
                        Text { text: qsTr("FakeDNS IP pool"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactTextField { Layout.fillWidth: true; text: plumbum.fakeDnsIpPool; onEditingFinished: plumbum.setFakeDnsIpPool(text) }
                        Text { text: qsTr("FakeDNS pool size"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSpinBox { from: 1; to: 16777216; value: plumbum.fakeDnsPoolSize; editable: true; onValueModified: plumbum.setFakeDnsPoolSize(value) }
                    }
                }
            }

            // -------- Forward proxy card --------
            Rectangle {
                id: forwardProxyCard
                Layout.fillWidth: true
                implicitHeight: forwardProxyLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: forwardProxyLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12
                    Text { text: qsTr("Forward Proxy"); font.pixelSize: 13; font.bold: true; color: window.cPrimaryAlt }
                    GridLayout {
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10
                        Text { text: qsTr("Enable forward proxy"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.forwardProxyEnabled; onToggled: plumbum.setForwardProxyEnabled(checked) }
                        Text { text: qsTr("Type"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactComboBox { model: ["http", "socks"]; currentIndex: model.indexOf(plumbum.forwardProxyType); onActivated: plumbum.setForwardProxyType(model[currentIndex]) }
                        Text { text: qsTr("Host address"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactTextField { Layout.fillWidth: true; text: plumbum.forwardProxyAddress; onEditingFinished: plumbum.setForwardProxyAddress(text) }
                        Text { text: qsTr("Port"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSpinBox { from: 1; to: 65535; value: plumbum.forwardProxyPort; editable: true; onValueModified: plumbum.setForwardProxyPort(value) }
                        Text { text: qsTr("Authentication"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactSwitch { checked: plumbum.forwardProxyAuth; onToggled: plumbum.setForwardProxyAuth(checked) }
                        Text { text: qsTr("Username"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactTextField { Layout.fillWidth: true; text: plumbum.forwardProxyUsername; onEditingFinished: plumbum.setForwardProxyUsername(text) }
                        Text { text: qsTr("Password"); color: window.cTextDim; font.pixelSize: 12; Layout.preferredWidth: 150 }
                        CompactTextField { Layout.fillWidth: true; echoMode: TextInput.Password; text: plumbum.forwardProxyPassword; onEditingFinished: plumbum.setForwardProxyPassword(text) }
                    }
                }
            }

            // -------- TUN system proxy card --------
            Rectangle {
                id: tunCard
                Layout.fillWidth: true
                implicitHeight: tunLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: tunLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: qsTr("TUN System Proxy")
                            font.pixelSize: 13
                            font.bold: true
                            color: window.cPrimaryAlt
                            Layout.fillWidth: true
                        }
                        CompactSwitch {
                            checked: plumbum.tunEnabled
                            enabled: plumbum.tunAvailable
                            onToggled: plumbum.setTunEnabled(checked)
                        }
                    }

                    Text {
                        visible: plumbum.tunAvailable && !plumbum.tunEnabled
                        text: qsTr("Route all system traffic through the proxy via a virtual TUN interface.")
                        font.pixelSize: 10
                        color: window.cTextDim
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: !plumbum.tunAvailable
                        text: qsTr("⚠ TUN requires an Xray core and root privileges or CAP_NET_ADMIN. Please select Xray and grant the required capability if needed.")
                        font.pixelSize: 10
                        color: window.cOrange
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }

                    GridLayout {
                        id: tunGrid
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 10

                        Text {
                            text: qsTr("TUN IPv4:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            CompactTextField {
                                id: tunIpv4Input
                                Layout.fillWidth: true
                                text: plumbum.tunIpv4
                                validator: RegularExpressionValidator { regularExpression: /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ }
                            }
                            CompactButton {
                                text: qsTr("Apply")
                                enabled: tunIpv4Input.text !== plumbum.tunIpv4 && tunIpv4Input.acceptableInput
                                onClicked: plumbum.setTunIpv4(tunIpv4Input.text)
                            }
                        }

                        Text {
                            text: qsTr("MTU:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        CompactSpinBox {
                            from: 576
                            to: 65535
                            value: plumbum.tunMtu
                            editable: true
                            onValueModified: plumbum.setTunMtu(value)
                        }

                        Text {
                            text: qsTr("TUN IPv6:")
                            font.pixelSize: 12
                            color: window.cTextDim
                            Layout.preferredWidth: 140
                            Layout.alignment: Qt.AlignVCenter
                        }
                        CompactTextField {
                            Layout.fillWidth: true
                            text: plumbum.tunIpv6
                            onEditingFinished: plumbum.setTunIpv6(text)
                        }

                        Text { text: qsTr("Auto route:"); font.pixelSize: 12; color: window.cTextDim; Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.tunAutoRoute; onToggled: plumbum.setTunAutoRoute(checked) }

                        Text { text: qsTr("Strict route:"); font.pixelSize: 12; color: window.cTextDim; Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.tunStrictRoute; onToggled: plumbum.setTunStrictRoute(checked) }

                        Text { text: qsTr("TUN sniffing:"); font.pixelSize: 12; color: window.cTextDim; Layout.preferredWidth: 140; Layout.alignment: Qt.AlignVCenter }
                        CompactSwitch { checked: plumbum.tunSniffing; onToggled: plumbum.setTunSniffing(checked) }
                    }
                }
            }

            // -------- Current group overrides --------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: groupOverrideLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: groupOverrideLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8
                    Text { text: qsTr("Current group overrides"); font.pixelSize: 13; font.bold: true; color: window.cPrimaryAlt }
                    Text { text: qsTr("Select a group on the Connections page before enabling these options."); color: window.cTextDim; font.pixelSize: 11; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: qsTr("Override routing rules"); color: window.cTextDim; font.pixelSize: 12; Layout.fillWidth: true }
                        CompactSwitch { checked: plumbum.groupRouteOverride; onToggled: plumbum.setGroupRouteOverride(checked) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: qsTr("Override DNS / FakeDNS"); color: window.cTextDim; font.pixelSize: 12; Layout.fillWidth: true }
                        CompactSwitch { checked: plumbum.groupDnsOverride; onToggled: plumbum.setGroupDnsOverride(checked) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: qsTr("Override connection mode"); color: window.cTextDim; font.pixelSize: 12; Layout.fillWidth: true }
                        CompactSwitch { checked: plumbum.groupConnectionOverride; onToggled: plumbum.setGroupConnectionOverride(checked) }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: qsTr("Override Forward Proxy"); color: window.cTextDim; font.pixelSize: 12; Layout.fillWidth: true }
                        CompactSwitch { checked: plumbum.groupForwardProxyOverride; onToggled: plumbum.setGroupForwardProxyOverride(checked) }
                    }
                }
            }

            // -------- About card --------
            Rectangle {
                id: aboutCard
                Layout.fillWidth: true
                implicitHeight: aboutLayout.implicitHeight + 36
                Layout.preferredHeight: implicitHeight
                radius: 10
                color: window.cSurface
                border.color: window.cBorder

                ColumnLayout {
                    id: aboutLayout
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 6

                    Text {
                        text: "⚡ Qplumbum"
                        font.pixelSize: 16
                        font.bold: true
                        color: window.cText
                    }
                    Text {
                        text: qsTr("A modern Qt6 Xray / V2Ray client")
                        font.pixelSize: 12
                        color: window.cTextDim
                    }
                    Text {
                        text: qsTr("Xray / V2Ray protocols: VMess, VLESS, Shadowsocks, Trojan, HTTP, SOCKS")
                        font.pixelSize: 11
                        color: window.cTextDim
                    }
                    Item { Layout.fillHeight: true }
                    Text {
                        text: qsTr("Kernel: xray-core / v2ray-core (v5 config)")
                        font.pixelSize: 11
                        color: window.cTextDim
                    }
                }
            }
        }
    }
}
