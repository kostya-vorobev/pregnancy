import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Item {
    id: root
    width: parent.width
    height: parent.height

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14

    Rectangle {
        anchors.fill: parent
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
    }

    Flickable {
        anchors.fill: parent
        contentWidth: contentColumn.width
        contentHeight: contentColumn.height
        clip: true

        Column {
            id: contentColumn
            width: root.width - 40
            spacing: 20
            padding: 20

            // Заголовок
            Text {
                text: "Настройки уведомлений"
                font {
                    family: "Comfortaa"
                    pixelSize: Math.min(24, root.width * 0.07)
                    weight: Font.Bold
                }
                color: textColor
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            // Раздел основных уведомлений
            Column {
                width: parent.width
                spacing: 15

                Text {
                    text: "Основные уведомления"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(18, root.width * 0.05)
                        weight: Font.Bold
                    }
                    color: textColor
                }

                MyComponents.SwitchOption {
                    width: parent.width
                    label: "Разрешить уведомления"
                    checked: true
                }

                MyComponents.SwitchOption {
                    width: parent.width
                    label: "Звуковые уведомления"
                    checked: true
                }

                MyComponents.SwitchOption {
                    width: parent.width
                    label: "Вибрация"
                }
            }

            // Раздел напоминаний
            Column {
                width: parent.width
                spacing: 15

                Text {
                    text: "Напоминания"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(18, root.width * 0.05)
                        weight: Font.Bold
                    }
                    color: textColor
                }

                MyComponents.SwitchOption {
                    width: parent.width
                    label: "О приёме витаминов"
                    checked: true
                }

                MyComponents.SwitchOption {
                    width: parent.width
                    label: "О визитах к врачу"
                    checked: true
                }

                MyComponents.SwitchOption {
                    width: parent.width
                    label: "Об измерениях веса"
                }

                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Время напоминаний:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        width: parent.width
                        placeholderText: "Например, 09:00"
                        text: "09:00"
                    }
                }
            }

            // Кнопка сохранения
            MyComponents.CustomButton {
                width: parent.width
                text: "Сохранить настройки"
                onClicked: {
                    console.log("Настройки уведомлений сохранены")
                    stackView.pop()
                }
            }

            // Кнопка назад
            MyComponents.CustomButton {
                width: parent.width
                text: "Назад"
                buttonColor: "#e0e0e0"
                textColor: root.textColor
                onClicked: stackView.pop()
            }
        }
    }
}
