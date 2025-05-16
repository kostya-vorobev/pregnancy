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

    // Данные пользователя
    property string userName: "Иванова Анна"
    property string userEmail: "anna@example.com"
    property string userInfo: "28 лет, 12 неделя беременности"
    property url userAvatar: "https://via.placeholder.com/150"

    // Режим редактирования
    property bool editMode: false

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
            width: root.width
            spacing: 20
            padding: 20

            // Заголовок и кнопка редактирования
            Row {
                width: parent.width - (contentColumn.spacing * 2)
                spacing: 10

                Text {
                    text: "Мой профиль"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(24, root.width * 0.07)
                        weight: Font.Bold
                    }
                    color: textColor
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width - editButton.width - parent.spacing
                }

                MyComponents.CustomButton {
                    id: editButton
                    width: 120
                    height: 30
                    text: editMode ? "Отменить" : "Редактировать"
                    buttonColor: editMode ? "#e0e0e0" : primaryColor
                    textColor: editMode ? textColor : "white"
                    onClicked: {
                        editMode = !editMode
                        if (!editMode) {
                            // При отмене возвращаем исходные значения
                            pregnancyWeekField.text = "12"
                            dueDateField.text = "15.12.2023"
                            ageField.text = "28"
                            heightField.text = "165"
                            weightBeforeField.text = "58"
                        }
                    }
                }
            }

            // Аватар и основная информация
            Column {
                width: parent.width
                spacing: 15
                anchors.horizontalCenter: parent.horizontalCenter

                // Аватар
                Rectangle {
                    width: 120
                    height: 120
                    radius: width / 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        source: userAvatar
                        fillMode: Image.PreserveAspectCrop
                        layer.enabled: true
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: primaryColor
                        border.width: 3
                    }

                    MyComponents.CustomButton {
                        visible: editMode
                        width: 30
                        height: 30
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        text: "+"
                        radius: 15
                        onClicked: console.log("Изменить фото")
                    }
                }

                // Имя и информация
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: userName
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(22, root.width * 0.06)
                            weight: Font.Bold
                        }
                        color: textColor
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: userInfo
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Разделитель
            Rectangle {
                width: parent.width - (contentColumn.spacing * 2)
                height: 1
                color: Qt.lighter(primaryColor, 1.5)
                opacity: 0.5
            }

            // Блок с данными беременности
            Column {
                width: parent.width - (contentColumn.spacing * 2)
                spacing: 15

                Text {
                    text: "Данные беременности"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(18, root.width * 0.05)
                        weight: Font.Bold
                    }
                    color: textColor
                }

                // Срок беременности
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Срок беременности:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: pregnancyWeekField
                        width: parent.width
                        placeholderText: "Введите текущую неделю"
                        text: "12"
                        inputMethodHints: Qt.ImhDigitsOnly
                        visible: editMode
                        readOnly: !editMode
                        opacity: editMode ? 1.0 : 0.7
                    }

                    Text {
                        visible: !editMode
                        text: pregnancyWeekField.text + " недель"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }
                }

                // Дата родов
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Предполагаемая дата родов:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: dueDateField
                        width: parent.width
                        placeholderText: "ДД.ММ.ГГГГ"
                        text: "15.12.2023"
                        readOnly: !editMode
                        visible: editMode
                        opacity: editMode ? 1.0 : 0.7
                    }

                    Text {
                        visible: !editMode
                        text: dueDateField.text
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }
                }
            }

            // Разделитель
            Rectangle {
                width: parent.width - (contentColumn.spacing * 2)
                height: 1
                color: Qt.lighter(primaryColor, 1.5)
                opacity: 0.5
            }

            // Блок с личными данными
            Column {
                width: parent.width - (contentColumn.spacing * 2)
                spacing: 15

                Text {
                    text: "Личные данные"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(18, root.width * 0.05)
                        weight: Font.Bold
                    }
                    color: textColor
                }

                // Возраст
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Возраст:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: ageField
                        width: parent.width
                        placeholderText: "Введите ваш возраст"
                        text: "28"
                        inputMethodHints: Qt.ImhDigitsOnly
                        readOnly: !editMode
                        visible: editMode
                        opacity: editMode ? 1.0 : 0.7
                    }

                    Text {
                        visible: !editMode
                        text: ageField.text + " лет"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }
                }

                // Рост
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
                        text: "165"
                        inputMethodHints: Qt.ImhDigitsOnly
                        readOnly: !editMode
                        visible: editMode
                        opacity: editMode ? 1.0 : 0.7
                    }

                    Text {
                        visible: !editMode
                        text: heightField.text + " см"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }
                }

                // Вес до беременности
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Вес до беременности (кг):"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: weightBeforeField
                        width: parent.width
                        placeholderText: "Введите ваш вес"
                        text: "58"
                        inputMethodHints: Qt.ImhDigitsOnly
                        readOnly: !editMode
                        visible: editMode
                        opacity: editMode ? 1.0 : 0.7
                    }

                    Text {
                        visible: !editMode
                        text: weightBeforeField.text + " кг"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }
                }
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Группа крови:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: bloodTypeField
                        width: parent.width
                        placeholderText: "Введите вашу группу крови"
                        text: "58"
                        inputMethodHints: Qt.ImhDigitsOnly
                        readOnly: !editMode
                        visible: editMode
                        opacity: editMode ? 1.0 : 0.7
                    }

                    Text {
                        visible: !editMode
                        text: bloodTypeField.text
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }
                }
            }

            // Кнопки действий
            Column {
                width: parent.width - (contentColumn.spacing * 2)
                spacing: 10

                MyComponents.CustomButton {
                    width: parent.width
                    text: "Сохранить изменения"
                    visible: editMode
                    onClicked: {
                        console.log("Данные сохранены:",
                                    pregnancyWeekField.text, dueDateField.text,
                                    ageField.text, heightField.text,
                                    weightBeforeField.text)
                        editMode = false
                    }
                }

                MyComponents.CustomButton {
                    width: parent.width
                    text: "Настройки уведомлений"
                    textColor: textColor
                    onClicked: stackView.push(
                                   "qrc:/Screens/NotificationSettings.qml")
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
}
