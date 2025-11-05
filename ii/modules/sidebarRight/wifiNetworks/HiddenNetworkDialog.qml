import qs
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

WindowDialog {
    id: root

    WindowDialogTitle {
        text: Translation.tr("Connect to Hidden Network")
    }

    WindowDialogSeparator {}

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        MaterialTextField {
            id: networkNameField
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            placeholderText: Translation.tr("Network name (SSID)")
            onAccepted: passwordField.forceActiveFocus()
        }

        MaterialTextField {
            id: passwordField
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            placeholderText: Translation.tr("Password (optional)")
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData
            onAccepted: connectToHiddenNetwork()
        }
    }

    WindowDialogSeparator {}

    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Cancel")
            onClicked: root.dismiss()
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: Translation.tr("Connect")
            enabled: networkNameField.text.length > 0
            onClicked: connectToHiddenNetwork()
        }
    }

    function connectToHiddenNetwork() {
        if (networkNameField.text.length === 0) return;

        const ssid = networkNameField.text.trim();
        const password = passwordField.text;

        // Use the dedicated hidden network connection function
        Network.connectToHiddenWifiNetwork(ssid, password);

        // Clear the fields and close dialog
        networkNameField.text = "";
        passwordField.text = "";
        root.dismiss();
    }
}
