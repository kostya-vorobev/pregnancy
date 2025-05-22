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
    property string weightValue: ""
    property string pressureValue: ""
    property string waistValue: ""
    property string moodValue: ""
    property var symptomsModel: []

    signal saveClicked(var data)

    // Объявляем сигнал с одним параметром
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

                Button {
                    anchors {
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Сохранить"
                    flat: true
                    onClicked: {
                        var dataToSave = {
                            "date": selectedDate,
                            "weight": weightValue,
                            "pressure": pressureValue,
                            "waist": waistValue,
                            "mood": moodValue,
                            "symptoms": symptomsModel
                        }
                        saveClicked(dataToSave) // Передаем один объект
                        close()
                    }
                }
            }

            // Блок показателей
            GridLayout {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 1
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
                    CustomTextField {
                        id: weightField
                        width: parent.width
                        text: weightValue
                        placeholderText: "Введите вес (кг)"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: weightValue = text
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
                    CustomTextField {
                        id: pressureField
                        width: parent.width
                        text: pressureValue
                        placeholderText: "120/80"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /^\d{2,3}\/\d{2,3}$/
                        }
                        onTextChanged: pressureValue = text
                    }
                }

                // Живот
                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Обхват талии"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    CustomTextField {
                        id: waistField
                        width: parent.width
                        text: waistValue
                        placeholderText: "Введите обхват (см)"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        onTextChanged: waistValue = text
                    }
                }
            }

            // Симптомы
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Симптомы"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                Repeater {
                    model: symptomsModel

                    delegate: RowLayout {
                        width: parent.width
                        spacing: 10

                        CheckBox {
                            checked: modelData.severity > 0
                            onCheckedChanged: {
                                var updatedSymptoms = symptomsModel
                                updatedSymptoms[index].severity = checked ? 1 : 0
                                symptomsModel = updatedSymptoms
                            }
                        }

                        Label {
                            text: modelData.name
                            Layout.fillWidth: true
                        }

                        Slider {
                            from: 1
                            to: 5
                            value: modelData.severity > 0 ? modelData.severity : 1
                            stepSize: 1
                            visible: modelData.severity > 0
                            onMoved: {
                                var updatedSymptoms = symptomsModel
                                updatedSymptoms[index].severity = value
                                symptomsModel = updatedSymptoms
                            }
                        }

                        Label {
                            text: modelData.severity > 0 ? modelData.severity + "/5" : ""
                            visible: modelData.severity > 0
                        }
                    }
                }
            }

            // Настроение
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Настроение"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                CustomComboBox {
                    id: moodComboBox
                    width: parent.width
                    model: ["", "Отличное", "Хорошее", "Нормальное", "Плохое", "Ужасное"]
                    currentIndex: {
                        switch (moodValue) {
                        case "Отличное":
                            return 1
                        case "Хорошее":
                            return 2
                        case "Нормальное":
                            return 3
                        case "Плохое":
                            return 4
                        case "Ужасное":
                            return 5
                        default:
                            return 0
                        }
                    }
                    onActivated: moodValue = currentText
                }
            }
        }
    }

    // Диалог добавления симптома
    Dialog {
        id: symptomDialog
        title: "Добавить симптом"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel

        Column {
            width: parent.width
            spacing: 10

            CustomComboBox {
                id: symptomComboBox
                width: parent.width
                model: ["Тошнота", "Головная боль", "Боль в спине", "Изжога", "Отеки", "Судороги"]
            }

            SpinBox {
                id: severitySpinBox
                width: parent.width
                from: 1
                to: 5
                value: 1
                textFromValue: function (value) {
                    return "Интенсивность: " + value
                }
            }
        }

        onAccepted: {
            var newSymptom = {
                "name": symptomComboBox.currentText,
                "severity": severitySpinBox.value,
                "notes": ""
            }
            symptomsModel.push(newSymptom)
            symptomsModel = symptomsModel // Force update
        }
    }
}
