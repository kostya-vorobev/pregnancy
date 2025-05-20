import QtQuick
import QtQuick.Layouts

Rectangle {
    property alias title: titleText.text
    property alias content: contentText.text

    width: parent.width
    implicitHeight: column.implicitHeight + 20 // используем implicitHeight
    radius: 8
    color: "#ffffff"
    border.color: "#e1bee7"
    border.width: 1

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        Text {
            id: titleText
            width: parent.width
            font {
                family: "Roboto"
                pixelSize: 16
                bold: true
            }
            wrapMode: Text.WordWrap
            color: "#7b1fa2"
        }

        Text {
            id: contentText
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: 14
            color: "#666"
        }
    }
}
