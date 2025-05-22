import QtQuick
import QtQuick.Controls

Slider {
    id: control

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 4
        radius: 2
        color: Style.borderColor

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Style.primaryColor
            radius: 2
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 20
        height: 20
        radius: 10
        color: control.pressed ? Qt.darker(Style.primaryColor,
                                           1.2) : Style.primaryColor
        border.color: Qt.darker(Style.primaryColor, 1.2)
    }
}
