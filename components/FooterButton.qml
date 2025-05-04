import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: parent.width / 5
    height: parent.height
    property alias iconSource: icon.source

    signal clicked

    Image {
        id: icon
        anchors.centerIn: parent
        width: 30
        height: 30
        sourceSize: Qt.size(width, height)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
