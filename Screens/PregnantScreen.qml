import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../components" as MyComponents
import PregnancyAppData 1.0

Item {
    id: root
    height: parent.height
    width: parent.width
    visible: true

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14
    property int currentWeek: 1
    property int currentProfileId: 1
    property var weekInfo: ({})
    property bool dbReady: false

    DatabaseHandler {
        id: dbHandler
        Component.onCompleted: {
            dbHandler.initializeDatabase()
            dbReady = dbHandler.isInitialized()
            if (dbReady) {
                currentWeek = dbHandler.getCurrentWeek(currentProfileId)
                loadWeekData()
            }
        }
    }

    function loadWeekData() {
        weekInfo = dbHandler.getWeekInfo(currentWeek)
    }

    function saveCurrentWeek() {
        if (dbReady) {
            console.log("Saving week:", currentWeek)
            var success = dbHandler.savePregnancyData(currentProfileId,
                                                      currentWeek)
            console.log("Save result:", success)

            // Проверяем, что данные сохранились
            var savedWeek = dbHandler.getCurrentWeek(currentProfileId)
            console.log("Saved week in DB:", savedWeek)
        } else {
            console.error("Database not ready")
        }
    }

    Connections {
        target: weekComboBox
        function onActivated(index) {
            currentWeek = index + 1
            loadWeekData()
            saveCurrentWeek()
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
            id: flickable
            anchors.fill: parent
            contentWidth: contentColumn.width
            contentHeight: contentColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

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
                        currentIndex: currentWeek - 1
                        fontSize: Math.min(16, root.width * 0.045)
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
                            text: "На " + currentWeek + " неделе:"
                            font {
                                family: "Comfortaa"
                                pixelSize: Math.min(16, root.width * 0.045)
                                weight: Font.Bold
                            }
                            color: "#2e7d32"
                            width: parent.width
                        }

                        Text {
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
                            text: weekInfo.description || "Описание недоступно"
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
                        saveCurrentWeek()
                        stackView.push("qrc:/Screens/PersonalDataScreen.qml")
                    }
                }

                // Кнопка назад
                MyComponents.CustomButton {
                    width: parent.width
                    text: "Назад"
                    buttonColor: "#e0e0e0"
                    textColor: root.textColor
                    fontSize: Math.min(16, root.width * 0.045)
                    onClicked: {
                        saveCurrentWeek()
                        if (typeof stackView !== 'undefined')
                            stackView.pop()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("Размеры экрана:", Screen.width, "x", Screen.height)
        console.log("Размеры окна:", width, "x", height)

        // Инициализация базы данных и загрузка данных
        dbReady = dbHandler.initializeDatabase()
        if (dbReady) {
            currentWeek = dbHandler.getCurrentWeek(currentProfileId)
            weekComboBox.currentIndex = currentWeek - 1
            loadWeekData()
        }
    }
}
