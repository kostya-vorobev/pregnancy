import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls

ColumnLayout {
    id: root
    property string title: ""
    property color indicatorColor: "#9c27b0"
    property alias model: repeater.model

    spacing: 8
    Layout.fillWidth: true

    // Заголовок секции
    Rectangle {
        id: header
        Layout.fillWidth: true
        height: 56
        radius: 12
        color: Qt.lighter(root.indicatorColor, 1.4)

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#20000000"
            shadowVerticalOffset: 2
            shadowBlur: 0.8
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            // Иконка/номер триместра
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: root.indicatorColor

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (root.title.includes("Первый"))
                            return "1"
                        if (root.title.includes("Второй"))
                            return "2"
                        if (root.title.includes("Третий"))
                            return "3"
                        return "★"
                    }
                    color: "white"
                    font {
                        pixelSize: 16
                        bold: true
                    }
                }
            }

            // Название триместра
            Text {
                text: root.title
                Layout.fillWidth: true
                font {
                    pixelSize: 16
                    bold: true
                    family: "Comfortaa"
                }
                color: "#4a148c"
            }

            // Прогресс выполнения
            ProgressBar {
                id: progressBar
                Layout.preferredWidth: 80
                value: {
                    if (!repeater.model)
                        return 0
                    var completed = 0
                    for (var i = 0; i < repeater.model.count; i++) {
                        if (repeater.model.get(i).checked)
                            completed++
                    }
                    return completed / repeater.model.count
                }

                background: Rectangle {
                    radius: height / 2
                    color: "#e0e0e0"
                }

                contentItem: Rectangle {
                    radius: height / 2
                    color: root.indicatorColor
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                        }
                    }
                }
            }

            // Процент выполнения
            Text {
                text: Math.round(progressBar.value * 100) + "%"
                font {
                    pixelSize: 14
                    bold: true
                }
                color: progressBar.value > 0.5 ? root.indicatorColor : "#666"
            }
        }
    }

    // Элементы чеклиста
    Repeater {
        id: repeater
        delegate: ChecklistItem {
            text: model.text
            checked: model.checked
            onCheckedChanged: model.checked = checked
            Layout.fillWidth: true
            indicatorColor: root.indicatorColor

            // Анимация появления
            opacity: 0
            NumberAnimation on opacity {
                from: 0
                to: 1
                duration: 300
                running: true
            }
        }
    }
}
