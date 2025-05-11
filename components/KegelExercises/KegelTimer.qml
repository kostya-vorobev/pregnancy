import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

GroupBox {
    property string phase: "готово"
    property int timeLeft: 0
    property real progress: 0
    property bool running: false

    signal startClicked

    title: "Текущее упражнение"
    background: Rectangle {
        color: "white"
        radius: 10
        border.color: "#e0e0e0"
    }

    ColumnLayout {
        width: parent.width
        spacing: 10

        Text {
            text: "Фаза: " + phase
            font {
                bold: true
                pixelSize: 16
            }
            color: "#4a148c"
        }

        Text {
            text: "Осталось: " + timeLeft + " сек"
            font.pixelSize: 24
            color: "#9c27b0"
            Layout.alignment: Qt.AlignHCenter
        }

        ProgressBar {
            Layout.fillWidth: true
            value: progress
            background: Rectangle {
                radius: 2
                color: "#e0e0e0"
            }
            contentItem: Item {
                Rectangle {
                    width: parent.width * parent.parent.value
                    height: parent.height
                    radius: 2
                    color: "#9c27b0"
                }
            }
        }

        Button {
            text: running ? "Пауза" : "Начать"
            Layout.fillWidth: true
            background: Rectangle {
                radius: 5
                color: parent.down ? "#7b1fa2" : "#9c27b0"
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
            }
            onClicked: startClicked()
        }
    }
}
