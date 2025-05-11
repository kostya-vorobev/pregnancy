import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    background: Rectangle {
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#f3e5f5"
            }
            GradientStop {
                position: 1.0
                color: "#e1bee7"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Text {
            text: "Счетчик толчков малыша"
            font {
                family: "Comfortaa"
                pixelSize: 22
                bold: true
            }
            color: "#9c27b0"
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Количество толчков: " + kickCount
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            id: counterCircle
            width: 150
            height: 150
            radius: width / 2
            color: mouseArea.pressed ? "#d1c4e9" : "#b39ddb"
            border.color: "#9c27b0"
            border.width: 3
            Layout.alignment: Qt.AlignHCenter

            Text {
                text: "Нажмите"
                anchors.centerIn: parent
                font.pixelSize: 16
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: kickCount++
            }
        }

        Button {
            text: "Сбросить счетчик"
            Layout.alignment: Qt.AlignHCenter
            onClicked: kickCount = 0
        }

        Text {
            text: "Рекомендуется отслеживать активность малыша 2 раза в день"
            font.pixelSize: 12
            color: "#666"
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
    }

    property int kickCount: 0
}
