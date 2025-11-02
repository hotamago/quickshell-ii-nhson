import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick

GroupButton {
    id: button
    property string buttonIcon
    property bool activated: false
    property bool danger: false
    property int iconSize: Appearance.font.pixelSize.small
    toggled: activated
    baseWidth: height
    colBackgroundHover: danger ? Appearance.colors.colErrorContainer :
                        activated ? Appearance.colors.colPrimaryContainer :
                        Appearance.colors.colSecondaryContainerHover
    colBackgroundActive: danger ? Appearance.colors.colError :
                         activated ? Appearance.colors.colPrimary :
                         Appearance.colors.colSecondaryContainerActive

    contentItem: MaterialSymbol {
        horizontalAlignment: Text.AlignHCenter
        iconSize: button.iconSize
        text: buttonIcon
        color: button.activated ? (danger ? Appearance.colors.colOnError :
                                         Appearance.m3colors.m3onPrimary) :
            button.enabled ? (danger ? Appearance.colors.colError :
                                     Appearance.m3colors.m3onSurface) :
            Appearance.colors.colOnLayer1Inactive

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
