import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs.services.network
import QtQuick
import QtQuick.Layouts

DialogListItem {
    id: root

    onClicked: {
        // Find the WifiDialog and emit the signal
        var parentItem = parent;
        while (parentItem && !parentItem.openHiddenNetworkDialog) {
            parentItem = parentItem.parent;
        }
        if (parentItem && parentItem.openHiddenNetworkDialog) {
            parentItem.openHiddenNetworkDialog();
        }
    }

    contentItem: ColumnLayout {
        anchors {
            fill: parent
            topMargin: root.verticalPadding
            bottomMargin: root.verticalPadding
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }
        spacing: 0

        RowLayout {
            // Name
            spacing: 10
            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.larger
                text: "visibility_off"
                color: Appearance.colors.colOnSurfaceVariant
            }
            StyledText {
                Layout.fillWidth: true
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
                text: Translation.tr("Hidden Network")
                font.weight: Font.Medium
            }
            MaterialSymbol {
                text: "chevron_right"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
