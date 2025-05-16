import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root
    objectName: "home"
    property string source: "qrc:/Screens/HomeScreen.qml"

    PregnancyData {
        id: pregnancyData
        // Загружаем данные для профиля с ID 1 при создании компонента
        Component.onCompleted: loadData(1)
    }

    Rectangle {
        anchors.fill: parent
        color: "#f3e5f5"
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
            contentHeight: contentColumn.height + 40
            clip: true

            ColumnLayout {
                id: contentColumn
                width: parent.width - 40
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter

                // 1. 3D модель плода
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    Layout.fillWidth: true
                    height: 300
                    color: "#e91e63"
                    radius: 10
                    border.color: "#9c27b0"
                    border.width: 2

                    Image {
                        anchors.fill: parent
                        anchors.margins: 5
                        source: "qrc:/Images/logo.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Неделя " + pregnancyData.currentWeek
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

                    ProgressBar {
                        id: pregnancyProgress
                        Layout.fillWidth: true
                        value: pregnancyData.currentWeek / 40
                        background: Rectangle {
                            radius: 3
                            color: "#e0e0e0"
                        }

                        Rectangle {
                            width: pregnancyProgress.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#9c27b0"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: "#e91e63"
                                }
                            }
                        }
                    }

                    Label {
                        text: pregnancyData.currentWeek + " из 40 недель (" + Math.round(
                                  pregnancyData.currentWeek / 40 * 100) + "%)"
                        color: "#4a148c"
                    }
                }

                // 3. Сравнение размера плода
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    radius: 10
                    color: "#e1f5fe"
                    border.color: "#4fc3f7"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        Image {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            source: "qrc:/Images/equal/" + pregnancyData.babySizeImage + ".svg"
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
                                text: "Как " + pregnancyData.babySize
                                font.bold: true
                                font.pixelSize: 16
                                color: "#4a148c"
                            }
                        }
                    }
                }

                // 4. Совет дня
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    radius: 10
                    color: "#f1f8e9"
                    border.color: "#aed581"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        Label {
                            text: "Совет дня:"
                            font.bold: true
                            color: "#2e7d32"
                        }

                        Label {
                            text: pregnancyData.dailyTip
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            color: "#4a148c"
                        }
                    }
                }

                // 5. Кнопка перехода к продуктам
                MyComponents.CustomButton {
                    Layout.topMargin: 10
                    width: parent.width
                    text: "Рекомендуемые продукты"
                    onClicked: stackView.push("qrc:/Screens/FoodInfoScreen.qml")
                }
            }
        }
    }
}
