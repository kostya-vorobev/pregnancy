import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Page {
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

    header: ToolBar {
        background: Rectangle {
            color: "#9c27b0"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 20

            ToolButton {
                icon.source: "qrc:/Images/svg/arrow_down.svg"
                icon.color: "white"
                onClicked: stackView.pop()
            }

            Label {
                text: "Чеклист беременности"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                color: "white"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
        }
    }

    ScrollView {
        anchors.fill: parent
        padding: 15
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 15

            // Первый триместр
            MyComponents.ChecklistSection {
                title: "Первый триместр (1-12 недель)"
                Layout.fillWidth: true
            }

            Repeater {
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

                delegate: MyComponents.ChecklistItem {
                    text: model.text
                    checked: model.checked
                    onCheckedChanged: model.checked = checked
                    Layout.fillWidth: true
                    indicatorColor: "#e1bee7"
                }
            }

            // Второй триместр
            MyComponents.ChecklistSection {
                Layout.topMargin: 20
                title: "Второй триместр (13-27 недель)"
                Layout.fillWidth: true
            }

            Repeater {
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

                delegate: MyComponents.ChecklistItem {
                    text: model.text
                    checked: model.checked
                    onCheckedChanged: model.checked = checked
                    Layout.fillWidth: true
                    indicatorColor: "#ce93d8"
                }
            }

            // Третий триместр
            MyComponents.ChecklistSection {
                Layout.topMargin: 20
                title: "Третий триместр (28-40 недель)"
                Layout.fillWidth: true
            }

            Repeater {
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

                delegate: MyComponents.ChecklistItem {
                    text: model.text
                    checked: model.checked
                    onCheckedChanged: model.checked = checked
                    Layout.fillWidth: true
                    indicatorColor: "#ba68c8"
                }
            }

            // Общие рекомендации
            MyComponents.ChecklistSection {
                Layout.topMargin: 20
                title: "Общие рекомендации"
                Layout.fillWidth: true
            }

            Repeater {
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

                delegate: MyComponents.ChecklistItem {
                    text: model.text
                    checked: model.checked
                    onCheckedChanged: model.checked = checked
                    Layout.fillWidth: true
                    indicatorColor: "#ab47bc"
                }
            }
        }
    }
}
