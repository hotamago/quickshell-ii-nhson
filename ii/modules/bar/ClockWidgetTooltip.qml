import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

StyledPopup {
    id: root
    property string formattedDate: Qt.locale().toString(DateTime.clock.date, "dddd, MMMM dd, yyyy")
    property string formattedTime: DateTime.time
    property string formattedUptime: DateTime.uptime
    property string todosSection: getUpcomingTodos()
    property var currentDate: new Date()

    function getUpcomingTodos() {
        const unfinishedTodos = Todo.list.filter(function (item) {
            return !item.done;
        });
        if (unfinishedTodos.length === 0) {
            return Translation.tr("No pending tasks");
        }

        // Limit to first 5 todos to keep popup manageable
        const limitedTodos = unfinishedTodos.slice(0, 5);
        let todoText = limitedTodos.map(function (item, index) {
            return `${index + 1}. ${item.content}`;
        }).join('\n');

        if (unfinishedTodos.length > 5) {
            todoText += `\n${Translation.tr("... and %1 more").arg(unfinishedTodos.length - 5)}`;
        }

        return todoText;
    }

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 12

        // Header with current date and time
        RowLayout {
            spacing: 12
            Layout.fillWidth: true

            Column {
                spacing: 2
                Layout.fillWidth: true

                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                    text: Qt.formatDateTime(root.currentDate, "dddd")
                }

                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnSurfaceVariant
                    text: Qt.formatDateTime(root.currentDate, "MMMM yyyy")
                }
            }

            Column {
                spacing: 2
                Layout.alignment: Qt.AlignRight

                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnSurface
                    text: Qt.formatDateTime(root.currentDate, "dd")
                }

                StyledText {
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnSurfaceVariant
                    text: Qt.formatDateTime(root.currentDate, "yyyy")
                }
            }
        }

        // Mini calendar
        GridLayout {
            columns: 7
            rowSpacing: 2
            columnSpacing: 2
            Layout.fillWidth: true

            // Day headers
            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: StyledText {
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnSurfaceVariant
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 24
                }
            }

            // Calendar days
            Repeater {
                model: {
                    const today = new Date();
                    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
                    const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                    const startDate = new Date(firstDay);
                    startDate.setDate(startDate.getDate() - firstDay.getDay());

                    const days = [];
                    const current = new Date(startDate);
                    while (current <= lastDay || days.length % 7 !== 0) {
                        days.push({
                            date: new Date(current),
                            isCurrentMonth: current.getMonth() === today.getMonth(),
                            isToday: current.toDateString() === today.toDateString()
                        });
                        current.setDate(current.getDate() + 1);
                    }
                    return days;
                }

                delegate: Rectangle {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    radius: 4
                    color: modelData.isToday ? Appearance.colors.colPrimaryContainer :
                           modelData.isCurrentMonth ? "transparent" :
                           Appearance.colors.colSurfaceVariant

                    StyledText {
                        anchors.centerIn: parent
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: modelData.isToday ? Appearance.colors.colOnPrimaryContainer :
                               modelData.isCurrentMonth ? Appearance.colors.colOnSurface :
                               Appearance.colors.colOnSurfaceVariant
                        text: modelData.date.getDate()
                        font.weight: modelData.isToday ? Font.Bold : Font.Normal
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }

        // System information
        Column {
            spacing: 8
            Layout.fillWidth: true

            // Uptime
            RowLayout {
                spacing: 8
                Layout.fillWidth: true
                MaterialSymbol {
                    text: "timelapse"
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    text: Translation.tr("Uptime:")
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.small
                }
                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    color: Appearance.colors.colOnSurface
                    text: root.formattedUptime
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }

            // Weather (if available)
            RowLayout {
                visible: Weather.currentWeather?.temperature !== undefined
                spacing: 8
                Layout.fillWidth: true
                MaterialSymbol {
                    text: "thermostat"
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    text: Translation.tr("Weather:")
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.small
                }
                StyledText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    color: Appearance.colors.colOnSurface
                    text: Weather.currentWeather ? `${Weather.currentWeather.temperature}°C, ${Weather.currentWeather.description}` : ""
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }

        // Tasks section
        Column {
            spacing: 4
            Layout.fillWidth: true

            Row {
                spacing: 8
                MaterialSymbol {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "checklist"
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Translation.tr("Tasks:")
                    color: Appearance.colors.colOnSurfaceVariant
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }

            StyledText {
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.Wrap
                color: Appearance.colors.colOnSurface
                text: root.todosSection
                font.pixelSize: Appearance.font.pixelSize.small
                maximumLineCount: 6
                elide: Text.ElideRight
            }
        }
    }
}
