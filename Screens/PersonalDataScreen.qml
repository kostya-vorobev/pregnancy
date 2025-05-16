import QtQuick
import QtQuick.Controls
import "../components" as MyComponents
import PregnancyAppData 1.0

Item {
    id: root

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14

    property int currentProfileId: 1 // Добавляем ID профиля
    property string currentFirstName: ""
    property string currentLastName: ""
    property string currentMiddleName: ""
    property date currentDateBirth: new Date()
    property int currentGestationalAge: 1
    property int currentHeight: 0
    property double currentWeight: 0
    property string currentBloodType: ""
    property double currentInitialWeight: 0
    property double currentPrePregnancyWeight: 0
    property double currentWeightGainGoal: 0

    DatabaseHandler {
        id: dbHandler
        Component.onCompleted: {
            if (!dbHandler.initializeDatabase()) {
                console.error("Failed to initialize database")
            }
        }
    }
    function validateInput() {
        if (!firstNameField.text || !lastNameField.text) {
            console.error("Имя и фамилия обязательны для заполнения")
            return false
        }

        var height = parseInt(heightField.text)
        if (isNaN(height) || height <= 0 || height > 250) {
            console.error("Некорректный рост (должен быть от 1 до 250 см)")
            return false
        }

        var weight = parseFloat(weightField.text)
        if (isNaN(weight) || weight <= 0 || weight > 300) {
            console.error("Некорректный вес (должен быть от 1 до 300 кг)")
            return false
        }

        return true
    }
    function saveData() {
        if (!validateInput()) {
            return
        }
        // Установим значения по умолчанию для отсутствующих полей
        var success = dbHandler.savePersonalData(
                    currentProfileId, firstNameField.text,
                    lastNameField.text, middleNameField.text,
                    currentDateBirth, currentGestationalAge,
                    parseInt(heightField.text) || 0, parseFloat(
                        weightField.text) || 0.0, currentBloodType || "A+",
                    // Значение по умолчанию для группы крови
                    currentInitialWeight || 0.0,
                    currentPrePregnancyWeight || 0.0,
                    currentWeightGainGoal || 0.0)

        if (success) {
            var mainWin = ApplicationWindow.window
            if (mainWin)
                mainWin.showFooterRequested(true)
            stackView.clear()
            stackView.push("qrc:/Screens/HomeScreen.qml")
        } else {
            console.error("Ошибка сохранения данных")
            // Можно показать сообщение об ошибке пользователю
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
