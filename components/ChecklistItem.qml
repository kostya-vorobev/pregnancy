// components/ChecklistItem.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

CheckBox {
    id: root

    // Публичные свойства
    property color indicatorColor: "#ba68c8"
    property color textColor: "#4a148c"
    property color backgroundColor: "white"
    property int borderRadius: 8

    // Стилизация
    padding: 12
    spacing: 15
    font.pixelSize: 16

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: 5
        border.color: root.down ? "#9c27b0" : "#9c27b0"
        border.width: 2

        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            radius: 3
            color: root.checked ? root.indicatorColor : "transparent"
            visible: root.checked
        }
    }

    contentItem: Text {
        text: root.text
        font: root.font
        color: root.textColor
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator.width + root.spacing
        wrapMode: Text.WordWrap
    }

    background: Rectangle {
        color: root.backgroundColor
        radius: root.borderRadius
    }
}
