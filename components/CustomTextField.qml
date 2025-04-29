import QtQuick
import QtQuick.Controls

TextField {
    id: textField
    property real fontSize: 16
    height: 50
    font.family: "Comfortaa"
    font.pixelSize: fontSize
    color: "#4a148c"
    padding: 10
    verticalAlignment: Text.AlignVCenter
    property string style: "Material"

    background: Rectangle {
        radius: 8
        border.color: "#9c27b0"
        border.width: 1
    }
}
