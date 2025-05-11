import QtQuick 2.15

Rectangle {
    id: root

    property string text: ""
    property color textColor: "#7b1fa2"
    property color backgroundColor: "#e1bee7"

    implicitWidth: Math.min(tagText.implicitWidth + 20, 200)
    implicitHeight: 28
    radius: height / 2
    color: backgroundColor

    Text {
        id: tagText
        text: root.text
        anchors.centerIn: parent
        leftPadding: 10
        rightPadding: 10
        font {
            pixelSize: 12
            bold: true
        }
        color: textColor
    }
}
