import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Popup {
    id: root
    width: Math.min(parent.width * 0.9, 400)
    height: Math.min(parent.height * 0.8, 700) // Увеличил максимальную высоту
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 20

    property var categories: [{
            "name": "Кровь",
            "params": ["Гемоглобин", "Глюкоза", "Лейкоциты", "Тромбоциты"]
        }, {
            "name": "Моча",
            "params": ["Белок", "Лейкоциты", "Глюкоза"]
        }, {
            "name": "УЗИ",
            "params": ["БПР", "Длина бедра", "Окружность головы"]
        }]

    signal analysisAdded(string category, string parameter, real value, date testDate)

    background: Rectangle {
        radius: 10
        color: "#ffffff"
        border.color: "#e0e0e0"
        border.width: 1
    }

    Flickable {
        anchors.fill: parent
        contentWidth: contentColumn.width
        contentHeight: contentColumn.height
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width - root.padding * 2
            spacing: 15

            Label {
                text: "Добавить новый анализ"
                font.bold: true
                font.pixelSize: 20
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
            }

            // Выбор категории
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                Label {
                    text: "Категория:"
                    font.pixelSize: 16
                }

                MyComponents.CustomComboBox {
                    id: categoryCombo
                    model: categories.map(item => item.name)
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    onCurrentIndexChanged: parameterCombo.currentIndex = -1
                }
            }

            // Выбор параметра
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true
                visible: categoryCombo.currentIndex >= 0

                Label {
                    text: "Показатель:"
                    font.pixelSize: 16
                }

                MyComponents.CustomComboBox {
                    id: parameterCombo
                    model: categoryCombo.currentIndex
                           >= 0 ? categories[categoryCombo.currentIndex].params : []
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                }
            }

            // Ввод значения
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true
                visible: parameterCombo.currentIndex >= 0

                Label {
                    text: "Значение:"
                    font.pixelSize: 16
                }

                MyComponents.CustomTextField {
                    id: valueInput
                    validator: DoubleValidator {
                        bottom: 0
                    }
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: "Введите значение"
                }
            }

            // Выбор даты
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true

                Label {
                    text: "Дата анализа:"
                    font.pixelSize: 16
                }

                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    DatePicker {
                        id: datePicker
                        Layout.fillWidth: true
                    }

                    MyComponents.CustomButton {
                        text: "Сегодня"
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        onClicked: datePicker.selectedDate = new Date()
                    }
                }
            }

            // Кнопки действий
            RowLayout {
                spacing: 15
                Layout.fillWidth: true
                Layout.topMargin: 20

                MyComponents.CustomButton {
                    text: "Отмена"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    onClicked: root.close()
                }

                MyComponents.CustomButton {
                    text: "Добавить"
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    enabled: parameterCombo.currentIndex >= 0
                             && valueInput.text !== ""
                    onClicked: {
                        const category = categories[categoryCombo.currentIndex].name.toLowerCase()
                        const parameter = parameterCombo.currentText
                        const value = parseFloat(valueInput.text)
                        root.analysisAdded(category, parameter, value,
                                           datePicker.selectedDate)
                        root.close()
                    }
                }
            }
        }
    }

    // Компонент выбора даты
    component DatePicker: RowLayout {
        property date selectedDate: new Date()
        spacing: 5

        ComboBox {
            id: dayCombo
            model: 31
            currentIndex: selectedDate.getDate() - 1
            Layout.preferredWidth: 80
            Layout.preferredHeight: 40
            onActivated: selectedDate = new Date(selectedDate.getFullYear(),
                                                 selectedDate.getMonth(),
                                                 currentIndex + 1)
        }

        ComboBox {
            id: monthCombo
            model: ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
            currentIndex: selectedDate.getMonth()
            Layout.preferredWidth: 100
            Layout.preferredHeight: 40
            onActivated: selectedDate = new Date(selectedDate.getFullYear(),
                                                 currentIndex,
                                                 selectedDate.getDate())
        }

        ComboBox {
            id: yearCombo
            model: {
                var years = []
                var currentYear = new Date().getFullYear()
                for (var i = currentYear - 1; i <= currentYear + 1; i++) {
                    years.push(i)
                }
                return years
            }
            currentIndex: {
                var currentYear = new Date().getFullYear()
                return selectedDate.getFullYear() - currentYear + 1
            }
            Layout.preferredWidth: 100
            Layout.preferredHeight: 40
            onActivated: selectedDate = new Date(model[currentIndex],
                                                 selectedDate.getMonth(),
                                                 selectedDate.getDate())
        }
    }
}
