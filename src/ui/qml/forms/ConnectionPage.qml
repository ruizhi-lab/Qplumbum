import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

// Main connections page
Rectangle {
    id: root
    color: "transparent"

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
                    text: qsTr("Import")
                    active: true
                    onClicked: plumbum.importFromClipboard()
                }

                FlatButton {
                    text: qsTr("Import URL")
                    onClicked: importDialog.open()
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
                            text: qsTr("Click \"Import\" to add a server link (vmess://, vless://, ss://, trojan:// ...)")
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


    Dialog {
        id: editDialog
        property string connectionId: ""
        title: qsTr("Edit connection JSON")
        anchors.centerIn: parent
        width: Math.min(parent.width - 32, 760)
        height: Math.min(parent.height - 32, 620)
        modal: true
        standardButtons: Dialog.NoButton

        footer: RowLayout {
            spacing: 8
            Button {
                text: qsTr("Cancel")
                onClicked: editDialog.close()
            }
            Button {
                text: qsTr("Save")
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

    // -------- Import URL dialog --------
    Dialog {
        id: importDialog
        title: qsTr("Import from link")
        anchors.centerIn: parent
        width: 520
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            Text {
                text: qsTr("Paste one or more share links below:")
                font.pixelSize: 12
                color: window.cTextDim
            }
            TextArea {
                id: importText
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                placeholderText: "vmess://...\nvless://...\nss://...\ntrojan://..."
                wrapMode: TextEdit.Wrap
            }
        }

        onAccepted: plumbum.importFromLink(importText.text)
        onOpened: importText.text = ""
    }

    // -------- New group dialog --------
    Dialog {
        id: newGroupDialog
        title: qsTr("Create new group")
        anchors.centerIn: parent
        width: 380
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            anchors.fill: parent
            spacing: 8

            TextField {
                id: groupNameInput
                Layout.fillWidth: true
                placeholderText: qsTr("Group name")
            }
        }

        onAccepted: plumbum.createGroup(groupNameInput.text)
        onOpened: groupNameInput.text = ""
    }

    // -------- Delete confirm dialog --------
    Dialog {
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
