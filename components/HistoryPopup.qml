import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Popup {
    id: root
    width: Math.min(parent.width * 0.9, 500)
    height: Math.min(contentHeight * 1.2, 500)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 20

    property string parameterName: ""

    background: Rectangle {
        radius: 10
        color: "#ffffff"
        border.color: "#e0e0e0"
    }

    ColumnLayout {
        width: parent.width
        spacing: 15

        Label {
            text: parameterName
            font.bold: true
            font.pixelSize: 22
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.Wrap
            width: parent.width
        }

        // График истории (заглушка)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: "#f5f5f5"
            radius: 5
            border.color: "#e0e0e0"

            Label {
                anchors.centerIn: parent
                text: "График изменения показателя"
                color: "#888"
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50 // Фиксированная высота для кнопки
            Layout.topMargin: 15

            MyComponents.CustomButton {
                id: closeButton
                text: "Закрыть"
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 10 // Отступы по бокам
                }
                height: parent.height
                onClicked: root.close()
            }
        }
    }
}
