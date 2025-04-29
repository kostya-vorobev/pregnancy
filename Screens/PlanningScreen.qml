import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../components" as MyComponents

Rectangle {
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#f3e5f5"
        }
        GradientStop {
            position: 1.0
            color: "#e1bee7"
        }
    }

    // Основной контентный блок
    Rectangle {
        id: contentBox
        width: parent.width * 0.9
        height: parent.height * 0.7
        anchors.centerIn: parent
        radius: defaultRadius
        color: "#ffffff"

        MultiEffect {
            anchors.fill: parent
            source: contentBox
            shadowEnabled: true
            shadowColor: "#40000000"
            shadowVerticalOffset: shadowSize
            shadowBlur: 0.5
        }

        Column {
            anchors.centerIn: parent
            spacing: 25
            width: parent.width * 0.8

            Text {
                text: "Планирование беременности"
                font {
                    family: "Comfortaa"
                    pixelSize: 24
                    weight: Font.Bold
                }
                color: textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Блок с советами
            Repeater {
                model: [{
                        "icon": "calendar",
                        "text": "Отслеживайте цикл"
                    }, {
                        "icon": "vitamins",
                        "text": "Принимайте витамины"
                    }, {
                        "icon": "doctor",
                        "text": "Посетите врача"
                    }, {
                        "icon": "health",
                        "text": "Здоровый образ жизни"
                    }]

                delegate: Rectangle {
                    width: parent.width
                    height: 60
                    radius: 8
                    color: index % 2 === 0 ? "#f5f5f5" : "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Image {
                            source: "qrc:/Images/svg/" + modelData.icon + ".svg"
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter

                            MultiEffect {
                                anchors.fill: parent
                                source: parent
                                colorization: 1.0
                                colorizationColor: primaryColor
                            }
                        }

                        Text {
                            text: modelData.text
                            color: textColor
                            font {
                                family: "Comfortaa"
                                pixelSize: 16
                            }
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Кнопка полезных материалов
            Rectangle {
                id: materialsBtn
                width: parent.width
                height: 50
                radius: height / 2
                color: "#e1f5fe"

                MultiEffect {
                    anchors.fill: parent
                    source: materialsBtn
                    shadowEnabled: true
                    shadowColor: "#40000000"
                    shadowVerticalOffset: 2
                    shadowBlur: 0.2
                }

                Text {
                    text: "Полезные материалы"
                    color: "#0288d1"
                    anchors.centerIn: parent
                    font {
                        family: "Comfortaa"
                        pixelSize: 16
                        weight: Font.Medium
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Открываем материалы")
                        // Здесь переход на экран с материалами
                    }
                    hoverEnabled: true
                    onEntered: materialsBtn.scale = 0.98
                    onExited: materialsBtn.scale = 1.0
                }
            }

            // Кнопка назад
            MyComponents.CustomButton {
                width: parent.width
                text: "Назад"
                buttonColor: "#e0e0e0"
                textColor: root.textColor
                fontSize: Math.min(16, root.width * 0.045)
                onClicked: if (typeof stackView !== 'undefined')
                               stackView.pop()
            }
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }
}
