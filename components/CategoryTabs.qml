import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root
    height: 48

    property var categories: ["Кровь", "Моча", "УЗИ"]
    property var categoryValues: ["blood", "urine", "ultrasound"]
    property int currentIndex: 0
    signal categorySelected(string category)

    // Фон панели
    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"
        radius: 8
        border.color: "#E0E0E0"
        border.width: 1
    }

    // Индикатор выбранной вкладки
    Rectangle {
        id: selectionIndicator
        height: 3
        color: "#9C27B0"
        radius: 2
        y: parent.height - height - 2

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    // Контейнер кнопок
    Row {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.categories

            Item {
                width: parent.width / root.categories.length
                height: parent.height

                // Кастомная кнопка
                Rectangle {
                    id: btnBg
                    anchors.fill: parent
                    color: "transparent"

                    Text {
                        text: modelData
                        anchors.centerIn: parent
                        font {
                            family: "Roboto"
                            pixelSize: 14
                            weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
                        }
                        color: root.currentIndex === index ? "#9C27B0" : "#757575"
                    }

                    // Эффект при наведении
                    Rectangle {
                        anchors.fill: parent
                        color: "#9C27B0"
                        opacity: btnMa.containsMouse ? 0.08 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }
                }

                // Область нажатия
                MouseArea {
                    id: btnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.currentIndex = index
                        root.categorySelected(root.categoryValues[index])
                    }
                }
            }
        }
    }

    // Инициализация индикатора
    Component.onCompleted: updateIndicator()

    // Обновление позиции индикатора
    function updateIndicator() {
        if (root.categories.length === 0)
            return

        var itemWidth = width / root.categories.length
        selectionIndicator.x = itemWidth * currentIndex + (itemWidth - selectionIndicator.width) / 2
        selectionIndicator.width = itemWidth * 0.6
    }

    onWidthChanged: updateIndicator()
    onCurrentIndexChanged: updateIndicator()
}
