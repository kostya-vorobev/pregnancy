import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    // Публичные свойства
    property alias contentItem: contentColumn.data
    property color borderColor: "#e1bee7"
    property real borderWidth: 1
    property real spacing: 10 // Отступ между элементами
    property real padding: 12 // Внутренние отступы карточки

    // Визуальные настройки
    radius: 12
    color: "white"
    border.color: borderColor
    border.width: borderWidth

    // Автоматический расчет высоты
    implicitHeight: contentColumn.implicitHeight + 2 * padding

    // Основной контейнер с автоматическим расчетом размера
    ColumnLayout {
        id: contentColumn
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: root.spacing

        // Автоматическое распределение дочерних элементов
        default property alias children: contentColumn.children

        // Гарантируем правильное поведение Layout
        onImplicitHeightChanged: root.implicitHeight = Qt.binding(function () {
            return contentColumn.implicitHeight + 2 * root.padding
        })
    }

    // Альтернативный вариант с Column вместо ColumnLayout

    /*
    Column {
        id: contentColumn
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: root.spacing

        // Автоматическое распределение дочерних элементов
        default property alias children: contentColumn.children
    }
    */
}
