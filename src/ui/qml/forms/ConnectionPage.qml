import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "components"

// Main connections page
Rectangle {
    id: root
    color: "transparent"

    // Keep dialogs as dense as the rest of the application.
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
    component CompactCheckBox: CheckBox {
        implicitHeight: 36
    }
    component CompactButton: Button {
        implicitHeight: 36
        padding: 10
    }
    component RoundedDialog: Dialog {
        background: Rectangle {
            radius: 16
            color: window.cSurface
            border.color: window.cBorder
            border.width: 1
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // -------- Toolbar section --------
        SectionCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Text {
                    text: qsTr("Connections")
                    font.pixelSize: 17
                    font.bold: true
                    color: window.cText
                }

                Item { Layout.fillWidth: true }

                // Group selector
                ComboBox {
                    id: groupSelector
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 36
                    model: plumbum.groupModel
                    textRole: "displayName"
                    currentIndex: groupModelIndexFor(plumbum.currentGroupId)

                    function groupModelIndexFor(gid: string): int {
                        for (var i = 0; i < plumbum.groupModel.rowCount(); i++) {
                            if (plumbum.groupModel.data(plumbum.groupModel.index(i, 0), 0x0101) === gid)
                                return i
                        }
                        return 0
                    }

                    onActivated: function(index) {
                        plumbum.currentGroupId = plumbum.groupModel.data(plumbum.groupModel.index(index, 0), 0x0101)
                    }

                    Component.onCompleted: {
                        plumbum.currentGroupId = plumbum.groupModel.data(plumbum.groupModel.index(currentIndex, 0), 0x0101)
                    }
                }

                FlatButton {
                    text: qsTr("New Group")
                    onClicked: newGroupDialog.open()
                }

                FlatButton {
                    text: qsTr("New Connection")
                    active: true
                    onClicked: newConnectionDialog.open()
                }

                FlatButton {
                    text: qsTr("Import")
                    onClicked: {
                        importDialog.openLinkTab = false
                        importDialog.open()
                    }
                }

                FlatButton {
                    text: qsTr("Import URL")
                    onClicked: {
                        importDialog.openLinkTab = true
                        importDialog.open()
                    }
                }

                FlatButton {
                    text: qsTr("Latency Test")
                    onClicked: plumbum.startLatencyTest()
                }

                FlatButton {
                    visible: isCurrentGroupSubscription
                    text: qsTr("Update Subscription")
                    onClicked: plumbum.updateSubscription(plumbum.currentGroupId)
                }
            }
        }

        // -------- Connection list section --------
        SectionCard {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: connList
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                clip: true
                model: plumbum.connectionModel

                delegate: ConnectionCard {
                    width: connList.width
                    connId: model.connectionId
                    displayName: model.displayName
                    protocol: model.protocol
                    address: model.address
                    port: model.port
                    latencyText: model.latencyText
                    // Use the single connection state exposed by the property
                    // bridge so the card and the top status bar cannot diverge.
                    isConnected: plumbum.connected && plumbum.connectedConnectionId === model.connectionId
                    upTotal: model.upTotal
                    downTotal: model.downTotal

                    onConnectRequested: function(id) { plumbum.connectConnection(id) }
                    onDisconnectRequested: function(id) { plumbum.disconnectConnection() }
                    onEditRequested: function(id) {
                        editDialog.connectionId = id
                        editDialog.open()
                    }
                    onCopyLinkRequested: function(id) { plumbum.copyConnectionLink(id) }
                    onLatencyRequested: function(id) { plumbum.startLatencyTestFor(id) }
                    onDeleteRequested: function(id) {
                        deleteConfirm.message = qsTr("Delete connection \"%1\"?").arg(plumbum.connectionDisplayName(id))
                        deleteConfirm.connToDelete = id
                        deleteConfirm.open()
                    }
                }

                // Empty state
                Rectangle {
                    anchors.centerIn: parent
                    visible: connList.count === 0
                    width: parent.width - 40
                    height: 160
                    color: "transparent"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "📭"
                            font.pixelSize: 40
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: qsTr("No connections in this group")
                            font.pixelSize: 13
                            color: window.cTextDim
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: qsTr("Click \"Import URL\" to add a server link, or \"New Connection\" to configure one")
                            font.pixelSize: 11
                            color: window.cTextDim
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    readonly property bool isCurrentGroupSubscription: {
        for (var i = 0; i < plumbum.groupModel.rowCount(); i++) {
            if (plumbum.groupModel.data(plumbum.groupModel.index(i, 0), 0x0101) === plumbum.currentGroupId)
                return plumbum.groupModel.data(plumbum.groupModel.index(i, 0), 0x0103)
        }
        return false
    }

    RoundedDialog {
        id: editDialog
        property string connectionId: ""
        title: qsTr("Edit connection JSON")
        anchors.centerIn: parent
        width: Math.min(parent.width - 32, 760)
        height: Math.min(parent.height - 32, 620)
        modal: true
        standardButtons: Dialog.NoButton

        footer: RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Item { Layout.fillWidth: true }
            CompactButton {
                text: qsTr("Cancel")
                Layout.bottomMargin: 8
                onClicked: editDialog.close()
            }
            CompactButton {
                text: qsTr("Save")
                Layout.rightMargin: 8
                Layout.bottomMargin: 8
                onClicked: {
                    if (plumbum.updateConnectionJson(editDialog.connectionId, editJsonText.text))
                        editDialog.close()
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            Text {
                text: qsTr("Advanced editor: changes are validated as JSON before saving.")
                color: window.cTextDim
                font.pixelSize: 11
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextArea {
                    id: editJsonText
                    selectByMouse: true
                    wrapMode: TextEdit.NoWrap
                    font.family: "monospace"
                }
            }
        }

        onOpened: editJsonText.text = plumbum.connectionJson(connectionId)
    }

    // -------- New connection editor --------
    RoundedDialog {
        id: newConnectionDialog
        title: qsTr("New Connection")
        anchors.centerIn: parent
        width: Math.min(parent.width - 32, 620)
        height: Math.min(parent.height - 32, 620)
        modal: true
        standardButtons: Dialog.NoButton

        property bool isUuidProtocol: protocolSelector.currentText === "VMess" || protocolSelector.currentText === "VLESS"
        property bool isShadowsocks: protocolSelector.currentText === "Shadowsocks"
        property bool isVless: protocolSelector.currentText === "VLESS"

        footer: RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Item { Layout.fillWidth: true }
            CompactButton {
                text: qsTr("Cancel")
                Layout.bottomMargin: 8
                onClicked: newConnectionDialog.close()
            }
            CompactButton {
                text: qsTr("Create")
                Layout.rightMargin: 8
                Layout.bottomMargin: 8
                highlighted: true
                onClicked: {
                    if (plumbum.createConnection(connectionName.text,
                                                  protocolSelector.currentText,
                                                  serverAddress.text,
                                                  Number(serverPort.text),
                                                  credential.text,
                                                  newConnectionDialog.isShadowsocks ? ssMethod.currentText
                                                                                     : (newConnectionDialog.isVless ? vlessFlow.currentText : vmessSecurity.currentText),
                                                  transportSelector.currentText,
                                                  tlsEnabled.checked,
                                                  serverName.text,
                                                  transportPath.text))
                        newConnectionDialog.close()
                }
            }
        }

        contentItem: ScrollView {
            id: newConnectionScroll
            property int scrollGutter: 12
            clip: true
            contentWidth: Math.max(0, availableWidth - scrollGutter)
            contentHeight: newConnectionForm.implicitHeight + 8
            background: Rectangle {
                x: 0
                y: 0
                width: Math.max(0, newConnectionScroll.width - newConnectionScroll.scrollGutter)
                height: newConnectionScroll.height
                radius: 12
                color: window.cSurface
                border.color: window.cBorder
                border.width: 1
                clip: true
            }
            ScrollBar.vertical: ScrollBar {
                id: newConnectionScrollBar
                policy: ScrollBar.AsNeeded
                width: 8
                anchors.right: newConnectionScroll.right
                anchors.top: newConnectionScroll.top
                anchors.bottom: newConnectionScroll.bottom
                z: 2
            }

            ColumnLayout {
                id: newConnectionForm
                x: 8
                width: Math.max(0, newConnectionScroll.availableWidth - 16 - newConnectionScroll.scrollGutter)
                spacing: 8

            Text {
                text: qsTr("Basic connection settings")
                font.pixelSize: 12
                font.bold: true
                color: window.cText
                Layout.fillWidth: true
            }

            GridLayout {
                columns: 2
                columnSpacing: 12
                rowSpacing: 8
                Layout.fillWidth: true

                Text { text: qsTr("Name"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactTextField {
                    id: connectionName
                    Layout.fillWidth: true
                    placeholderText: qsTr("Optional display name")
                }

                Text { text: qsTr("Protocol"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactComboBox {
                    id: protocolSelector
                    Layout.fillWidth: true
                    model: ["VMess", "VLESS", "Shadowsocks", "Trojan"]
                    onCurrentTextChanged: {
                        if (currentText === "Trojan")
                            tlsEnabled.checked = true
                    }
                }

                Text { text: qsTr("Host"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactTextField {
                    id: serverAddress
                    Layout.fillWidth: true
                    placeholderText: qsTr("Hostname or IP address")
                }

                Text { text: qsTr("Port"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactTextField {
                    id: serverPort
                    Layout.fillWidth: true
                    text: "443"
                    validator: IntValidator { bottom: 1; top: 65535 }
                    inputMethodHints: Qt.ImhDigitsOnly
                }

                Text {
                    text: newConnectionDialog.isUuidProtocol ? qsTr("UUID") : qsTr("Password")
                    color: window.cTextDim
                    verticalAlignment: Text.AlignVCenter
                }
                CompactTextField {
                    id: credential
                    Layout.fillWidth: true
                    echoMode: newConnectionDialog.isUuidProtocol || newConnectionDialog.isShadowsocks ? TextInput.Normal : TextInput.Password
                    placeholderText: newConnectionDialog.isUuidProtocol ? "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" : qsTr("Server password")
                }

                Text {
                    visible: newConnectionDialog.isShadowsocks
                    text: qsTr("Encryption")
                    color: window.cTextDim
                    verticalAlignment: Text.AlignVCenter
                }
                CompactComboBox {
                    id: ssMethod
                    visible: newConnectionDialog.isShadowsocks
                    Layout.fillWidth: true
                    model: ["aes-256-gcm", "aes-128-gcm", "chacha20-ietf-poly1305"]
                }

                Text {
                    visible: protocolSelector.currentText === "VMess"
                    text: qsTr("Security")
                    color: window.cTextDim
                    verticalAlignment: Text.AlignVCenter
                }
                CompactComboBox {
                    id: vmessSecurity
                    visible: protocolSelector.currentText === "VMess"
                    Layout.fillWidth: true
                    model: ["auto", "aes-128-gcm", "chacha20-poly1305", "none"]
                }

                Text {
                    visible: newConnectionDialog.isVless
                    text: qsTr("Flow")
                    color: window.cTextDim
                    verticalAlignment: Text.AlignVCenter
                }
                CompactComboBox {
                    id: vlessFlow
                    visible: newConnectionDialog.isVless
                    Layout.fillWidth: true
                    model: ["", "xtls-rprx-splice", "xtls-rprx-direct", "xtls-rprx-vision"]
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: window.cBorder }

            Text {
                text: qsTr("Transport settings")
                font.pixelSize: 12
                font.bold: true
                color: window.cText
                Layout.fillWidth: true
            }

            GridLayout {
                columns: 2
                columnSpacing: 12
                rowSpacing: 8
                Layout.fillWidth: true

                Text { text: qsTr("Transport"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactComboBox {
                    id: transportSelector
                    Layout.fillWidth: true
                    model: ["tcp", "ws", "grpc"]
                }

                Text { text: qsTr("TLS"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactCheckBox { id: tlsEnabled; text: qsTr("Enable TLS") }

                Text { text: qsTr("SNI / Host header"); color: window.cTextDim; verticalAlignment: Text.AlignVCenter }
                CompactTextField {
                    id: serverName
                    Layout.fillWidth: true
                    placeholderText: qsTr("Optional server name")
                }

                Text {
                    visible: transportSelector.currentText !== "tcp"
                    text: transportSelector.currentText === "grpc" ? qsTr("Service name") : qsTr("Path")
                    color: window.cTextDim
                    verticalAlignment: Text.AlignVCenter
                }
                CompactTextField {
                    id: transportPath
                    visible: transportSelector.currentText !== "tcp"
                    Layout.fillWidth: true
                    text: transportSelector.currentText === "ws" ? "/" : ""
                    placeholderText: transportSelector.currentText === "grpc" ? qsTr("Optional gRPC service") : "/"
                }
            }

            Text {
                text: qsTr("You can fine-tune the generated JSON after creation from the connection menu.")
                color: window.cTextDim
                font.pixelSize: 11
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                Layout.bottomMargin: 8
            }
            }
        }

        onOpened: {
            connectionName.text = ""
            protocolSelector.currentIndex = 0
            serverAddress.text = ""
            serverPort.text = "443"
            credential.text = ""
            transportSelector.currentIndex = 0
            tlsEnabled.checked = false
            serverName.text = ""
            transportPath.text = "/"
        }
    }

    // -------- Qv2ray-style import dialog --------
    RoundedDialog {
        id: importDialog
        property bool openLinkTab: true
        title: qsTr("Import Connection")
        anchors.centerIn: parent
        width: Math.min(parent.width - 32, 620)
        height: Math.min(parent.height - 32, 500)
        modal: true
        standardButtons: Dialog.NoButton

        contentItem: ColumnLayout {
            anchors.margins: 8
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: qsTr("Name/Prefix")
                    color: window.cTextDim
                }
                CompactTextField {
                    id: importPrefix
                    Layout.fillWidth: true
                    placeholderText: qsTr("A prefix to the imported connection")
                }
            }

            TabBar {
                id: importTabs
                Layout.fillWidth: true
                TabButton { text: qsTr("Link") }
                TabButton { text: qsTr("File") }
            }

            StackLayout {
                id: importPages
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: importTabs.currentIndex

                ColumnLayout {
                    spacing: 8

                    Text {
                        text: qsTr("Share Link")
                        color: window.cTextDim
                    }
                    CompactTextArea {
                        id: importText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: qsTr("Paste share link here, one line for each.")
                        wrapMode: TextEdit.NoWrap
                        selectByMouse: true
                        topPadding: 12
                        bottomPadding: 12
                        leftPadding: 12
                        rightPadding: 12
                        verticalAlignment: TextEdit.AlignTop
                    }
                }

                ColumnLayout {
                    spacing: 8

                    Text {
                        text: qsTr("Configuration File")
                        color: window.cTextDim
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        CompactTextField {
                            id: importFilePath
                            Layout.fillWidth: true
                            placeholderText: qsTr("Select a JSON configuration file")
                            readOnly: true
                        }
                        CompactButton {
                            text: qsTr("Browse")
                            onClicked: configFileDialog.open()
                        }
                    }
                    CompactCheckBox {
                        id: importComplex
                        text: qsTr("Import as complex configuration")
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: 8
                CompactButton {
                    text: qsTr("Cancel")
                    onClicked: importDialog.close()
                }
                CompactButton {
                    text: qsTr("Import")
                    highlighted: true
                    onClicked: {
                        var imported = importTabs.currentIndex === 0
                                       ? plumbum.importFromLink(importText.text)
                                       : plumbum.importFromFile(importFilePath.text, importComplex.checked, importPrefix.text)
                        if (imported)
                            importDialog.close()
                    }
                }
            }
        }

        onOpened: {
            importTabs.currentIndex = openLinkTab ? 0 : 1
            importPrefix.text = ""
            importText.text = ""
            importFilePath.text = ""
            importComplex.checked = false
        }
    }

    FileDialog {
        id: configFileDialog
        title: qsTr("Select a configuration file")
        nameFilters: [qsTr("JSON files (*.json)"), qsTr("All files (*)")]
        onAccepted: importFilePath.text = selectedFile.toString()
    }

    // -------- New group dialog --------
    RoundedDialog {
        id: newGroupDialog
        title: qsTr("Create new group")
        anchors.centerIn: parent
        width: 380
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            CompactTextField {
                id: groupNameInput
                Layout.fillWidth: true
                placeholderText: qsTr("Group name")
            }
        }

        onAccepted: plumbum.createGroup(groupNameInput.text)
        onOpened: groupNameInput.text = ""
    }

    // -------- Delete confirm dialog --------
    RoundedDialog {
        id: deleteConfirm
        property string connToDelete: ""
        property string message: ""
        title: qsTr("Confirm")
        anchors.centerIn: parent
        width: 400
        modal: true
        standardButtons: Dialog.Yes | Dialog.No

        Text {
            anchors.fill: parent
            text: deleteConfirm.message
            wrapMode: Text.Wrap
        }

        onAccepted: plumbum.deleteConnection(deleteConfirm.connToDelete)
    }
}
