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

    property bool isConnecting: false

    // Monitor the connection state with a timer
    Timer {
        id: connectionCheckTimer
        interval: 500
        repeat: true
        running: false
        
        onTriggered: {
            console.log("[HiddenNetworkDialog] isConnecting:", root.isConnecting, "Network.hiddenWifiConnecting:", Network.hiddenWifiConnecting);
            if (root.isConnecting && !Network.hiddenWifiConnecting) {
                // Connection attempt finished
                console.log("[HiddenNetworkDialog] Connection attempt finished, dismissing dialog");
                connectionCheckTimer.stop();
                root.isConnecting = false;
                networkNameField.text = "";
                passwordField.text = "";
                // Delay dismissal to ensure notifications are sent
                dismissTimer.start();
            }
        }
    }
    
    Timer {
        id: dismissTimer
        interval: 500
        running: false
        onTriggered: {
            root.dismiss();
        }
    }

    WindowDialogTitle {
        text: Translation.tr("Connect to Hidden Network")
    }

    WindowDialogSeparator {
        visible: !root.isConnecting
    }

    StyledIndeterminateProgressBar {
        visible: root.isConnecting
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        MaterialTextField {
            id: networkNameField
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            placeholderText: Translation.tr("Network name (SSID)")
            enabled: !root.isConnecting
            onAccepted: passwordField.forceActiveFocus()
        }

        MaterialTextField {
            id: passwordField
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            placeholderText: Translation.tr("Password (optional)")
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData
            enabled: !root.isConnecting
            onAccepted: {
                if (!root.isConnecting && networkNameField.text.length > 0) {
                    connectToHiddenNetwork();
                }
            }
        }
    }

    WindowDialogSeparator {}

    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Cancel")
            enabled: !root.isConnecting
            onClicked: root.dismiss()
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: root.isConnecting ? Translation.tr("Connecting...") : Translation.tr("Connect")
            enabled: networkNameField.text.length > 0 && !root.isConnecting
            onClicked: {
                if (networkNameField.text.length === 0) return;

                const ssid = networkNameField.text.trim();
                const password = passwordField.text;

                console.log("[HiddenNetworkDialog] Attempting to connect to:", ssid);

                // Mark as connecting and start monitoring
                root.isConnecting = true;
                connectionCheckTimer.start();

                // Use the dedicated hidden network connection function
                Network.connectToHiddenWifiNetwork(ssid, password);
            }
        }
    }

    function connectToHiddenNetwork() {
        if (networkNameField.text.length === 0 || root.isConnecting) return;

        const ssid = networkNameField.text.trim();
        const password = passwordField.text;

        root.isConnecting = true;
        connectionCheckTimer.start();
        Network.connectToHiddenWifiNetwork(ssid, password);
    }
}
