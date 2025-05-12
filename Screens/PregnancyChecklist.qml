import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../components" as MyComponents

Page {
    id: root
    padding: 16

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
                text: "Чеклист беременности"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                Layout.fillWidth: true
            }
        }
    }
    Flickable {
        anchors.fill: parent
        anchors.top: headerBar.bottom + 10
        contentHeight: contentColumn.height
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 20

            // Первый триместр
            PregnancyTrimesterSection {
                id: firstTrimester
                title: "Первый триместр (1-12 недель)"
                indicatorColor: "#e1bee7"
                model: ListModel {
                    ListElement {
                        text: "Встать на учет в ЖК"
                        checked: false
                    }
                    ListElement {
                        text: "Сдать общий анализ крови"
                        checked: false
                    }
                    ListElement {
                        text: "Сдать анализ мочи"
                        checked: false
                    }
                    ListElement {
                        text: "Первый скрининг (УЗИ + биохимия)"
                        checked: false
                    }
                }
            }

            // Второй триместр
            PregnancyTrimesterSection {
                id: secondTrimester
                title: "Второй триместр (13-27 недель)"
                indicatorColor: "#ce93d8"
                model: ListModel {
                    ListElement {
                        text: "Второй скрининг (УЗИ)"
                        checked: false
                    }
                    ListElement {
                        text: "Анализ на глюкозу"
                        checked: false
                    }
                    ListElement {
                        text: "Посещение стоматолога"
                        checked: false
                    }
                    ListElement {
                        text: "Курсы для беременных"
                        checked: false
                    }
                }
            }

            // Третий триместр
            PregnancyTrimesterSection {
                id: thirdTrimester
                title: "Третий триместр (28-40 недель)"
                indicatorColor: "#ba68c8"
                model: ListModel {
                    ListElement {
                        text: "Третий скрининг (УЗИ)"
                        checked: false
                    }
                    ListElement {
                        text: "КТГ плода"
                        checked: false
                    }
                    ListElement {
                        text: "Собрать сумку в роддом"
                        checked: false
                    }
                    ListElement {
                        text: "Выбрать роддом"
                        checked: false
                    }
                }
            }

            // Общие рекомендации
            PregnancyTrimesterSection {
                id: generalRecommendations
                title: "Общие рекомендации"
                indicatorColor: "#ab47bc"
                model: ListModel {
                    ListElement {
                        text: "Принимать витамины"
                        checked: false
                    }
                    ListElement {
                        text: "Следить за питанием"
                        checked: false
                    }
                    ListElement {
                        text: "Выполнять упражнения"
                        checked: false
                    }
                    ListElement {
                        text: "Контролировать вес"
                        checked: false
                    }
                }
            }
        }
    }

    // Компонент секции триместра
    component PregnancyTrimesterSection: ColumnLayout {
        id: sectionRoot
        property string title
        property color indicatorColor
        property ListModel model

        Layout.fillWidth: true
        spacing: 8

        // Заголовок секции с прогрессом
        Rectangle {
            id: header
            Layout.fillWidth: true
            height: 56
            radius: 12
            color: Qt.lighter(indicatorColor, 1.4)

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 8
                samples: 16
                color: "#20000000"
                verticalOffset: 2
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                // Иконка триместра
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: sectionRoot.indicatorColor

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (sectionRoot.title.includes("Первый"))
                                return "1"
                            if (sectionRoot.title.includes("Второй"))
                                return "2"
                            if (sectionRoot.title.includes("Третий"))
                                return "3"
                            return "★"
                        }
                        color: "white"
                        font {
                            pixelSize: 16
                            bold: true
                        }
                    }
                }

                // Название триместра с ограничением ширины
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: titleText.implicitHeight

                    Text {
                        id: titleText
                        anchors.right: progressBar.left
                        anchors.left: parent.left
                        text: sectionRoot.title
                        font {
                            pixelSize: 16
                            bold: true
                            family: "Comfortaa"
                        }
                        color: "#4a148c"
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    // Индикатор прогресса
                    ProgressIndicator {
                        id: progressBar
                        width: 80
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        progress: {
                            var completed = 0
                            for (var i = 0; i < sectionRoot.model.count; i++) {
                                if (sectionRoot.model.get(i).checked)
                                    completed++
                            }
                            return completed / sectionRoot.model.count
                        }
                        color: sectionRoot.indicatorColor
                    }
                }
            }
        }

        // Элементы чеклиста
        Repeater {
            model: sectionRoot.model
            delegate: MyComponents.ChecklistItem {
                text: model.text
                checked: model.checked
                onCheckedChanged: model.checked = checked
                Layout.fillWidth: true
                indicatorColor: sectionRoot.indicatorColor

                // Анимация появления
                opacity: 0
                NumberAnimation on opacity {
                    from: 0
                    to: 1
                    duration: 300
                    running: true
                }
            }
        }
    }
    // Компонент индикатора прогресса
    component ProgressIndicator: Item {
        property real progress: 0
        property color color: "#9c27b0"
        implicitWidth: 64
        implicitHeight: 24

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "#e0e0e0"
        }

        Rectangle {
            width: parent.width * parent.progress
            height: parent.height
            radius: height / 2
            color: parent.color
            Behavior on width {
                NumberAnimation {
                    duration: 300
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: Math.round(parent.progress * 100) + "%"
            font {
                pixelSize: 10
                bold: true
            }
            color: "#4a148c"
        }
    }
}
