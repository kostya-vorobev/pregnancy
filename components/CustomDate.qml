import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    width: parent.width
    height: 45

    property date selectedDate: new Date()
    property bool showHeader: false
    property string headerText: ""

    function setDate(date) {
        if (date instanceof Date && !isNaN(date.getTime())) {
            selectedDate = date
            dayCombo.currentIndex = date.getDate() - 1
            monthCombo.currentIndex = date.getMonth()
            yearCombo.currentIndex = yearCombo.model.indexOf(date.getFullYear())
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 5

        Label {
            visible: root.showHeader
            text: root.headerText
            Layout.fillWidth: true
            font.bold: true
        }

        ComboBox {
            id: dayCombo
            model: 31
            currentIndex: selectedDate.getDate() - 1
            Layout.fillWidth: true
            onActivated: updateDate()
        }

        ComboBox {
            id: monthCombo
            model: ["Янв", "Фев", "Мар", "Апр", "Май", "Июн", "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
            currentIndex: selectedDate.getMonth()
            Layout.fillWidth: true
            onActivated: updateDate()
        }

        ComboBox {
            id: yearCombo
            model: {
                var years = []
                var currentYear = new Date().getFullYear()
                for (var i = currentYear - 5; i <= currentYear + 1; i++)
                    years.push(i)
                return years
            }
            currentIndex: model.indexOf(selectedDate.getFullYear())
            Layout.fillWidth: true
            onActivated: updateDate()
        }
    }

    function updateDate() {
        var day = dayCombo.currentIndex + 1
        var month = monthCombo.currentIndex
        var year = yearCombo.model[yearCombo.currentIndex]

        // Проверка на корректность даты
        var lastDay = new Date(year, month + 1, 0).getDate()
        if (day > lastDay)
            day = lastDay

        selectedDate = new Date(year, month, day)
    }

    Component.onCompleted: {
        setDate(selectedDate)
    }
}
