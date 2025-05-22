import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Item {
    id: root
    objectName: "calendar"
    width: parent.width
    height: parent.height

    property int currentWeek: 0
    property int currentDay: 0
    property date currentDate: new Date()
    property string currentMonth: Qt.formatDate(currentDate, "MMMM")
    property string currentYear: Qt.formatDate(currentDate, "yyyy")

    // Данные для календаря
    property var calendarData: {
        var now = new Date()
        var month = now.getMonth()
        var year = now.getFullYear()

        // Генерация календаря для текущего и следующего месяца
        var months = {}
        for (var m = 0; m < 9; m++) {
            var monthName = Qt.locale().monthName((month + m) % 12,
                                                  Locale.LongFormat)
            var firstDay = new Date(year, (month + m) % 12, 1).getDay()
            var daysInMonth = new Date(year, (month + m) % 12 + 1, 0).getDate()

            var weeks = []
            var day = 1
            for (var w = 0; w < 6; w++) {
                var week = []
                for (var d = 0; d < 7; d++) {
                    if ((w === 0 && d < firstDay + 1) || day > daysInMonth) {
                        week.push(null)
                    } else {
                        week.push(day++)
                    }
                }
                weeks.push(week)
                if (day > daysInMonth)
                    break
            }
            months[monthName] = weeks
        }
        return months
    }

    // Инициализация данных
    Component.onCompleted: {
        updatePregnancyProgress()
    }

    // Обновление данных о прогрессе беременности
    function updatePregnancyProgress() {
        var progress = pregnancyCalendarManager.loadPregnancyData()
        if (progress) {
            currentDay = progress.currentDay || 0
            currentWeek = progress.currentWeek || 0
        }
    }

    // Получение данных дня
    function getDayData(date) {
        var dateStr = Qt.formatDate(date, "yyyy-MM-dd")
        var dayData = pregnancyCalendarManager.getDayData(dateStr) || {}

        return {
            "weight": dayData.weight || "Никогда не измерялось",
            "pressure": dayData.pressure || "Никогда не измерялось",
            "waist": dayData.waist || "Никогда не измерялось",
            "symptoms": dayData.symptoms || [],
            "mood": dayData.mood || ""
        }
    }

    // Сохранение данных дня
    function saveDayData(date, weight, pressure, waist, mood, symptoms) {
        var dateStr = Qt.formatDate(date, "yyyy-MM-dd")
        pregnancyCalendarManager.saveDayData(dateStr, weight, pressure,
                                             waist, mood)
        pregnancyCalendarManager.saveSymptoms(dateStr, symptoms)
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
                                            var isToday = modelData === Qt.formatDate(
                                                        root.currentDate, "d")
                                                    && modelData === Qt.formatDate(
                                                        new Date(), "d")
                                            return isToday ? "#9c27b0" : hasNotes ? "#e1bee7" : "transparent"
                                        }
                                        border.color: "#9c27b0"
                                        border.width: modelData ? 1 : 0
                                        Layout.alignment: Qt.AlignHCenter

                                        property date currentDate: {
                                            var year = root.currentDate.getFullYear()
                                            var month = Object.keys(
                                                        calendarData).indexOf(
                                                        modelData) + new Date().getMonth()
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
                                                    var data = getDayData(
                                                                dayRect.currentDate)
                                                    dayInfoPopup.selectedDate = dayRect.currentDate
                                                    dayInfoPopup.weightValue = data.weight.replace(
                                                                " кг",
                                                                "").replace(
                                                                "Никогда не измерялось",
                                                                "")
                                                    dayInfoPopup.pressureValue
                                                            = data.pressure.replace(
                                                                " мм рт.ст.",
                                                                "").replace(
                                                                "Никогда не измерялось",
                                                                "")
                                                    dayInfoPopup.waistValue = data.waist.replace(
                                                                " см",
                                                                "").replace(
                                                                "Никогда не измерялось",
                                                                "")
                                                    dayInfoPopup.moodValue = data.mood
                                                    dayInfoPopup.symptomsModel = data.symptoms
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
        onSaveClicked: function (data) {
            pregnancyCalendarManager.saveDayData(Qt.formatDate(data.date,
                                                               "yyyy-MM-dd"),
                                                 data.weight, data.pressure,
                                                 data.waist, data.mood)
            pregnancyCalendarManager.saveSymptoms(Qt.formatDate(data.date,
                                                                "yyyy-MM-dd"),
                                                  data.symptoms)
        }
    }
}
