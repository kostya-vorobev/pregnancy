import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property Flickable flickableItem
    property color handleColor: "#9c27b0"
    property int handleWidth: 8
    property int handleRadius: 4

    implicitWidth: handleWidth
    visible: flickableItem && flickableItem.contentHeight > flickableItem.height
    z: 1000

    // Фон скроллбара
    Rectangle {
        anchors.fill: parent
        color: "#10000000"
        radius: handleRadius
    }

    // Ползунок
    Rectangle {
        id: handle
        width: parent.width - 2
        radius: handleRadius
        color: handleColor
        opacity: ma.containsMouse ? 0.9 : 0.6
        x: 1

        // Динамический расчет положения и размера
        height: Math.max(
                    30,
                    parent.height * (flickableItem.height / flickableItem.contentHeight))
        y: flickableItem.contentY * (parent.height - height)
           / (flickableItem.contentHeight - flickableItem.height)

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 100
            }
        }
    }

    // Область взаимодействия
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        drag.target: handle
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: parent.height - handle.height

        // Прокрутка при перетаскивании
        onPositionChanged: if (drag.active) {
                               flickableItem.contentY = handle.y
                                       * (flickableItem.contentHeight - flickableItem.height)
                                       / (parent.height - handle.height)
                           }

        // Прокрутка колесиком
        onWheel: {
            flickableItem.contentY -= wheel.angleDelta.y / 2
            flickableItem.returnToBounds()
        }

        // Клик для быстрой прокрутки
        onClicked: {
            var targetY = mouseY - handle.height / 2
            flickableItem.contentY = targetY * flickableItem.contentHeight / parent.height
        }
    }
}
