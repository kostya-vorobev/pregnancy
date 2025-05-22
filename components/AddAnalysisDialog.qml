import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
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
    property var analysisTypes: analysisManager ? analysisManager.getAnalysisTypes(
                                                      ) : []
    property int currentTypeId: -1

    signal analysisAdded(int typeId, real value, date testDate, string notes, string laboratory, bool isFasting)

    background: Rectangle {
        radius: 10
        color: "#ffffff"
        border.color: "#e0e0e0"
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 5
            samples: 10
            color: "#20000000"
        }
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
                model: {
                    var cats = []
                    var result = {}
                    for (var i = 0; i < analysisTypes.length; i++) {
                        var cat = analysisTypes[i].category
                        if (!result[cat]) {
                            cats.push(cat)
                            result[cat] = true
                        }
                    }
                    return cats
                }
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                currentIndex: 0
                onCurrentIndexChanged: {
                    parameterCombo.model = getParametersByCategory(currentText)
                    parameterCombo.currentIndex = -1
                    currentTypeId = -1
                }
            }
        }

        // Выбор параметра
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            //visible: categoryCombo.currentIndex >= 0
            Label {
                text: "Показатель:"
                font.pixelSize: 16
            }

            MyComponents.CustomComboBox {
                id: parameterCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                textRole: "displayName"
                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        currentTypeId = currentValue
                        var type = model[currentIndex]
                        valueInput.placeholderText = "Норма: "
                                + (type.minValue !== undefined ? type.minValue + "-" : "")
                                + (type.maxValue
                                   || "") + " " + (type.unit || "")
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
                placeholderText: "Название лаборатории"
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

    function getParametersByCategory(category) {
        var params = []
        for (var i = 0; i < analysisTypes.length; i++) {
            if (analysisTypes[i].category === category) {
                params.push(analysisTypes[i])
            }
        }
        return params
    }

    // Инициализация текущей даты
    Component.onCompleted: {
        datePicker.selectedDate = new Date()
    }

    function openDialog() {
        categoryCombo.currentIndex = -1
        parameterCombo.currentIndex = -1
        valueInput.clear()
        laboratoryInput.clear()
        notesInput.clear()
        fastingCheckBox.checked = true
        datePicker.selectedDate = new Date()
        open()
    }
}
