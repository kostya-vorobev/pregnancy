import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 100
    height: 120

    property alias iconSource: icon.source
    property alias title: titleText.text
    property alias subtitle: subtitleText.text
    property color tileColor: "#9c27b0"
    property real tileRadius: 14

    signal clicked

    Rectangle {
        id: tile
        anchors.fill: parent
        radius: tileRadius
        color: Qt.lighter(tileColor, 1.2)
        border.color: tileColor
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 10
            width: parent.width * 0.8

            Image {
                id: icon
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize.width: parent.width * 0.4
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: titleText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: "Comfortaa"
                    pixelSize: 18
                    bold: true
                }
                color: "#4a148c"
                wrapMode: Text.Wrap
            }

            Text {
                id: subtitleText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: "Comfortaa"
                    pixelSize: 14
                }
                color: "#4a148c"
                opacity: 0.8
                wrapMode: Text.Wrap
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.clicked()
        }
    }
}
