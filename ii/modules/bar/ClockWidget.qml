import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    property bool showSeconds: Config.options.bar?.showSeconds ?? false
    property bool use24Hour: Config.options.bar?.use24Hour ?? true
    property string timeFormat: root.use24Hour ? "HH:mm" + (root.showSeconds ? ":ss" : "") : "hh:mm" + (root.showSeconds ? ":ss" : "") + " AP"
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    Timer {
        id: secondTimer
        interval: root.showSeconds ? 1000 : 60000
        running: true
        repeat: true
        onTriggered: timeText.updateTime()
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 6

        StyledText {
            id: timeText
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer1
            text: Qt.formatDateTime(new Date(), root.timeFormat)

            function updateTime() {
                text = Qt.formatDateTime(new Date(), root.timeFormat)
            }

            Component.onCompleted: {
                updateTime()
            }
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium
            color: Appearance.colors.colOnLayer1
            text: DateTime.date
        }

        // Day of week indicator
        MaterialSymbol {
            visible: Config.options.bar?.showDayOfWeek ?? false
            text: {
                const day = new Date().getDay()
                const days = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
                return days[day] || "calendar_today"
            }
            iconSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            opacity: 0.8
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        ClockWidgetTooltip {
            hoverTarget: mouseArea
        }
    }
}
