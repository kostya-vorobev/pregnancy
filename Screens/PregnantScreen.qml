import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root
    height: parent.height
    width: parent.width
    visible: true

    property int profileId: 1
    property color textColor: "#4a148c"
    property color primaryColor: "#9c27b0"

    // Данные пользователя
    property Profile userProfile: Profile {
        id: profileData
        onDataLoaded: {
            console.log("Данные профиля загружены")
            pregnancyProgress.loadData()
        }
    }

    // Данные о беременности
    PregnancyProgress {
        id: pregnancyProgress
        profileId: profileData.id

        onDataLoaded: {
            console.log("Данные недели беременности загружены")
            updateUI()
        }

        onCurrentWeekChanged: {
            weekInfo.weekNumber = currentWeek
            updateUI()
        }
    }

    PregnancyWeek {
        id: weekInfo
        weekNumber: pregnancyProgress.currentWeek
    }

    function updateUI() {
        // Обновляем ComboBox при загрузке данных
        weekComboBox.currentIndex = pregnancyProgress.currentWeek
                > 0 ? pregnancyProgress.currentWeek - 1 : 0
        weekInfo.weekNumber = pregnancyProgress.currentWeek > 0 ? pregnancyProgress.currentWeek : 1
        updateWeekInfo(weekInfo.weekNumber)
    }

    function updateWeekInfo(week) {
        currentWeekText.text = "На " + week + " неделе:"
        babySizeText.text = "● Размер: " + (weekInfo.babySize || "неизвестно")
        babyLengthText.text = "● Длина: " + (weekInfo.babyLength || "0") + " см"
        babyWeightText.text = "● Вес: " + (weekInfo.babyWeight || "0") + " г"
        developmentDescriptionText.text = weekInfo.developmentDescription
                || "Описание недоступно"
    }

    function saveProgress() {
        // Обновляем текущую неделю из ComboBox
        pregnancyProgress.currentWeek = weekComboBox.currentIndex + 1

        if (pregnancyProgress.save()) {
            console.log("Данные беременности сохранены")
            return true
        }
        console.log("Ошибка сохранения данных беременности")
        return false
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
            id: flickable
            anchors.fill: parent
            contentWidth: contentColumn.width
            contentHeight: contentColumn.height
            clip: true

            Column {
                id: contentColumn
                spacing: 15
                padding: 20
                width: root.width - padding * 2

                Text {
                    text: "Ваша беременность"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(24, root.width * 0.07)
                        weight: Font.Bold
                    }
                    color: textColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // Выбор недели
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Срок беременности:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomComboBox {
                        id: weekComboBox
                        width: parent.width
                        model: Array.from({
                                              "length": 42
                                          }, (_, i) => `${i + 1} неделя`)
                        fontSize: Math.min(16, root.width * 0.045)
                        onCurrentIndexChanged: {
                            // Обновляем информацию сразу при изменении выбора
                            var selectedWeek = currentIndex + 1
                            weekInfo.weekNumber = selectedWeek
                            updateWeekInfo(selectedWeek)
                        }
                    }
                }

                // Информационный блок
                Rectangle {
                    width: parent.width
                    height: infoColumn.height + 30
                    radius: 8
                    color: "#f1f8e9"
                    border.color: "#dcedc8"

                    Column {
                        id: infoColumn
                        width: parent.width - 20
                        spacing: 8
                        anchors {
                            top: parent.top
                            left: parent.left
                            margins: 15
                        }

                        Text {
                            id: currentWeekText
                            text: "На " + pregnancyProgress.currentWeek + " неделе:"
                            font {
                                family: "Comfortaa"
                                pixelSize: Math.min(16, root.width * 0.045)
                                weight: Font.Bold
                            }
                            color: "#2e7d32"
                            width: parent.width
                        }

                        Text {
                            id: babySizeText
                            text: "● Размер: " + (weekInfo.babySize
                                                  || "неизвестно")
                            font {
                                family: "Comfortaa"
                                pixelSize: Math.min(14, root.width * 0.04)
                            }
                            color: "#2e7d32"
                            width: parent.width
                        }

                        Text {
                            id: babyLengthText
                            text: "● Длина: " + (weekInfo.babyLength
                                                 || "0") + " см"
                            font {
                                family: "Comfortaa"
                                pixelSize: Math.min(14, root.width * 0.04)
                            }
                            color: "#2e7d32"
                            width: parent.width
                        }

                        Text {
                            id: babyWeightText
                            text: "● Вес: " + (weekInfo.babyWeight
                                               || "0") + " г"
                            font {
                                family: "Comfortaa"
                                pixelSize: Math.min(14, root.width * 0.04)
                            }
                            color: "#2e7d32"
                            width: parent.width
                        }

                        Text {
                            id: developmentDescriptionText
                            text: weekInfo.developmentDescription
                                  || "Описание недоступно"
                            font {
                                family: "Comfortaa"
                                pixelSize: Math.min(14, root.width * 0.04)
                            }
                            color: "#2e7d32"
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // Кнопка подтверждения
                MyComponents.CustomButton {
                    width: parent.width
                    text: "Подтвердить"
                    fontSize: Math.min(16, root.width * 0.045)
                    onClicked: {
                        if (saveProgress()) {
                            if (typeof stackView !== 'undefined') {
                                stackView.push(
                                            "qrc:/Screens/PersonalDataScreen.qml")
                            }
                        }
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

    Component.onCompleted: {
        // Загружаем данные профиля при создании компонента
        profileData.id = profileId
        profileData.loadData()
    }
}
