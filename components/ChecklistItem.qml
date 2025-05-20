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
    property int taskId: -1 // Добавляем ID задачи для связи с базой

    height: 56
    radius: 12
    color: "white"
    clip: true

    // Сигнал для изменения состояния с передачей ID задачи
    signal toggled(int taskId, bool checked)

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.taskId,
                         root.checked) // Передаем ID задачи и новое состояние
        }

        RowLayout {
            id: content
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            Rectangle {
                id: checkbox
                width: 24
                height: 24
                radius: 4
                border.width: 2
                border.color: root.checked ? root.indicatorColor : "#e0e0e0"
                color: root.checked ? root.indicatorColor : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "white"
                    font.pixelSize: 14
                    visible: root.checked
                }
            }

            Text {
                id: taskText
                text: root.text
                Layout.fillWidth: true
                font.pixelSize: 16
                font.family: "Roboto"
                color: root.checked ? "#666" : "#333"
                wrapMode: Text.WordWrap

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

    // Анимации остаются без изменений
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
    onCheckedChanged: clickAnim.start()
}
