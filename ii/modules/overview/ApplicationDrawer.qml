import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root
    property bool expanded: false
    property string searchText: ""
    property string sortMode: "name" // "name", "recent"
    property string filterCategory: "all" // "all", "favorites"
    
    property real collapsedHeight: 200 // Better initial height
    property real availableHeight: 0
    property real availableWidth: 0
    property real expandedHeight: {
        // Use most of available height when expanded, but leave space for top bar
        if (availableHeight > 0) {
            // Use 85% of available height to ensure it doesn't overlap top bar
            // This leaves ~15% for the bar and some breathing room
            return availableHeight * 0.85;
        }
        return 600;
    }
    property int columns: {
        if (availableWidth > 0) {
            // Calculate columns based on available width with proper spacing
            const cellWidth = 90; // Desired cell width including spacing
            return Math.max(6, Math.floor((availableWidth - 60) / cellWidth));
        }
        return Math.max(6, Math.floor((width - 60) / 90));
    }
    property real iconSize: 48
    property real spacing: 15
    
    implicitHeight: root.expanded ? root.expandedHeight : root.collapsedHeight
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.animation.elementResize.duration
            easing.type: Appearance.animation.elementResize.type
            easing.bezierCurve: Appearance.animation.elementResize.bezierCurve
        }
    }
    
    // Filter and sort apps
    function getFilteredApps() {
        const list = AppSearch.list;
        if (!list || list.length === 0) return [];
        
        let apps = Array.from(list);
        
        // Filter by search text
        if (root.searchText.length > 0) {
            const searchLower = root.searchText.toLowerCase();
            apps = apps.filter(app => 
                app.name.toLowerCase().includes(searchLower) ||
                (app.description && app.description.toLowerCase().includes(searchLower))
            );
        }
        
        // Sort
        if (root.sortMode === "name") {
            apps.sort((a, b) => a.name.localeCompare(b.name));
        }
        
        return apps;
    }
    
    StyledRectangularShadow {
        target: drawerBackground
    }
    
    Rectangle {
        id: drawerBackground
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.expanded ? 20 : 15
            spacing: 10
            
            // Header with search and controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                MaterialSymbol {
                    text: "apps"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer0
                }
                
                StyledText {
                    text: root.expanded ? Translation.tr("All Applications") : Translation.tr("Applications")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer0
                }
                
                Item { Layout.fillWidth: true }
                
                MaterialSymbol {
                    text: root.expanded ? "expand_less" : "expand_more"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colSubtext
                }
            }
            
            // Search bar (only visible when expanded)
            TextField {
                id: searchField
                Layout.fillWidth: true
                visible: root.expanded
                Layout.maximumHeight: root.expanded ? implicitHeight : 0
                opacity: root.expanded ? 1 : 0
                focus: root.expanded
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.elementMoveFast.duration
                        easing.type: Appearance.animation.elementMoveFast.type
                        easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                    }
                }
                Behavior on Layout.maximumHeight {
                    NumberAnimation {
                        duration: Appearance.animation.elementResize.duration
                        easing.type: Appearance.animation.elementResize.type
                        easing.bezierCurve: Appearance.animation.elementResize.bezierCurve
                    }
                }
                
                placeholderText: Translation.tr("Search applications...")
                placeholderTextColor: Appearance.m3colors.m3outline
                padding: 10
                
                font {
                    family: Appearance.font.family.main
                    pixelSize: Appearance.font.pixelSize.small
                }
                
                color: Appearance.m3colors.m3onSurface
                selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
                selectionColor: Appearance.colors.colSecondaryContainer
                
                background: Rectangle {
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: searchField.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant
                    
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
                
                cursorDelegate: Rectangle {
                    width: 1
                    color: Appearance.colors.colPrimary
                    radius: 1
                    visible: searchField.activeFocus
                }
                
                onTextChanged: {
                    root.searchText = text;
                }
                
                // Clear button
                MaterialSymbol {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "close"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colSubtext
                    visible: searchField.text.length > 0
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchField.text = "";
                        }
                    }
                }
            }
            
            // App Grid
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: root.expanded ? 100 : 40
                clip: true
                ScrollBar.vertical: StyledScrollBar {}
                
                GridView {
                    id: appGrid
                    anchors.fill: parent
                    cellWidth: Math.max(80, (parent.width - (root.columns - 1) * root.spacing - 30) / root.columns)
                    cellHeight: cellWidth * 1.15
                    interactive: root.expanded || contentHeight > height
                    boundsBehavior: Flickable.StopAtBounds
                    
                    model: ScriptModel {
                        values: root.getFilteredApps()
                    }
                    
                    // Show "no results" message
                    Label {
                        anchors.centerIn: parent
                        visible: appGrid.count === 0 && root.searchText.length > 0
                        text: Translation.tr("No applications found")
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }
                    
                    delegate: RippleButton {
                        id: appButton
                        required property var modelData
                        required property int index
                        property bool keyboardDown: false
                        
                        width: appGrid.cellWidth
                        height: appGrid.cellHeight
                        buttonRadius: Appearance.rounding.normal
                        colBackground: (appButton.down || appButton.keyboardDown) ? 
                            Appearance.colors.colSecondaryContainerActive : 
                            ((appButton.hovered || appButton.focus) ? 
                                Appearance.colors.colSecondaryContainer : 
                                ColorUtils.transparentize(Appearance.colors.colSecondaryContainer, 1))
                        colBackgroundHover: Appearance.colors.colSecondaryContainer
                        colRipple: Appearance.colors.colSecondaryContainerActive
                        
                        PointingHandInteraction {}
                        
                        onClicked: {
                            GlobalStates.overviewOpen = false
                            modelData.execute()
                        }
                        
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                appButton.keyboardDown = true
                                appButton.clicked()
                                event.accepted = true
                            }
                        }
                        
                        Keys.onReleased: (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                appButton.keyboardDown = false
                                event.accepted = true
                            }
                        }
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6
                            
                            IconImage {
                                Layout.alignment: Qt.AlignHCenter
                                source: Quickshell.iconPath(modelData.icon, "image-missing")
                                implicitSize: root.iconSize
                            }
                            
                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.name
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colOnLayer0
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                            }
                        }
                        
                        StyledToolTip {
                            text: modelData.name + (modelData.description ? "\n" + modelData.description : "")
                        }
                    }
                }
            }
        }
    }
}
