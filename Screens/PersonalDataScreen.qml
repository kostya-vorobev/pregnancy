import QtQuick
import QtQuick.Controls
import "../components" as MyComponents

Item {
    id: root

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

        Flickable {
            anchors.fill: parent
            contentWidth: contentColumn.width
            contentHeight: contentColumn.height
            clip: true

            Column {
                id: contentColumn
                width: root.width - 40
                spacing: 15
                padding: 20

                Text {
                    text: "Основные данные"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(24, root.width * 0.07)
                        weight: Font.Bold
                    }
                    color: textColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // Поле для ФИО
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Фамилия:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: firstNameField
                        width: parent.width
                        placeholderText: "Введите вашу фамилию"
                    }
                }

                // Поле для ФИО
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Имя:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: lastNameField
                        width: parent.width
                        placeholderText: "Введите ваше имя"
                    }
                }

                // Поле для ФИО
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "ФИО:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: middleNameField
                        width: parent.width
                        placeholderText: "Введите ваше отчество"
                    }
                }

                // Поле для роста
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Рост (см):"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: heightField
                        width: parent.width
                        placeholderText: "Введите ваш рост"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }

                // Поле для веса
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Вес (кг):"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: weightField
                        width: parent.width
                        placeholderText: "Введите ваш вес"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }
                Component.onCompleted: {
                    var mainWin = ApplicationWindow.window
                    if (mainWin) {
                        mainWin.showFooterRequested.connect(function (show) {
                            mainWin.showFooter = show
                        })
                    }
                }

                // Кнопка сохранения
                MyComponents.CustomButton {
                    width: parent.width
                    text: "Сохранить"
                    onClicked: {
                        console.log("Данные сохранены:", firstNameField.text,
                                    lastNameField.text, middleNameField.text,
                                    heightField.text, weightField.text)

                        var mainWin = ApplicationWindow.window
                        if (mainWin)
                            mainWin.showFooterRequested(true)
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
}
