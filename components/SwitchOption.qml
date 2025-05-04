import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width
    height: 50

    property alias label: optionText.text
    property alias checked: switchControl.checked

    Row {
        width: parent.width
        height: parent.height
        spacing: 15

        Text {
            id: optionText
            text: "Опция"
            font {
                family: "Comfortaa"
                pixelSize: 16
            }
            color: "#4a148c"
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            width: parent.width - switchControl.width - parent.spacing
            wrapMode: Text.Wrap
        }

        Switch {
            id: switchControl
            anchors.verticalCenter: parent.verticalCenter
            checked: true
            indicator: Rectangle {
                implicitWidth: 48
                implicitHeight: 26
                radius: 13
                color: switchControl.checked ? "#9c27b0" : "#ffffff"
                border.color: switchControl.checked ? "#9c27b0" : "#cccccc"

                Rectangle {
                    x: switchControl.checked ? parent.width - width : 0
                    width: 26
                    height: 26
                    radius: 13
                    color: switchControl.down ? "#cccccc" : "#ffffff"
                    border.color: switchControl.checked ? (switchControl.down ? "#9c27b0" : "#9c27b0") : "#999999"
                }
            }
        }
    }
}
