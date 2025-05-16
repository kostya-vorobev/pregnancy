import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string text
    property bool selected: false
    property int padding: 20
    signal clicked

    height: 36
    radius: height / 2
    color: selected ? "#7E57C2" : "#F5F3FF"
    border.color: "#7E57C2"

    Text {
        id: textMetrics
        text: root.text
        font.pixelSize: 14
        visible: false
    }

    Text {
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 14
        color: selected ? "white" : "#7E57C2"
    }

    width: textMetrics.implicitWidth + padding * 2

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.clicked()
        }
    }
}
