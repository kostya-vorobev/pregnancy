// components/DayInfoPopup.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup
    width: parent.width * 0.95
    height: parent.height * 0.8
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property date selectedDate: new Date()
    property string weightValue: "Никогда не измерялось"
    property string pressureValue: "Никогда не измерялось"
    property string waistValue: "Никогда не измерялось"

    background: Rectangle {
        radius: 10
        color: "white"
        border.color: "#e0e0e0"
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + 40
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: 20

            // Шапка с датой
            Rectangle {
                width: parent.width
                height: 60
                color: "#9c27b0"

                Label {
                    anchors.centerIn: parent
                    text: Qt.formatDate(selectedDate, "d MMMM yyyy")
                    font.pixelSize: 18
                    color: "white"
                }
            }

            // Блок показателей
            GridLayout {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                columnSpacing: 20
                rowSpacing: 15

                // Вес
                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Вес"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Label {
                        text: weightValue
                        font.pixelSize: 16
                    }
                    Button {
                        text: "ДОБАВИТЬ"
                        flat: true
                        font.bold: true
                        onClicked: addWeightDialog.open()
                    }
                }

                // Давление
                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Давление"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Label {
                        text: pressureValue
                        font.pixelSize: 16
                    }
                    Button {
                        text: "ДОБАВИТЬ"
                        flat: true
                        font.bold: true
                        onClicked: addPressureDialog.open()
                    }
                }

                // Живот
                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Живот"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    Label {
                        text: waistValue
                        font.pixelSize: 16
                    }
                    Button {
                        text: "ДОБАВИТЬ"
                        flat: true
                        font.bold: true
                        onClicked: addWaistDialog.open()
                    }
                }
            }

            // Планы на день
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Планы на день:"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                Button {
                    text: "Посещение специалиста"
                    flat: true
                    font.bold: true
                    onClicked: addAppointmentDialog.open()
                }
            }

            // Симптомы
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Как ваши дела?"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                Label {
                    text: "Симптомы"
                    font.pixelSize: 14
                    color: "#666"
                }

                Flow {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: ["всё в порядке", "акне", "головная боль", "боль в пояснице", "боли в теле", "спазмы внизу живота", "усталость"]

                        CheckBox {
                            text: modelData
                            checked: index === 0
                        }
                    }
                }

                Button {
                    text: "ЕЩЁ"
                    flat: true
                    font.bold: true
                    onClicked: showMoreSymptoms()
                }
            }

            // Настроение
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Настроение"
                    font.pixelSize: 14
                    color: "#666"
                }

                Flow {
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: ["вдохновленная", "безразличная", "радостная", "грустная", "злая", "возбужденная", "в панике"]

                        RadioButton {
                            text: modelData
                            checked: index === 2
                        }
                    }
                }
            }
        }
    }

    // Диалоги добавления данных
    Dialog {
        id: addWeightDialog
        title: "Добавить вес"
        // ... реализация диалога
    }

    Dialog {
        id: addPressureDialog
        title: "Добавить давление"
        // ... реализация диалога
    }

    // ... остальные диалоги
    function showMoreSymptoms() {// Логика показа дополнительных симптомов
    }
}
