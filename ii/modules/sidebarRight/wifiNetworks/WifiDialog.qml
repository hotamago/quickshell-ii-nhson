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
        text: Translation.tr("Connect to Wi-Fi")
    }
    WindowDialogSeparator {
        visible: !Network.wifiScanning
    }
    StyledIndeterminateProgressBar {
        visible: Network.wifiScanning
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large
    }
    ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large

        clip: true
        spacing: 0

        model: ScriptModel {
            values: [...Network.wifiNetworks].sort((a, b) => {
                if (a.active && !b.active)
                    return -1;
                if (!a.active && b.active)
                    return 1;
                return b.strength - a.strength;
            })
        }
        delegate: WifiNetworkItem {
            required property WifiAccessPoint modelData
            wifiNetwork: modelData
            anchors {
                left: parent?.left
                right: parent?.right
            }
        }
    }
    WindowDialogSeparator {}

    // Hidden network section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8

        StyledText {
            text: Translation.tr("Hidden Network")
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
            color: Appearance.colors.colOnSurfaceVariant
        }

        RowLayout {
            spacing: 8

            MaterialTextField {
                id: hiddenNetworkField
                Layout.fillWidth: true
                placeholderText: Translation.tr("Network name (SSID)")
                onAccepted: hiddenPasswordField.forceActiveFocus()
            }

            MaterialTextField {
                id: hiddenPasswordField
                Layout.preferredWidth: 120
                placeholderText: Translation.tr("Password (optional)")
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData
                onAccepted: connectToHiddenNetwork()
            }

            DialogButton {
                buttonText: Translation.tr("Connect")
                enabled: hiddenNetworkField.text.length > 0
                onClicked: connectToHiddenNetwork()
            }
        }
    }

    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: Translation.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: Translation.tr("Done")
            onClicked: root.dismiss()
        }
    }

    function connectToHiddenNetwork() {
        if (hiddenNetworkField.text.length === 0) return;

        const ssid = hiddenNetworkField.text.trim();
        const password = hiddenPasswordField.text;

        // Use the dedicated hidden network connection function
        Network.connectToHiddenWifiNetwork(ssid, password);

        // Clear the fields
        hiddenNetworkField.text = "";
        hiddenPasswordField.text = "";
    }
}