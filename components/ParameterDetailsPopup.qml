import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Popup {
    id: root
    width: Math.min(parent.width * 0.9, 500)
    height: Math.min(parent.height * 0.7, 600)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 20

    property var parameterData: ({})
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

        GridLayout {
            columns: 2
            columnSpacing: 20
            rowSpacing: 10
            Layout.fillWidth: true

            // Текущее значение
            Label {
                text: "Текущее значение:"
                font.bold: true
                font.pixelSize: 16
            }
            Label {
                text: (parameterData.value
                       || "--") + " " + (parameterData.unit || "")
                font.pixelSize: 16
                Layout.fillWidth: true
            }

            // Референсные значения
            Label {
                text: "Нормальный диапазон:"
                font.bold: true
                font.pixelSize: 16
            }
            Label {
                text: getNormalRangeText(parameterData)
                font.pixelSize: 16
                Layout.fillWidth: true
            }

            // Тренд (показываем только если есть данные)
            Label {
                text: "Тренд:"
                font.bold: true
                font.pixelSize: 16
                visible: parameterData.trend !== undefined
            }
            Label {
                text: parameterData.trend !== undefined ? getTrendText(
                                                              parameterData.trend) : ""
                font.pixelSize: 16
                visible: parameterData.trend !== undefined
                Layout.fillWidth: true
            }
        }

        // График истории (заглушка)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            color: "#f5f5f5"
            radius: 5
            border.color: "#e0e0e0"
            visible: false // Временно скрыто, пока не реализовано

            Label {
                anchors.centerIn: parent
                text: "График изменения показателя"
                color: "#888"
            }
        }

        // Рекомендации
        Label {
            text: "Рекомендации:"
            font.bold: true
            font.pixelSize: 16
            Layout.topMargin: 10
        }
        Label {
            text: getRecommendations(parameterData)
            font.pixelSize: 14
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 15

            MyComponents.CustomButton {
                id: closeButton
                text: "Закрыть"
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 10
                }
                height: parent.height
                onClicked: root.close()
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 15

            MyComponents.CustomButton {
                text: "История"
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 10
                }
                height: parent.height
                onClicked: {
                    console.log(parameterData.id + " " + parameterData.name
                                + " " + parameterData.unit)
                    historyPopup.parameterId = parameterData.typeId
                    historyPopup.parameterName = parameterData.name
                    historyPopup.parameterUnit = parameterData.unit
                    historyPopup.open()
                }
            }
        }
    }

    function getNormalRangeText(data) {
        if (!data)
            return "не указаны"

        if (data.min !== undefined && data.max !== undefined) {
            return data.min + " - " + data.max + " " + (data.unit || "")
        } else if (data.max !== undefined) {
            return "до " + data.max + " " + (data.unit || "")
        } else if (data.min !== undefined) {
            return "от " + data.min + " " + (data.unit || "")
        }
        return "не указаны"
    }

    function getTrendText(trend) {
        if (!trend)
            return "Неизвестно"

        switch (trend) {
        case "increasing":
            return "Повышается ↗"
        case "decreasing":
            return "Понижается ↘"
        case "stable":
            return "Стабильный →"
        default:
            return "Неизвестно"
        }
    }

    function getRecommendations(data) {
        if (!data || data.value === undefined) {
            return "Нет данных для рекомендаций"
        }

        if (data.min !== undefined && data.value < data.min) {
            return "• Показатель ниже нормы\n• Рекомендуется консультация врача\n• Возможно, требуется корректировка питания"
        }

        if (data.max !== undefined && data.value > data.max) {
            return "• Показатель выше нормы\n• Необходимо дополнительное обследование\n• Соблюдайте рекомендации врача"
        }

        return "Показатель в пределах нормы. Продолжайте наблюдение."
    }
}
