import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import "../components" as MyComponents

Page {
    id: root
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#e1bee7"

    background: Rectangle {
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#f3e5f5"
            }
            GradientStop {
                position: 1.0
                color: secondaryColor
            }
        }
    }

    property var weightData: []
    property date currentDate: new Date()

    header: ToolBar {
        Material.foreground: "white"
        background: Rectangle {
            color: primaryColor
        }

        RowLayout {
            anchors.fill: parent
            ToolButton {
                icon.source: "qrc:/Images/icons/arrow_back.svg"
                onClicked: stackView.pop()
            }
            Label {
                text: "Контроль веса"
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
        anchors {
            fill: parent
            topMargin: 20
            bottomMargin: 20
        }
        contentHeight: contentColumn.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: contentColumn
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 25

            // Карточка графика
            MyComponents.WeightChartCard {
                id: chartCard
                Layout.fillWidth: true
                weightData: root.weightData
                chartColor: primaryColor
            }

            // Таблица с данными
            MyComponents.WeightDataTable {
                id: dataTable
                Layout.fillWidth: true
                weightData: root.weightData
                primaryColor: root.primaryColor
                secondaryColor: "#f3e5f5"
            }

            // Кнопка добавления
            MyComponents.CustomButton {
                id: addButton
                Layout.fillWidth: true
                Layout.topMargin: 10
                height: 60
                text: "Добавить текущий вес"
                fontSize: Math.min(18, root.width * 0.04)
                onClicked: weightDialog.open()
            }
        }
    }

    // Диалог добавления веса
    MyComponents.WeightDialog {
        id: weightDialog
        currentDate: root.currentDate

        onAccepted: function (weight, date) {
            root.weightData.push({
                                     "weight": weight,
                                     "date": date
                                 })
            root.weightData.sort((a, b) => a.date - b.date)
            chartCard.requestPaint()
        }
    }

    MessageDialog {
        id: errorDialog
        title: "Ошибка"
        text: "Пожалуйста, введите корректный вес!"
        buttons: MessageDialog.Ok
    }

    Component.onCompleted: {
        // Тестовые данные
        weightData = [{
                          "weight": 68.5,
                          "date": new Date(2023, 5, 1)
                      }, {
                          "weight": 67.8,
                          "date": new Date(2023, 5, 8)
                      }, {
                          "weight": 67.2,
                          "date": new Date(2023, 5, 15)
                      }, {
                          "weight": 66.5,
                          "date": new Date(2023, 5, 22)
                      }]
    }

    Timer {
        interval: 300
        onTriggered: chartCard.requestPaint()
    }
}
