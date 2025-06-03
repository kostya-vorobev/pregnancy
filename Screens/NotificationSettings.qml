import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root
    width: parent.width
    height: parent.height

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14

    property var notificationManager

    // Добавьте эту проверку
    onNotificationManagerChanged: {
        if (notificationManager) {
            console.log("NotificationManager is available")
            loadSettings()
        } else {
            console.error("NotificationManager is not available")
        }
    }

    function loadSettings() {
        notificationTimeField.text = Qt.formatTime(
                    notificationManager.notificationTime, "hh:mm")
        mainSwitch.checked = notificationManager.notificationsEnabled
        soundSwitch.checked = notificationManager.soundEnabled
        vibrationSwitch.checked = notificationManager.vibrationEnabled
        vitaminsSwitch.checked = notificationManager.vitaminsEnabled
        doctorSwitch.checked = notificationManager.doctorVisitsEnabled
        measurementsSwitch.checked = notificationManager.weightMeasurementsEnabled
    }

    Component.onCompleted: {
        if (notificationManager) {
            loadSettings()
        }
    }

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

            // Основные уведомления
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
                    id: mainSwitch
                    width: parent.width
                    label: "Разрешить уведомления"
                }

                MyComponents.SwitchOption {
                    id: soundSwitch
                    width: parent.width
                    label: "Звуковые уведомления"
                }

                MyComponents.SwitchOption {
                    id: vibrationSwitch
                    width: parent.width
                    label: "Вибрация"
                }
            }

            // Напоминания
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
                    id: vitaminsSwitch
                    width: parent.width
                    label: "О приёме витаминов"
                }

                MyComponents.SwitchOption {
                    id: doctorSwitch
                    width: parent.width
                    label: "О визитах к врачу"
                }

                MyComponents.SwitchOption {
                    id: measurementsSwitch
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
                        id: notificationTimeField
                        width: parent.width
                        placeholderTextValue: "Например, 09:00"
                        validator: RegularExpressionValidator {
                            regularExpression: /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/
                        }
                        onTextChanged: {
                            if (text.length === 2 && !text.includes(":")) {
                                text = text + ":"
                            }
                        }
                    }
                }
            }

            // Кнопки
            MyComponents.CustomButton {
                width: parent.width
                text: "Сохранить настройки"
                onClicked: {
                    if (!notificationManager) {
                        console.error("NotificationManager is not available")
                        return
                    }

                    // Преобразуем текст в QTime
                    var timeParts = notificationTimeField.text.split(":")
                    if (timeParts.length !== 2) {
                        console.error("Invalid time format")
                        return
                    }

                    var time = Qt.formatTime(new Date(0, 0, 0, timeParts[0],
                                                      timeParts[1]), "HH:mm")

                    notificationManager.saveSettings(time, mainSwitch.checked,
                                                     soundSwitch.checked,
                                                     vibrationSwitch.checked,
                                                     vitaminsSwitch.checked,
                                                     doctorSwitch.checked,
                                                     measurementsSwitch.checked)
                }
            }

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
