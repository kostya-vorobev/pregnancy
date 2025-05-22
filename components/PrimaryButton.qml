import QtQuick
import QtQuick.Controls

Button {
    id: root
    height: 50
    font.pixelSize: 16
    font.bold: true

    background: Rectangle {
        radius: 5
        color: root.down ? "#7b1fa2" : "#9c27b0"
        opacity: root.enabled ? 1 : 0.5
    }

    contentItem: Text {
        text: root.text
        font: root.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
