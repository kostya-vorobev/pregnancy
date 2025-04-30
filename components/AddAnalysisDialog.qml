import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Popup {
    id: root
    width: Math.min(parent.width * 0.9, 600)
    height: Math.min(parent.height * 0.7, 800)
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

    ColumnLayout {
        width: parent.width
        spacing: 15

        Label {
            text: "Добавить новый анализ"
            font.bold: true
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
        }

        // Выбор категории
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Label {
                text: "Категория:"
                font.pixelSize: 14
            }

            MyComponents.CustomComboBox {
                id: categoryCombo
                model: categories.map(item => item.name)
                Layout.fillWidth: true
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
                font.pixelSize: 14
            }

            MyComponents.CustomComboBox {
                id: parameterCombo
                model: categoryCombo.currentIndex
                       >= 0 ? categories[categoryCombo.currentIndex].params : []
                Layout.fillWidth: true
            }
        }

        // Ввод значения
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: parameterCombo.currentIndex >= 0

            Label {
                text: "Значение:"
                font.pixelSize: 14
            }

            TextField {
                id: valueInput
                validator: DoubleValidator {
                    bottom: 0
                }
                Layout.fillWidth: true
                placeholderText: "Введите значение"
            }
        }

        // Выбор даты
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Label {
                text: "Дата анализа:"
                font.pixelSize: 14
            }

            RowLayout {
                DatePicker {
                    id: datePicker
                    Layout.fillWidth: true
                }

                MyComponents.CustomButton {
                    text: "Сегодня"
                    onClicked: datePicker.selectedDate = new Date()
                }
            }
        }

        // Кнопки действий
        RowLayout {
            spacing: 10
            Layout.alignment: Qt.AlignHCenter

            MyComponents.CustomButton {
                text: "Отмена"
                onClicked: root.close()
            }

            MyComponents.CustomButton {
                text: "Добавить"
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

    // Компонент выбора даты
    component DatePicker: RowLayout {
        property date selectedDate: new Date()
        spacing: 5

        ComboBox {
            id: dayCombo
            model: 31
            currentIndex: selectedDate.getDate() - 1
            onActivated: selectedDate = new Date(selectedDate.getFullYear(),
                                                 selectedDate.getMonth(),
                                                 currentIndex + 1)
        }

        ComboBox {
            id: monthCombo
            model: ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
            currentIndex: selectedDate.getMonth()
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
            onActivated: selectedDate = new Date(model[currentIndex],
                                                 selectedDate.getMonth(),
                                                 selectedDate.getDate())
        }
    }
}
