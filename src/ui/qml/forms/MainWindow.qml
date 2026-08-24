import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: window
    width: 1100
    height: 720
    minimumWidth: 860
    minimumHeight: 560
    visible: true
    title: qsTr("Qplumbum - Xray/V2Ray Client")

    // Hide to tray instead of quitting on close.
    onClosing: {
        close.accepted = false
        window.hide()
    }

    // -------- Theme (light/dark/system) --------
    readonly property bool isDark: plumbum.themeMode === 2 || (plumbum.themeMode === 0 && plumbum.systemDark)
    readonly property int currentTheme: isDark ? 2 : 1

    // Modern palette
    readonly property color cBackground: isDark ? "#0f1115" : "#f2f4f8"
    readonly property color cSurface: isDark ? "#161a22" : "#ffffff"
    readonly property color cSurfaceAlt: isDark ? "#1c212c" : "#e9edf3"
    readonly property color cBorder: isDark ? "#262d3b" : "#d7dce5"
    readonly property color cPrimary: "#5b8cff"
    readonly property color cPrimaryAlt: isDark ? "#7aa2ff" : "#4a7dff"
    readonly property color cText: isDark ? "#dbe2f0" : "#1a2332"
    readonly property color cTextDim: isDark ? "#7f8ba3" : "#67738a"
    readonly property color cGreen: "#3ddc97"
    readonly property color cRed: "#ff6b6b"
    readonly property color cOrange: "#ffb86c"
    readonly property color cAccent: "#bd93f9"

    Material.theme: isDark ? Material.Dark : Material.Light
    Material.accent: cPrimary
    Material.background: cBackground
    Material.foreground: cText

    background: Rectangle {
        color: cBackground
    }

    // ============================= Layout =============================
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // -------- Sidebar --------
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 210
            color: cSurface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0

                // Logo & Title
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 84
                    color: "transparent"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Image {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            source: "qrc:/assets/icons/plumbum.png"
                            sourceSize.width: 36
                            sourceSize.height: 36
                            antialiasing: true
                        }

                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: "Qplumbum"
                                font.pixelSize: 18
                                font.bold: true
                                color: cText
                            }
                            Text {
                                text: "Xray / V2Ray Client"
                                font.pixelSize: 10
                                color: cTextDim
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: cBorder
                }

                // Navigation
                SideBarButton {
                    id: navConnections
                    Layout.topMargin: 8
                    buttonText: qsTr("Connections")
                    buttonIcon: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23000000'><path d='M0 0h24v24H0z' fill='none'/><path d='M15.5 15.5a4.5 4.5 0 0 1-4.06 2.99 4.5 4.5 0 0 1-4.4-5.44 4.5 4.5 0 0 1 2.4-2.93V6.5a1.5 1.5 0 0 1 3 0v3.62a4.5 4.5 0 0 1 3.06 5.38zM4 6h2a1 1 0 0 1 0 2H4a1 1 0 0 1 0-2zm0-3h8a1 1 0 0 1 0 2H4a1 1 0 0 1 0-2zm13 9h3a1 1 0 0 1 0 2h-3a1 1 0 0 1 0-2zm-1-6a1 1 0 0 1 0 2h-2V7a3 3 0 0 1 3-3h1a1 1 0 0 1 0 2z'/></svg>"
                    isActive: stackView.currentIndex === 0
                    onClicked: stackView.currentIndex = 0
                }
                SideBarButton {
                    id: navSubscriptions
                    buttonText: qsTr("Subscriptions")
                    buttonIcon: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23000000'><path d='M0 0h24v24H0z' fill='none'/><path d='M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm4.2 14.2L11 13.3V7h1.5v5.4l4.5 2.5-0.8 1.3z'/></svg>"
                    isActive: stackView.currentIndex === 1
                    onClicked: stackView.currentIndex = 1
                }
                SideBarButton {
                    id: navSettings
                    buttonText: qsTr("Settings")
                    buttonIcon: "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23000000'><path d='M0 0h24v24H0z' fill='none'/><path d='M19.14 12.94a7.5 7.5 0 0 0 .05-.94 7.5 7.5 0 0 0-.05-.94l2.03-1.58a.5.5 0 0 0 .12-.64l-1.92-3.32a.5.5 0 0 0-.61-.22l-2.39.96a7.02 7.02 0 0 0-1.62-.94l-.36-2.54a.5.5 0 0 0-.5-.42h-3.84a.5.5 0 0 0-.5.42l-.36 2.54c-.59.24-1.13.56-1.62.94l-2.39-.96a.5.5 0 0 0-.61.22L2.56 8.84a.5.5 0 0 0 .12.64l2.03 1.58a7.5 7.5 0 0 0 0 1.88l-2.03 1.58a.5.5 0 0 0-.12.64l1.92 3.32a.5.5 0 0 0 .61.22l2.39-.96c.49.38 1.03.7 1.62.94l.36 2.54a.5.5 0 0 0 .5.42h3.84a.5.5 0 0 0 .5-.42l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96a.5.5 0 0 0 .61-.22l1.92-3.32a.5.5 0 0 0-.12-.64l-2.03-1.58zM12 15.5A3.5 3.5 0 1 1 12 8.5a3.5 3.5 0 0 1 0 7z'/></svg>"
                    isActive: stackView.currentIndex === 2
                    onClicked: stackView.currentIndex = 2
                }

                Item { Layout.fillHeight: true }

                // Connection status indicator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 12
                    Layout.preferredHeight: 48
                    radius: 10
                    color: cSurfaceAlt
                    border.color: cBorder

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Rectangle {
                            id: statusDot
                            width: 10
                            height: 10
                            radius: 5
                            color: plumbum.connected ? cGreen : cTextDim
                            Behavior on color { ColorAnimation { duration: 200 } }

                            // Pulse animation when connected
                            SequentialAnimation {
                                running: plumbum.connected
                                loops: Animation.Infinite
                                NumberAnimation { target: statusDot; property: "opacity"; from: 1; to: 0.4; duration: 900 }
                                NumberAnimation { target: statusDot; property: "opacity"; from: 0.4; to: 1; duration: 900 }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: plumbum.connected
                                      ? qsTr("Connected")
                                      : qsTr("Disconnected")
                                color: plumbum.connected ? cGreen : cTextDim
                                font.pixelSize: 11
                                font.bold: plumbum.connected
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: plumbum.connected
                                text: plumbum.connectedName
                                color: cTextDim
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Version
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                    text: "v" + plumbum.versionString + " · Qt6"
                    font.pixelSize: 10
                    color: cTextDim
                }
            }
        }

        // -------- Content --------
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // This pane is the single shared rounded surface for all pages.
            color: cBackground
            radius: 12
            border.color: cBorder
            border.width: 1
            clip: true

            // Top status bar
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                TopStatusBar {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: cBorder
                }

                StackLayout {
                    id: stackView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: 0

                    ConnectionPage {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    SubscriptionPage {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    SettingsPage {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    // Toast notifications (modern with shadow)
    Rectangle {
        id: toast
        visible: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        width: toastText.implicitWidth + 56
        height: 44
        radius: 22
        color: window.isDark ? Qt.rgba(0.12, 0.14, 0.20, 0.95) : Qt.rgba(0.12, 0.14, 0.20, 0.92)
        z: 100
        Text {
            id: toastText
            anchors.centerIn: parent
            color: "#f0f4ff"
            font.pixelSize: 13
        }

        NumberAnimation on opacity {
            from: 0
            to: 1
            duration: 150
        }

        SequentialAnimation {
            id: toastAnim
            running: false
            NumberAnimation { target: toast; property: "opacity"; to: 1; duration: 120 }
            PauseAnimation { duration: 2200 }
            NumberAnimation { target: toast; property: "opacity"; to: 0; duration: 400 }
            PropertyAction { target: toast; property: "visible"; value: false }
        }

        function show(msg: string) {
            toastText.text = msg
            toast.visible = true
            toast.opacity = 1
            toastAnim.restart()
        }
    }

    Connections {
        target: plumbum
        function onToastMessage(message: string) { toast.show(message) }
    }
}
