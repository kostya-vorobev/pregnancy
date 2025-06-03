import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root
    objectName: "calendar"
    width: parent.width
    height: parent.height

    property int profileId: 1
    property int displayWeek: pregnancyProgress.currentWeek > 0 ? pregnancyProgress.currentWeek : 1
    property date startDate

    // Локализация для названий месяцев
    property var locale: Qt.locale("ru_RU")

    // Данные о беременности (C++ класс)
    PregnancyProgress {
        id: pregnancyProgress
        profileId: root.profileId

        onDataLoaded: {
            console.log("Текущая неделя беременности:", currentWeek)
            root.displayWeek = currentWeek > 0 ? currentWeek : 1
        }
    }

    // Инициализация данных
    Component.onCompleted: {
        updatePregnancyProgress()
        if (profileId > 0) {
            pregnancyProgress.profileId = profileId
            pregnancyProgress.loadData()
            startDate = new Date(pregnancyProgress.startDate)
        }
    }

    property int currentWeek: 4
    property int currentDay: 0

    // Оптимизированная генерация данных календаря
    function generateCalendarData() {
        var result = []
        if (!startDate)
            return result

        var now = new Date(startDate)
        var currentYear = now.getFullYear()
        var currentMonth = now.getMonth()

        // Генерируем 9 месяцев беременности
        for (var m = 0; m < 9; m++) {
            var monthDate = new Date(currentYear, currentMonth + m, 1)
            var monthName = locale.standaloneMonthName(monthDate.getMonth(),
                                                       Locale.LongFormat)
            var year = monthDate.getFullYear()
            var firstDay = (monthDate.getDay(
                                ) + 6) % 7 // Convert to Mon=0, Sun=6
            var daysInMonth = new Date(year, monthDate.getMonth() + 1,
                                       0).getDate()

            var weeks = []
            var day = 1

            // Рассчитываем количество недель в месяце
            var totalCells = firstDay + daysInMonth
            var totalWeeks = Math.ceil(totalCells / 7)

            for (var w = 0; w < totalWeeks; w++) {
                var week = []
                for (var d = 0; d < 7; d++) {
                    if ((w === 0 && d < firstDay) || day > daysInMonth) {
                        week.push(null)
                    } else {
                        week.push({
                                      "day": day,
                                      "date": new Date(year,
                                                       monthDate.getMonth(),
                                                       day++)
                                  })
                    }
                }
                weeks.push(week)
            }

            result.push({
                            "name": monthName,
                            "year": year,
                            "weeks": weeks
                        })
        }
        return result
    }

    // Кэшируем данные календаря
    property var calendarData: generateCalendarData()

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

        // Prepare symptoms data with default severity 0 for unselected symptoms
        var symptoms = []
        var allSymptoms = pregnancyCalendarManager.getAvailableSymptoms()

        // First add selected symptoms with their severity
        if (dayData.symptoms) {
            symptoms = dayData.symptoms
        }

        // Then add unselected symptoms with severity 0
        for (var i = 0; i < allSymptoms.length; i++) {
            var found = symptoms.some(s => s.id === allSymptoms[i].id)
            if (!found) {
                symptoms.push({
                                  "id": allSymptoms[i].id,
                                  "name": allSymptoms[i].name,
                                  "severity": 0,
                                  "notes": "",
                                  "category": allSymptoms[i].category
                              })
            }
        }

        return {
            "weight": dayData.weight || "Никогда не измерялось",
            "pressure": dayData.pressure || "Никогда не измерялось",
            "waist": dayData.waist || "Никогда не измерялось",
            "symptoms": symptoms,
            "mood": dayData.mood || "",
            "notes": dayData.notes || "",
            "plans": dayData.plans || []
        }
    }

    // Сохранение данных дня
    function saveDayData(date, weight, pressure, waist, mood, notes, symptoms) {
        var dateStr = Qt.formatDate(date, "yyyy-MM-dd")
        pregnancyCalendarManager.saveDayData(dateStr, weight, pressure, waist,
                                             mood, notes)
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
                        text: {
                            var date = new Date()
                            return date.getDate() + " " + root.locale.monthName(
                                        date.getMonth(),
                                        Locale.LongFormat) + " (Сегодня)"
                        }
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
                                text: displayWeek + " НЕД 0 Д"
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
                    model: calendarData

                    Column {
                        width: parent.width
                        spacing: 10

                        Label {
                            text: modelData.name.toUpperCase(
                                      ) + " " + modelData.year
                            font.pixelSize: 18
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#4a148c"
                        }

                        GridLayout {
                            width: parent.width
                            columns: 7
                            rowSpacing: 10
                            columnSpacing: 10

                            // Заголовки дней недели
                            Repeater {
                                model: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
                                Label {
                                    text: modelData
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }

                            // Ячейки календаря
                            Repeater {
                                model: {
                                    var flatWeeks = []
                                    for (var i = 0; i < modelData.weeks.length; i++) {
                                        flatWeeks = flatWeeks.concat(
                                                    modelData.weeks[i])
                                    }
                                    return flatWeeks
                                }

                                delegate: Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: {
                                        if (!modelData)
                                            return "transparent"
                                        var today = new Date()
                                        var isToday = modelData.date.getDate(
                                                    ) === today.getDate()
                                                && modelData.date.getMonth(
                                                    ) === today.getMonth()
                                                && modelData.date.getFullYear(
                                                    ) === today.getFullYear()
                                        return isToday ? "#9c27b0" : hasNotes ? "#e1bee7" : "transparent"
                                    }
                                    border.color: modelData ? "#9c27b0" : "transparent"
                                    border.width: 1
                                    Layout.alignment: Qt.AlignHCenter

                                    property bool hasNotes: modelData ? getDayData(
                                                                            modelData.date).weight !== "Никогда не измерялось" : false
                                    property date currentDate: modelData ? modelData.date : new Date()

                                    Label {
                                        text: modelData ? modelData.day : ""
                                        anchors.centerIn: parent
                                        color: parent.color === "#9c27b0" ? "white" : "black"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: modelData
                                        onClicked: {
                                            var data = getDayData(
                                                        parent.currentDate)
                                            dayInfoPopup.selectedDate = parent.currentDate
                                            dayInfoPopup.weightValue = data.weight.replace(
                                                        " кг", "").replace(
                                                        "Никогда не измерялось",
                                                        "")
                                            dayInfoPopup.pressureValue = data.pressure.replace(
                                                        " мм рт.ст.",
                                                        "").replace(
                                                        "Никогда не измерялось",
                                                        "")
                                            dayInfoPopup.waistValue = data.waist.replace(
                                                        " см", "").replace(
                                                        "Никогда не измерялось",
                                                        "")
                                            dayInfoPopup.moodValue = data.mood
                                            dayInfoPopup.notesValue = data.notes
                                            dayInfoPopup.symptomsModel = data.symptoms
                                            dayInfoPopup.plansModel = data.plans
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

    // Попап с информацией о дне
    MyComponents.DayInfoPopup {
        id: dayInfoPopup
        onSaveClicked: function (data) {
            saveDayData(data.date, data.weight, data.pressure, data.waist,
                        data.mood, data.notes, data.symptoms)
        }

        onCompletePlan: function (planId, completed) {
            pregnancyCalendarManager.setPlanCompleted(planId, completed)
            // Refresh the popup data
            var dayData = getDayData(dayInfoPopup.selectedDate)
            dayInfoPopup.plansModel = dayData.plans
        }
    }
}
