import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents
import PregnancyApp 1.0

Popup {
    id: root
    width: Math.min(parent.width * 0.9, 500)
    implicitHeight: contentColumn.implicitHeight + 40
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 20

    property var analysisManager
    property var analysisTypes: []
    property var categories: []
    property var parametersByCategory: ({})
    property int currentTypeId: -1

    signal analysisAdded(int typeId, real value, date testDate, string notes, string laboratory, bool isFasting)

    // Инициализация данных при создании
    Component.onCompleted: {
        loadAnalysisData()
    }

    function loadAnalysisData() {
        if (analysisManager) {
            analysisTypes = analysisManager.getAnalysisTypes()
            processAnalysisData()
        }
    }

    function processAnalysisData() {
        // Группируем анализы по категориям
        var tempParamsByCategory = {}
        var tempCategories = []

        for (var i = 0; i < analysisTypes.length; i++) {
            var type = analysisTypes[i]
            var category = type.category

            if (!tempParamsByCategory[category]) {
                tempParamsByCategory[category] = []
                tempCategories.push(category)
            }
            tempParamsByCategory[category].push(type)
        }

        categories = tempCategories
        parametersByCategory = tempParamsByCategory

        // Обновляем модели ComboBox
        categoryCombo.model = categories
        if (categories.length > 0) {
            categoryCombo.currentIndex = 0
            updateParametersCombo()
        }
    }

    function updateParametersCombo() {
        var currentCat = categoryCombo.currentText
        if (currentCat && parametersByCategory[currentCat]) {
            parameterCombo.model = parametersByCategory[currentCat]
        } else {
            parameterCombo.model = []
        }
        parameterCombo.currentIndex = -1
        currentTypeId = -1
    }

    background: Rectangle {
        radius: 10
        color: "#ffffff"
        border.color: "#e0e0e0"
        border.width: 1
    }

    ColumnLayout {
        id: contentColumn
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
                font.pixelSize: 16
            }

            MyComponents.CustomComboBox {
                id: categoryCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 45

                onCurrentTextChanged: {
                    if (currentText) {
                        updateParametersCombo()
                    }
                }
            }
        }

        // Выбор параметра
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Label {
                text: "Показатель:"
                font.pixelSize: 16
            }

            MyComponents.CustomComboBox {
                id: parameterCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                textRole: "displayName"

                valueRole: "id"
                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        var type = model[currentIndex]
                        currentTypeId = type.id // Получаем id напрямую из модели
                        valueInput.placeholderTextValue = formatRangeText(type)
                    } else {
                        currentTypeId = -1
                        valueInput.placeholderTextValue = ""
                    }
                }
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
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                validator: DoubleValidator {
                    bottom: 0
                }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
        }

        // Лаборатория
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: parameterCombo.currentIndex >= 0

            Label {
                text: "Лаборатория:"
                font.pixelSize: 16
            }

            MyComponents.CustomTextField {
                id: laboratoryInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderTextValue: "Название лаборатории"
            }
        }

        // Натощак
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: parameterCombo.currentIndex >= 0

            Label {
                text: "Условия сдачи:"
                font.pixelSize: 16
            }

            MyComponents.ChecklistItem {
                id: fastingCheckBox
                text: "Натощак"
                checked: false
                taskId: 1
                indicatorColor: "#e91e63"
                Layout.fillWidth: true
                opacity: 0

                NumberAnimation on opacity {
                    from: 0
                    to: 1
                    duration: 300
                    running: true
                }
            }
        }

        // Ввод примечаний
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: parameterCombo.currentIndex >= 0

            Label {
                text: "Примечания:"
                font.pixelSize: 16
            }

            TextArea {
                id: notesInput
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                wrapMode: TextArea.Wrap
                placeholderText: "Дополнительная информация..."
                background: Rectangle {
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 4
                }
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

            MyComponents.CustomDate {
                id: datePicker
                Layout.fillWidth: true
                Layout.preferredHeight: 45
            }
        }

        // Кнопки действий
        RowLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.topMargin: 10

            MyComponents.CustomButton {
                text: "Отмена"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                flat: true
                onClicked: root.close()
            }

            MyComponents.CustomButton {
                text: "Добавить"
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                enabled: parameterCombo.currentIndex >= 0
                         && valueInput.text !== "" && !isNaN(
                             parseFloat(valueInput.text))
                onClicked: {
                    root.analysisAdded(currentTypeId,
                                       parseFloat(valueInput.text),
                                       datePicker.selectedDate,
                                       notesInput.text, laboratoryInput.text,
                                       fastingCheckBox.checked)
                    root.close()
                }
            }
        }
    }

    function formatRangeText(type) {
        if (!type)
            return ""
        var text = "Норма: "
        if (type.minValue !== undefined)
            text += type.minValue
        if (type.maxValue !== undefined)
            text += " - " + type.maxValue
        if (type.unit)
            text += " " + type.unit
        return text
    }

    function openDialog() {
        // Перезагружаем данные при каждом открытии
        loadAnalysisData()

        // Сбрасываем состояние
        if (categoryCombo.count > 0) {
            categoryCombo.currentIndex = 0
            updateParametersCombo()
        }

        valueInput.clear()
        laboratoryInput.clear()
        notesInput.clear()
        fastingCheckBox.checked = false
        datePicker.selectedDate = new Date()
        open()
    }
}
