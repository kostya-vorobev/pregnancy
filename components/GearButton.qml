import QtQuick
import QtQuick.Controls

Item {
    id: gearButton
    width: 30
    height: 30

    property string tooltipText: "Настройки раздела"
    property alias scale: gearIcon.scale // Добавляем публичный доступ к scale
    signal clicked

    // Иконка шестерёнки
    Text {
        id: gearIcon
        text: "⚙️"
        font.pixelSize: 22
        anchors.centerIn: parent
        renderType: Text.NativeRendering

        // Анимация вращения
        RotationAnimation on rotation {
            id: gearAnimation
            from: 0
            to: 360
            duration: 2000
            loops: Animation.Infinite
            running: false
        }
    }

    // Подсказка
    ToolTip {
        id: tooltip
        visible: ma.containsMouse
        text: tooltipText
        delay: 500
    }
    Menu {
        id: contextMenu
        MenuItem {
            text: "Настройки"
            onTriggered: console.log("Настройки")
        }
        MenuItem {
            text: "Справка"
            onTriggered: console.log("Справка")
        }
    }
    // Область нажатия
    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            gearAnimation.start()
            gearButton.clicked()
            onClicked: contextMenu.popup()
        }

        onEntered: {
            scaleAnimator.to = 1.2
            scaleAnimator.start()
        }

        onExited: {
            scaleAnimator.to = 1.0
            scaleAnimator.start()
            gearAnimation.stop()
            gearIcon.rotation = 0
        }
    }

    // Аниматор масштаба (правильная реализация)
    ScaleAnimator {
        id: scaleAnimator
        target: gearIcon
        from: gearIcon.scale
        to: 1.0
        duration: 200
    }

    // Граница при наведении
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: ma.containsMouse ? "#9c27b0" : "transparent"
        border.width: 2

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }
        }
    }
}
