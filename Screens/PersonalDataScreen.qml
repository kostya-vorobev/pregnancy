import QtQuick
import QtQuick.Controls
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root

    property int profileId: 1

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14

    property Profile userProfile: Profile {
        id: profile
        onDataLoaded: loadFormData()
    }

    // Загрузка данных при создании
    Component.onCompleted: {
        if (profileId > 0) {
            profile.id = profileId
            profile.loadData()
        }
    }

    // Заполнение формы данными из профиля
    function loadFormData() {
        firstNameField.text = profile.lastName
        lastNameField.text = profile.firstName
        middleNameField.text = profile.middleName
        heightField.text = profile.height > 0 ? profile.height : ""
        weightField.text = profile.weight > 0 ? profile.weight : ""
    }

    // Сохранение данных
    function saveData() {
        profile.lastName = firstNameField.text
        profile.firstName = lastNameField.text
        profile.middleName = middleNameField.text
        profile.height = parseInt(heightField.text) || 0
        profile.weight = parseFloat(weightField.text) || 0

        if (profile.save()) {
            stackView.push("qrc:/Screens/HomeScreen.qml")
        } else {
            errorMessage.open()
        }
    }

    // Сообщения
    Popup {
        id: savedMessage
        anchors.centerIn: parent
        Text {
            text: "Данные сохранены!"
        }
    }

    Popup {
        id: errorMessage
        anchors.centerIn: parent
        Text {
            text: "Ошибка сохранения!"
            color: "red"
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

                // Поле для Фамилии
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
                        text: profile.firstName
                    }
                }

                // Поле для Имя
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
                        text: profile.lastName
                    }
                }

                // Поле для Отчества
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Отчество:"
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
                        text: profile.middleName
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
                        text: profile.height
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
                        text: profile.weight
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
                    anchors.centerIn: parent.Center
                    text: "Сохранить"
                    onClicked: {
                        saveData()
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
