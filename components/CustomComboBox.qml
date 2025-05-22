import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: root
    width: parent.width
    height: 50

    property alias model: listView.model
    property string textRole: "" // Добавляем поддержку textRole
    property int currentIndex: -1
    property alias currentText: displayText.text
    property int fontSize: 16
    signal activated(int index)

    // Функция для получения текста из модели
    function getDisplayText(item) {
        if (textRole === "" || typeof item !== "object")
            return item
        return item[textRole] || ""
    }

    // Основной прямоугольник комбобокса
    Rectangle {
        id: mainRect
        width: parent.width
        height: parent.height
        radius: 8
        color: "#f5f5f5"
        border.color: "#e0e0e0"

        Text {
            id: displayText
            text: {
                if (currentIndex < 0)
                    return ""
                if (model && model.length > currentIndex) {
                    return getDisplayText(model[currentIndex])
                }
                return ""
            }
            font {
                family: "Comfortaa"
                pixelSize: fontSize
            }
            color: "#4a148c"
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 15
            }
        }

        // Стрелка индикатора
        Rectangle {
            id: arrowContainer
            width: 24
            height: 24
            radius: 4
            color: "transparent"
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 12
            }

            Image {
                id: arrowIcon
                source: "qrc:/Images/svg/arrow_down.svg"
                width: 16
                height: 16
                anchors.centerIn: parent
                sourceSize: Qt.size(width, height)

                layer.enabled: true

                states: [
                    State {
                        name: "opened"
                        when: popup.opened
                        PropertyChanges {
                            target: arrowIcon
                            rotation: 180
                        }
                    },
                    State {
                        name: "closed"
                        when: !popup.opened
                        PropertyChanges {
                            target: arrowIcon
                            rotation: 0
                        }
                    }
                ]

                transitions: Transition {
                    RotationAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: popup.opened ? popup.close() : popup.open()
        }
    }

    // Выпадающий список
    Popup {
        id: popup
        y: mainRect.height + 5
        width: mainRect.width
        height: Math.min(listView.contentHeight + 20, 200)
        padding: 0
        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            radius: 8
            color: "#ffffff"
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowVerticalOffset: 3
                shadowBlur: 0.3
            }
        }

        contentItem: ListView {
            id: listView
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            spacing: 2

            delegate: Rectangle {
                width: listView.width
                height: 40
                radius: 4
                color: root.currentIndex
                       === index ? "#e1bee7" : mouseArea.containsMouse ? "#f3e5f5" : "transparent"

                Text {
                    text: getDisplayText(modelData)
                    font {
                        family: "Comfortaa"
                        pixelSize: root.fontSize
                    }
                    color: "#4a148c"
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.currentIndex = index
                        root.activated(index)
                        popup.close()
                    }
                }
            }
        }
    }
}
