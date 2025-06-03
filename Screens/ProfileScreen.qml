import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root
    width: parent.width
    height: parent.height

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14

    property string userName: "Иванова Анна"
    property string userInfo: "12 неделя беременности"
    property url userAvatar: "https://via.placeholder.com/150"

    // Данные пользователя
    property Profile userProfile: Profile {
        id: profileData
        onDataLoaded: {
            console.log("Данные профиля загружены")
            pregnancyProgressData.loadData()
        }
        onProfilePhotoChanged: {
            if (profilePhoto) {
                avatarImage.source = profilePhoto
                if (profilePhoto.toString().startsWith("file:")) {
                    userAvatar = profilePhoto
                } else {
                    userAvatar = "file:" + profilePhoto
                }
            }
        }
    }

    PregnancyProgress {
        id: pregnancyProgressData
        profileId: profileData.id
        onDataLoaded: {
            console.log("Данные профиля загружены")
            updateUI()
        }
    }

    // Инициализация - загрузка данных профиля
    Component.onCompleted: {
        // Загружаем профиль с ID=1 (можно сделать параметром)
        profileData.id = 1
        profileData.loadData()
    }

    FileDialog {
        id: fileDialog
        title: "Выберите изображение профиля"
        currentFolder: StandardPaths.standardLocations(
                           StandardPaths.PicturesLocation)[0]
        nameFilters: ["Изображения (*.png *.jpg *.jpeg)"]
        onAccepted: {
            // Используйте прямое присваивание свойства вместо вызова метода
            profileData.profilePhoto = selectedFile
            profileData.save()
        }
    }
    function updateUI() {
        // Обновляем все поля интерфейса при загрузке данных
        userName = profileData.lastName + " " + profileData.firstName
        if (profileData.middleName.length > 0)
            userName += " " + profileData.middleName
        userAvatar = profileData.profilePhoto
        birthDateField.text = profileData.dateBirth ? Qt.formatDate(
                                                          profileData.dateBirth,
                                                          "dd.MM.yyyy") : ""
        dueDateField.text = pregnancyProgressData.estimatedDueDate ? Qt.formatDate(
                                                                         pregnancyProgressData.estimatedDueDate,
                                                                         "dd.MM.yyyy") : ""
        heightField.text = profileData.height > 0 ? profileData.height : 0
        weightBeforeField.text = profileData.weight.toFixed(
                    1) > 0 ? profileData.weight.toFixed(1) : 0
        bloodTypeField.text = profileData.bloodType > 0 ? profileData.bloodType : 0

        userInfo = (pregnancyProgressData.currentWeek) + " неделя беременности"
        pregnancyWeekField.text = (pregnancyProgressData.currentWeek)
    }

    function calculateAge(birthDate) {
        var today = new Date()
        var birth = new Date(birthDate)
        var age = today.getFullYear() - birth.getFullYear()
        var m = today.getMonth() - birth.getMonth()
        if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) {
            age--
        }
        return age
    }

    function saveProfile() {
        // Обновляем модель перед сохранением
        profileData.dateBirth = new Date(birthDateField.text)
        profileData.height = parseInt(heightField.text)
        profileData.weight = parseFloat(weightBeforeField.text)
        profileData.bloodType = bloodTypeField.text

        if (profileData.save()) {
            editMode = false
            console.log("Профиль успешно сохранен")
        } else {
            console.log("Ошибка сохранения профиля")
        }
    }

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

                    Rectangle {
                        id: mask
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        visible: false // Маска не должна быть видима сама по себе
                    }

                    // Исходное изображение
                    Image {
                        id: avatarImage
                        asynchronous: true
                        anchors.fill: parent
                        source: userAvatar
                        fillMode: Image.PreserveAspectCrop
                        visible: false // Скрываем оригинальное изображение, так как будем использовать маскированную версию
                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = "qrc:/Images/avatar/default-avatar.png"
                            }
                        }
                    }

                    // Применяем маску к изображению
                    OpacityMask {
                        anchors.fill: parent
                        source: avatarImage
                        maskSource: mask
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
                        onClicked: fileDialog.open()
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
                        placeholderTextValue: "Введите текущую неделю"
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
                        placeholderTextValue: "ДД.ММ.ГГГГ"
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
                        text: "Дата рождения:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomTextField {
                        id: birthDateField
                        width: parent.width
                        placeholderTextValue: "ДД.ММ.ГГГГ"
                        text: ""
                        readOnly: !editMode
                        visible: editMode
                        opacity: editMode ? 1.0 : 0.7
                        inputMethodHints: Qt.ImhDate
                        validator: RegularExpressionValidator {
                            regularExpression: /^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[012])\.(19|20)\d\d$/
                        }
                    }

                    Text {
                        visible: !editMode
                        text: birthDateField.text || "Не указана"
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
                        placeholderTextValue: "Введите ваш рост"
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
                        placeholderTextValue: "Введите ваш вес"
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
                        placeholderTextValue: "Введите вашу группу крови"
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
                        saveProfile()
                    }
                }

                MyComponents.CustomButton {
                    width: parent.width
                    text: "Настройки уведомлений"
                    textColor: textColor
                    onClicked: stackView.push(
                                   "qrc:/Screens/NotificationSettings.qml", {
                                       "notificationManager": notificationManager
                                   })
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
