import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts

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

    ScrollView {
        anchors.fill: parent
        padding: 15

        ColumnLayout {
            width: parent.width
            spacing: 20

            Text {
                text: "Контроль веса"
                font {
                    family: "Comfortaa"
                    pixelSize: 22
                    bold: true
                }
                color: "#9c27b0"
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Добавить текущий вес"
                Layout.alignment: Qt.AlignHCenter
                onClicked: weightDialog.open()
            }
        }
    }

    Dialog {
        id: weightDialog
        title: "Добавить вес"
        standardButtons: Dialog.Ok | Dialog.Cancel

        ColumnLayout {
            TextField {
                id: weightInput
                placeholderText: "Вес в кг"
                validator: DoubleValidator {
                    bottom: 30
                    top: 150
                }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            TextField {
                id: dateInput
                placeholderText: "Дата (дд.мм.гггг)"
                inputMask: "99.99.9999"
            }
        }
    }
}
