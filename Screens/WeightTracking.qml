import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Controls.Material
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#e1bee7"

    WeightManager {
        id: weightManager
        onWeightDataChanged: {
            root.weightData = weightManager.weightData
            chartCard.requestPaint()
        }
    }

    property var weightData: []
    property date currentDate: new Date()

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

                onDeleteRequested: function (measurementData) {
                    deleteDialog.measurementId = measurementData.id
                    deleteDialog.open()
                }
            }

            Dialog {
                id: deleteDialog
                title: "Подтверждение удаления"
                standardButtons: Dialog.Yes | Dialog.No
                modal: true
                width: 300
                property int measurementId: -1

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: "Вы действительно хотите удалить эту запись?"
                }

                onAccepted: {
                    // Вызываем метод удаления из C++ класса
                    weightManager.removeWeightMeasurement(measurementId)
                }
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

        onAccepted: function (weight, date, note) {
            if (!weightManager.addWeightMeasurement(weight, date, note)) {
                errorDialog.text = "Не удалось сохранить данные о весе"
                errorDialog.open()
            }
        }
    }

    // Диалог ошибки
    MessageDialog {
        id: errorDialog
        title: "Ошибка"
        buttons: MessageDialog.Ok
    }

    Component.onCompleted: {
        weightManager.loadWeightData()
    }
}
