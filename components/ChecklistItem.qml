import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material.impl
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    property string text: ""
    property bool checked: false
    property color indicatorColor: "#9c27b0"

    height: 56
    radius: 12
    color: "white"
    clip: true

    // Сигнал для изменения состояния
    signal toggled(bool checked)

    // Внешний MouseArea для всей области
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }

        // Основное содержимое
        RowLayout {
            id: content
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            // Кастомный чекбокс
            Rectangle {
                id: checkbox
                width: 24
                height: 24
                radius: 4
                border.width: 2
                border.color: root.checked ? root.indicatorColor : "#e0e0e0"
                color: root.checked ? root.indicatorColor : "transparent"

                // Галочка
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "white"
                    font.pixelSize: 14
                    visible: root.checked
                    opacity: root.checked ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100
                        }
                    }
                }
            }

            // Текст задачи
            Text {
                id: taskText
                text: root.text
                Layout.fillWidth: true
                font.pixelSize: 16
                font.family: "Roboto"
                color: root.checked ? "#666" : "#333"
                wrapMode: Text.WordWrap

                // Линия перечеркивания
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.checked ? parent.width : 0
                    height: 2
                    color: root.indicatorColor
                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }

    // Анимация при нажатии
    SequentialAnimation {
        id: clickAnim
        PropertyAction {
            target: root
            property: "scale"
            value: 0.98
        }
        PropertyAction {
            target: content
            property: "x"
            value: 8
        }
        PauseAnimation {
            duration: 200
        }
        PropertyAction {
            target: root
            property: "scale"
            value: 1
        }
        PropertyAction {
            target: content
            property: "x"
            value: 0
        }
    }

    // Запуск анимации при изменении состояния
    onCheckedChanged: clickAnim.start()
}
