// HistoryPopup.qml
import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts 2.15
import Qt5Compat.GraphicalEffects

import "../components" as MyComponents

Popup {
    id: root
    width: Math.min(parent.width * 0.9, 600)
    height: Math.min(parent.height * 0.8, 700)
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 15

    property string parameterName: ""
    property int parameterId: -1
    property string parameterUnit: ""
    property var parameterData: ({})
    property var historyModel: []

    signal requestHistory(int parameterId)

    background: Rectangle {
        radius: 10
        color: "#ffffff"
        border.color: "#e0e0e0"
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 10
            samples: 16
            color: "#20000000"
        }
    }

    onParameterIdChanged: {
        historyModel = []
        valueSeries.clear()
        referenceSeries.clear()
    }

    onClosed: {
        historyModel = []
        valueSeries.clear()
        referenceSeries.clear()
    }

    onOpened: {
        if (parameterId >= 0) {
            requestHistory(parameterId)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        Label {
            text: parameterName + (parameterUnit ? ` (${parameterUnit})` : "")
            font.bold: true
            font.pixelSize: 20
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        // График
        ChartView {
            id: chartView
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            backgroundColor: "#f9f9f9"
            legend.visible: true
            legend.alignment: Qt.AlignTop
            antialiasing: true

            // Ось Y (значения)
            ValuesAxis {
                id: axisY
                titleText: "Значение" + (parameterUnit ? ", " + parameterUnit : "")
                labelFormat: "%.1f"
                gridVisible: true
                minorGridVisible: true
            }

            // Ось X (даты)
            DateTimeAxis {
                id: axisX
                titleText: "Дата"
                format: "dd.MM.yy"
                gridVisible: true
                minorGridVisible: true
            }

            // Линия с фактическими значениями
            LineSeries {
                id: valueSeries
                name: parameterName
                axisX: axisX
                axisY: axisY
                color: "#4a6da7"
                width: 3
                pointsVisible: true
            }

            // Линия с нормальными значениями (пунктирная)
            LineSeries {
                id: referenceSeries
                name: "Норма"
                axisX: axisX
                axisY: axisY
                color: "#4caf50"
                width: 1
                style: Qt.DashLine
            }
        }

        // Таблица с данными
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                model: historyModel
                spacing: 2
                width: parent.width

                delegate: Rectangle {
                    width: listView.width
                    height: 50
                    color: index % 2 === 0 ? "#f5f5f5" : "#ffffff"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Label {
                            text: Qt.formatDate(new Date(modelData.date),
                                                "dd.MM.yyyy")
                            font.pixelSize: 14
                            Layout.preferredWidth: 100
                        }

                        Label {
                            text: {
                                let val = modelData.value
                                if (parameterUnit) {
                                    return `${val} ${parameterUnit}`
                                }
                                return val
                            }
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 100

                            Rectangle {
                                visible: modelData.min !== undefined
                                         || modelData.max !== undefined
                                width: 4
                                height: parent.height
                                anchors.right: parent.right
                                color: {
                                    if (modelData.min !== undefined
                                            && modelData.value < modelData.min)
                                        return "#ff5722" // Ниже нормы
                                    if (modelData.max !== undefined
                                            && modelData.value > modelData.max)
                                        return "#ff5722" // Выше нормы
                                    return "#4caf50" // Норма
                                }
                                radius: 2
                            }
                        }

                        Label {
                            text: {
                                let parts = []
                                if (modelData.min !== undefined)
                                    parts.push(`мин: ${modelData.min}`)
                                if (modelData.max !== undefined)
                                    parts.push(`макс: ${modelData.max}`)
                                return parts.join(", ")
                            }
                            font.pixelSize: 12
                            color: "#666"
                            Layout.preferredWidth: 150
                        }

                        Label {
                            text: modelData.note || "-"
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                header: Rectangle {
                    width: listView.width
                    height: 40
                    color: "#e0e0e0"
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Label {
                            text: "Дата"
                            font.bold: true
                            font.pixelSize: 14
                            Layout.preferredWidth: 100
                        }

                        Label {
                            text: "Значение"
                            font.bold: true
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 100
                        }

                        Label {
                            text: "Норма"
                            font.bold: true
                            font.pixelSize: 14
                            Layout.preferredWidth: 150
                        }

                        Label {
                            text: "Примечание"
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }
                    }
                }

                footer: Item {
                    width: listView.width
                    height: historyModel.length === 0 ? 100 : 0
                    visible: historyModel.length === 0

                    Label {
                        anchors.centerIn: parent
                        text: "Нет данных для отображения"
                        color: "#888"
                        font.pixelSize: 16
                    }
                }
            }
        }

        // Кнопка закрытия
        MyComponents.CustomButton {
            text: "Закрыть"
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            onClicked: root.close()
        }
    }

    function updateChart() {
        valueSeries.clear()
        referenceSeries.clear()

        if (historyModel.length === 0) {
            return
        }

        // Обновляем имя серии
        valueSeries.name = parameterName

        let minDate = Infinity
        let maxDate = -Infinity
        let minValue = Infinity
        let maxValue = -Infinity

        historyModel.forEach(item => {
                                 let date = new Date(item.date)
                                 let dateMs = date.getTime()
                                 valueSeries.append(dateMs, item.value)

                                 if (item.min !== undefined) {
                                     referenceSeries.append(dateMs, item.min)
                                 }
                                 if (item.max !== undefined) {
                                     referenceSeries.append(dateMs, item.max)
                                 }

                                 minDate = Math.min(minDate, dateMs)
                                 maxDate = Math.max(maxDate, dateMs)
                                 minValue = Math.min(minValue, item.value)
                                 maxValue = Math.max(maxValue, item.value)
                             })

        axisX.min = new Date(minDate)
        axisX.max = new Date(maxDate)

        let valueRange = maxValue - minValue
        axisY.min = minValue - valueRange * 0.1
        axisY.max = maxValue + valueRange * 0.1
    }

    Connections {
        target: root
        function onHistoryModelChanged() {
            updateChart()
        }
    }
}
