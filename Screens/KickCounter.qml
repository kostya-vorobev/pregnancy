import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQml.Models
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material
import "../components" as MyComponents

Page {
    id: root
    padding: 20

    property int kickCount: 0
    property ListModel kickHistory: ListModel {}
    property string lastKickTime: ""

    background: Rectangle {
        color: "#faf4ff"
    }

    // Функция для добавления записи в историю
    function addHistoryEntry(saved) {
        var currentDate = new Date()
        kickHistory.insert(0, {
                               "time": currentDate.toLocaleTimeString(
                                           Qt.locale(), "hh:mm"),
                               "date": currentDate.toLocaleDateString(
                                           Qt.locale(), Locale.ShortFormat),
                               "count": kickCount,
                               "saved": saved || false
                           })

        // Ограничиваем историю 50 записями
        if (kickHistory.count > 50) {
            kickHistory.remove(50)
        }
    }
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#e1bee7"

    header: ToolBar {
        Material.foreground: "white"
        background: Rectangle {
            color: root.primaryColor
        }

        RowLayout {
            anchors.fill: parent
            ToolButton {
                icon.source: "qrc:/Images/icons/arrow_back.svg"
                onClicked: stackView.pop()
            }
            Label {
                text: "Толчки малыша"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                Layout.fillWidth: true
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        // Основной счетчик
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            width: 200
            height: 200
            radius: width / 2
            color: "#f3e5f5"
            border.color: "#ba68c8"
            border.width: 4

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowVerticalOffset: 4
                shadowBlur: 8
            }

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "Толчков"
                    font {
                        pixelSize: 16
                        family: "Comfortaa"
                    }
                    color: "#7b1fa2"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: root.kickCount
                    font {
                        pixelSize: 48
                        bold: true
                        family: "Comfortaa"
                    }
                    color: "#9c27b0"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    visible: root.lastKickTime !== ""
                    text: "Последний: " + root.lastKickTime
                    font.pixelSize: 12
                    color: "#ab47bc"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.kickCount++
                    root.lastKickTime = new Date().toLocaleTimeString(
                                Qt.locale(), "hh:mm")
                }
            }
        }

        // Кнопки управления
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            MyComponents.CustomButton {
                id: resetButton
                text: "Сбросить"
                Layout.preferredWidth: 120
                Layout.preferredHeight: 48

                onClicked: {
                    root.kickCount = 0
                    root.lastKickTime = ""
                }
            }

            MyComponents.CustomButton {
                id: saveButton
                text: "Сохранить"
                Layout.preferredWidth: 120
                Layout.preferredHeight: 48

                onClicked: {
                    if (root.kickCount > 0) {
                        root.addHistoryEntry(true)
                        root.kickCount = 0
                        root.lastKickTime = ""
                    }
                }
            }
        }

        // История
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Label {
                text: "История наблюдений"
                font {
                    family: "Comfortaa"
                    pixelSize: 18
                    bold: true
                }
                color: "#7b1fa2"
                Layout.alignment: Qt.AlignLeft
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#ffffff"
                border.color: "#e1bee7"
                border.width: 1

                ListView {
                    id: historyList
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    model: root.kickHistory
                    spacing: 4

                    delegate: Rectangle {
                        width: historyList.width
                        height: 48
                        radius: 8
                        color: saved ? "#f3e5f5" : "#faf4ff"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 16

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: date + " в " + time
                                    font {
                                        pixelSize: 14
                                        family: "Roboto"
                                    }
                                    color: "#4a148c"
                                }

                                Text {
                                    visible: saved
                                    text: "Сохраненный результат"
                                    font {
                                        pixelSize: 11
                                        family: "Roboto"
                                        italic: true
                                    }
                                    color: "#7b1fa2"
                                }
                            }

                            Text {
                                text: count + " толчков"
                                font {
                                    pixelSize: 16
                                    family: "Comfortaa"
                                    bold: true
                                }
                                color: "#9c27b0"
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
    }

    // Подсказка
    Label {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 16
        }
        text: "Нажимайте на круг при каждом толчке малыша"
        font.pixelSize: 12
        color: "#ab47bc"
    }
}
