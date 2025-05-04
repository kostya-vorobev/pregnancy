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

        ColumnLayout {
            id: contentColumn
            width: root.width
            spacing: 20

            Text {
                text: "Мой дневник"
                font {
                    family: "Comfortaa"
                    pixelSize: Math.min(24, root.width * 0.07)
                    weight: Font.Bold
                }
                color: textColor
                Layout.alignment: Qt.AlignHCenter
            }

            // Первый ряд
            GridLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                columnSpacing: 15
                rowSpacing: 15
                Layout.fillWidth: true

                MyComponents.MenuTile {
                    iconSource: "qrc:/Images/icons/checklist.svg"
                    title: "Чеклист"
                    subtitle: "беременности"
                    tileColor: "#8e24aa"
                    onClicked: stackView.push(
                                   "qrc:/Screens/PregnancyChecklist.qml")
                    Layout.preferredWidth: (root.width - 40 - parent.columnSpacing) / 2
                    Layout.preferredHeight: Layout.preferredWidth * 1.2
                }

                MyComponents.MenuTile {
                    iconSource: "qrc:/Images/icons/dumbbell.svg"
                    title: "Упражнения"
                    subtitle: "для беременных"
                    tileColor: "#7b1fa2"
                    onClicked: stackView.push(
                                   "qrc:/Screens/PregnancyExercises.qml")
                    Layout.preferredWidth: (root.width - 40 - parent.columnSpacing) / 2
                    Layout.preferredHeight: Layout.preferredWidth * 1.2
                }

                // Второй ряд
                MyComponents.MenuTile {
                    iconSource: "qrc:/Images/icons/idea.svg"
                    title: "Советы"
                    subtitle: "при беременности"
                    tileColor: "#6a1b9a"
                    onClicked: stackView.push("qrc:/Screens/PregnancyTips.qml")
                    Layout.preferredWidth: (root.width - 40 - parent.columnSpacing) / 2
                    Layout.preferredHeight: Layout.preferredWidth * 1.2
                }

                MyComponents.MenuTile {
                    iconSource: "qrc:/Images/icons/article.svg"
                    title: "Статьи"
                    subtitle: "и полезные материалы"
                    tileColor: "#5c148c"
                    onClicked: stackView.push(
                                   "qrc:/Screens/PregnancyArticles.qml")
                    Layout.preferredWidth: (root.width - 40 - parent.columnSpacing) / 2
                    Layout.preferredHeight: Layout.preferredWidth * 1.2
                }

                // Третий ряд
                MyComponents.MenuTile {
                    iconSource: "qrc:/Images/icons/scales.svg"
                    title: "Взвешивание"
                    subtitle: "контроль веса"
                    tileColor: "#4a1078"
                    onClicked: stackView.push("qrc:/Screens/WeightTracking.qml")
                    Layout.preferredWidth: (root.width - 40 - parent.columnSpacing) / 2
                    Layout.preferredHeight: Layout.preferredWidth * 1.2
                }

                MyComponents.MenuTile {
                    iconSource: "qrc:/Images/icons/counter.svg"
                    title: "Счетчик"
                    subtitle: "толчков малыша"
                    tileColor: "#38006b"
                    onClicked: stackView.push("qrc:/Screens/KickCounter.qml")
                    Layout.preferredWidth: (root.width - 40 - parent.columnSpacing) / 2
                    Layout.preferredHeight: Layout.preferredWidth * 1.2
                }
            }
        }
    }
}
