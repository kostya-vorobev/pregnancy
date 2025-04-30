import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Item {
    id: root
    objectName: "calendar"
    width: parent.width
    height: parent.height

    property int currentWeek: 6
    property int currentDay: 43
    property date currentDate: new Date()
    property string currentMonth: Qt.formatDate(currentDate, "MMMM")
    property string currentYear: Qt.formatDate(currentDate, "yyyy")

    // Данные для календаря
    property var calendarData: {
        "Апрель": [[null, 1, 2, 3, 4, 5, 6], [7, 8, 9, 10, 11, 12, 13], [14, 15, 16, 17, 18, 19, 20], [21, 22, 23, 24, 25, 26, 27], [28, 29, 30, null, null, null, null]],
        "Май": [[null, null, null, 1, 2, 3, 4], [5, 6, 7, 8, 9, 10, 11], [12, 13, 14, 15, 16, 17, 18], [19, 20, 21, 22, 23, 24, 25], [26, 27, 28, 29, 30, 31, null]]
    }

    // Данные для дней
    property var daysData: ({})

    // Функция для получения данных дня
    function getDayData(date) {
        var dateStr = Qt.formatDate(date, "yyyy-MM-dd")
        if (!daysData[dateStr]) {
            daysData[dateStr] = {
                "weight": "Никогда не измерялось",
                "pressure": "Никогда не измерялось",
                "waist": "Никогда не измерялось",
                "symptoms": [],
                "mood": ""
            }
        }
        return daysData[dateStr]
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 20

            // Шапка с текущей датой
            Rectangle {
                width: parent.width
                height: 100
                color: "#9c27b0"

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    Label {
                        text: Qt.formatDate(root.currentDate,
                                            "d MMMM (Сегодня)")
                        font.pixelSize: 18
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        spacing: 20
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column {
                            spacing: 2
                            Label {
                                text: "Акушерский срок"
                                font.pixelSize: 12
                                color: "white"
                            }
                            Label {
                                text: currentWeek + " НЕД 0 Д"
                                font {
                                    pixelSize: 16
                                    bold: true
                                }
                                color: "white"
                            }
                        }

                        Column {
                            spacing: 2
                            Label {
                                text: "День беременности"
                                font.pixelSize: 12
                                color: "white"
                            }
                            Label {
                                text: currentDay + " Д"
                                font {
                                    pixelSize: 16
                                    bold: true
                                }
                                color: "white"
                            }
                        }
                    }
                }
            }

            // Календарь
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 15

                Repeater {
                    model: Object.keys(calendarData)

                    Column {
                        width: parent.width
                        spacing: 10

                        Label {
                            text: modelData.toUpperCase()
                            font {
                                pixelSize: 18
                                bold: true
                            }
                            color: "#4a148c"
                        }

                        // Таблица календаря
                        GridLayout {
                            width: parent.width
                            columns: 7
                            rowSpacing: 10
                            columnSpacing: 10

                            // Заголовки дней недели
                            Repeater {
                                model: ["П", "В", "С", "Ч", "П", "С", "В"]
                                Label {
                                    text: modelData
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }

                            // Ячейки календаря
                            Repeater {
                                model: calendarData[modelData]

                                delegate: Repeater {
                                    model: modelData

                                    delegate: Rectangle {
                                        id: dayRect
                                        width: 30
                                        height: 30
                                        radius: 15
                                        color: {
                                            if (!modelData)
                                                return "transparent"
                                            return modelData === Qt.formatDate(
                                                        root.currentDate,
                                                        "d") ? "#9c27b0" : hasNotes ? "#e1bee7" : "transparent"
                                        }
                                        border.color: "#9c27b0"
                                        border.width: modelData ? 1 : 0
                                        Layout.alignment: Qt.AlignHCenter

                                        property date currentDate: {
                                            var year = root.currentDate.getFullYear()
                                            var month = Object.keys(
                                                        calendarData).indexOf(
                                                        modelData) + 3 // Апрель=3
                                            return new Date(year, month,
                                                            modelData)
                                        }
                                        property bool hasNotes: {
                                            var data = getDayData(currentDate)
                                            return data.weight !== "Никогда не измерялось"
                                                    || data.pressure !== "Никогда не измерялось"
                                                    || data.waist !== "Никогда не измерялось"
                                                    || data.symptoms.length > 0
                                                    || data.mood !== ""
                                        }

                                        Label {
                                            text: modelData || ""
                                            anchors.centerIn: parent
                                            color: modelData === Qt.formatDate(
                                                       root.currentDate,
                                                       "d") ? "white" : "black"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (modelData) {
                                                    dayInfoPopup.selectedDate = dayRect.currentDate
                                                    dayInfoPopup.weightValue = getDayData(
                                                                dayRect.currentDate).weight
                                                    dayInfoPopup.pressureValue = getDayData(
                                                                dayRect.currentDate).pressure
                                                    dayInfoPopup.waistValue = getDayData(
                                                                dayRect.currentDate).waist
                                                    dayInfoPopup.open()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Попап с информацией о дне
    MyComponents.DayInfoPopup {
        id: dayInfoPopup

        onWeightValueChanged: {
            var dateStr = Qt.formatDate(selectedDate, "yyyy-MM-dd")
            daysData[dateStr].weight = weightValue
        }

        onPressureValueChanged: {
            var dateStr = Qt.formatDate(selectedDate, "yyyy-MM-dd")
            daysData[dateStr].pressure = pressureValue
        }

        onWaistValueChanged: {
            var dateStr = Qt.formatDate(selectedDate, "yyyy-MM-dd")
            daysData[dateStr].waist = waistValue
        }
    }
}
