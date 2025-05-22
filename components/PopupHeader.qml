import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    width: parent.width
    height: 60
    color: "#9c27b0"

    property string title: ""

    signal closeClicked

    Label {
        anchors.centerIn: parent
        text: title
        font {
            pixelSize: 18
            bold: true
        }
        color: "white"
    }

    Button {
        width: 100
        height: 40
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        text: "✕"
        font.pixelSize: 20
        flat: true
        onClicked: closeClicked()
    }
}
