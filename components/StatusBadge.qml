import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string category
    property string status
    property int horizontalPadding: 8 // Отступы по бокам
    property int verticalPadding: 4 // Отступы сверху/снизу
    property int textSpacing: 4 // Расстояние между текстами

    radius: 4
    color: getStatusColor(status, false)
    border.color: getStatusColor(status, true)

    // Функция для определения цвета по статусу
    function getStatusColor(currentStatus, isBorder) {
        switch (currentStatus) {
        case "Можно":
            return isBorder ? "#C8E6C9" : "#E8F5E9"
        case "Умеренно":
            return isBorder ? "#FFECB3" : "#FFF8E1"
        case "Осторожно":
            return isBorder ? "#FFCDD2" : "#FFEBEE"
        default:
            return isBorder ? "#E0E0E0" : "#F5F5F5"
        }
    }

    // Скрытые элементы для измерения текста
    Text {
        id: categoryText
        text: category + ":"
        font.pixelSize: 12
        visible: false
    }

    Text {
        id: statusText
        text: status
        font.pixelSize: 12
        font.bold: true
        visible: false
    }

    // Основной контент
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.textSpacing

        Text {
            text: category + ":"
            font: categoryText.font
            color: "#555555"
        }

        Text {
            text: status
            font: statusText.font
            color: {
                if (status === "Можно")
                    return "#2E7D32"
                if (status === "Умеренно")
                    return "#FF8F00"
                if (status === "Осторожно")
                    return "#C62828"
                return "#616161"
            }
        }
    }

    // Автоматический расчет размеров
    implicitWidth: categoryText.implicitWidth + statusText.implicitWidth
                   + root.textSpacing + root.horizontalPadding * 2
    implicitHeight: Math.max(
                        categoryText.implicitHeight,
                        statusText.implicitHeight) + root.verticalPadding * 2
}
