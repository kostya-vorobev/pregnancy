import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root
    padding: 20

    property int profileId: 1
    property DailyTip dailyTip: DailyTip {}

    // Свойство для отображения текущей недели
    property int displayWeek: pregnancyProgress.currentWeek > 0 ? pregnancyProgress.currentWeek : 1

    // Данные о беременности (C++ класс)
    PregnancyProgress {
        id: pregnancyProgress
        profileId: root.profileId

        onDataLoaded: {
            console.log("Текущая неделя беременности:", currentWeek)
            root.displayWeek = currentWeek > 0 ? currentWeek : 1
            updateDailyTip()
        }

        onCurrentWeekChanged: {
            root.displayWeek = currentWeek > 0 ? currentWeek : 1
            updateDailyTip()
        }
    }

    // Данные о неделе беременности (C++ класс)
    PregnancyWeek {
        id: weekInfo
        weekNumber: displayWeek
        onBaby3dModelChanged: update3dModel()
        onBabySizeImageChanged: updateSizeComparison()
    }

    function update3dModel() {
        baby3dImage.source = "qrc:/Images/" + weekInfo.baby3dModel + ".png"
                || "qrc:/Images/logo.png"
    }

    function updateSizeComparison() {
        sizeComparisonImage.source
                = weekInfo.babySizeImage ? "qrc:/Images/equal/" + weekInfo.babySizeImage
                                           + ".svg" : "qrc:/Images/equal/lemon.svg"
        sizeComparisonLabel.text = "Как " + (weekInfo.babySize || "неизвестно")
    }

    function updateDailyTip() {
        var trimester = Math.floor((displayWeek - 1) / 13) + 1
        var tips = DailyTip.getTipForTrimester(trimester)
        if (tips.length > 0) {
            var randomIndex = Math.floor(Math.random() * tips.length)
            dailyTip = tips[randomIndex]
        }
    }

    // Остальной интерфейс остается без изменений
    background: Rectangle {
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

    ColumnLayout {
        spacing: 20
        width: parent.width

        // 1. 3D модель плода
        Rectangle {
            id: baby3dContainer
            Layout.fillWidth: true
            height: 300
            radius: 10
            color: "#e91e63"
            border {
                color: "#9c27b0"
                width: 2
            }

            Image {
                id: baby3dImage
                anchors.fill: parent
                anchors.margins: 5
                source: "qrc:/Images/" + weekInfo.baby3dModel + ".png"
                        || "qrc:/Images/logo.png"
                fillMode: Image.PreserveAspectFit
            }

            Label {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: "Неделя " + displayWeek
                color: "white"
                font.bold: true
                padding: 5
            }
        }

        // 2. Прогресс беременности
        ColumnLayout {
            width: parent.width
            spacing: 5

            Label {
                text: "Прогресс беременности"
                font.bold: true
                color: "#4a148c"
            }

            MyComponents.ModernProgressBar {
                Layout.fillWidth: true
                weekNumber: displayWeek
                totalWeeks: 40
                startColor: "#9c27b0"
                endColor: "#e91e63"
                textColor: "white"
                bgColor: "#f0f0f0"
                showWeekIndicator: true
                showPercentage: true
            }

            Label {
                text: displayWeek + " из 40 недель (" + Math.round(
                          displayWeek / 40 * 100) + "%)"
                color: "#4a148c"
            }
        }

        // 3. Сравнение размера плода
        Pane {
            Layout.fillWidth: true
            padding: 10
            background: Rectangle {
                radius: 10
                color: "#e1f5fe"
                border.color: "#4fc3f7"
            }

            RowLayout {
                anchors.fill: parent
                spacing: 15

                Image {
                    id: sizeComparisonImage
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    source: weekInfo.babySizeImage ? "qrc:/Images/equal/" + weekInfo.babySizeImage
                                                     + ".svg" : "qrc:/Images/equal/lemon.svg"
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    Label {
                        text: "Размер вашего малыша:"
                        font.pixelSize: 12
                        color: "#0277bd"
                    }

                    Label {
                        id: sizeComparisonLabel
                        text: "Как " + (weekInfo.babySize || "неизвестно")
                        font {
                            bold: true
                            pixelSize: 16
                        }
                        color: "#4a148c"
                    }
                }
            }
        }

        // 5. Совет дня
        Pane {
            Layout.fillWidth: true
            padding: 10
            background: Rectangle {
                radius: 10
                color: "#f1f8e9"
                border.color: "#aed581"
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                RowLayout {
                    spacing: 10
                    Image {
                        source: "qrc:/Images/icons/lightbulb.svg"
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                    }
                    Label {
                        text: "Совет дня:"
                        font {
                            bold: true
                            pixelSize: 16
                        }
                        color: "#2e7d32"
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Label {
                        width: parent.width
                        text: dailyTip.tipText || "Загрузка совета..."
                        wrapMode: Text.WordWrap
                        color: "#4a148c"
                    }
                }

                Button {
                    text: "Обновить"
                    flat: true
                    Layout.alignment: Qt.AlignRight
                    onClicked: updateDailyTip()
                }
            }
        }

        // 6. Кнопка перехода к продуктам
        MyComponents.CustomButton {
            text: "Рекомендуемые продукты"
            Layout.fillWidth: true
            onClicked: stackView.push("qrc:/Screens/FoodInfoScreen.qml")
        }
    }

    Component.onCompleted: {
        if (profileId > 0) {
            pregnancyProgress.profileId = profileId
            pregnancyProgress.loadData()
        }
        var mainWin = ApplicationWindow.window
        if (mainWin)
            mainWin.showFooterRequested(true)
    }
}
