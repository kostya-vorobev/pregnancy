// components/ChecklistSection.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root

    // Публичные свойства
    property string title: ""
    property color titleColor: "#4a148c"
    property color backgroundColor: "#d1c4e9"

    height: 40
    radius: 8

    Text {
        text: root.title
        font {
            bold: true
            pixelSize: 16
        }
        color: root.titleColor
        anchors.centerIn: parent
    }
}
