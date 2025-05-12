import QtQuick
import QtQuick.Controls

Rectangle {
    property alias text: label.text
    property color color: "#9c27b0"

    width: parent.width
    height: 40
    radius: 8

    Label {
        id: label
        anchors.centerIn: parent
        font {
            family: "Comfortaa"
            pixelSize: 18
            bold: true
        }
        color: "#4a148c"
    }
}
