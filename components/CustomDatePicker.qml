import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components" as MyComponents

Item {
    id: root
    required property int width
    required property int height
    required property string locale
    required property string calendar
    required property ApplicationWindow mainWindow

    property string placeholderText: ""
    property string selectedDateText: ""
    property date selectedDate
    property date minDate
    property date maxDate

    function reset() {
        root.selectedDate = new Date("Invalid Date")
        root.selectedDateText = ''
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        radius: 10
        color: "#FAFAFA"
        border {
            width: 1
            color: "#BDBDBD"
        }

        Label {
            anchors.fill: parent
            anchors.margins: 10
            text: root.selectedDateText !== "" ? root.selectedDateText : root.placeholderText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font {
                family: "Roboto"
                weight: Font.Normal
                pixelSize: 12
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: dateTimeDialog.open()
    }

    Dialog {
        id: dateTimeDialog
        modal: true
        width: Math.min(350, mainWindow.width * 0.9)
        height: Math.min(400, mainWindow.height * 0.8)
        padding: 0
        parent: mainWindow.contentItem
        anchors.centerIn: parent

        property date tempSelectedDate: root.selectedDate.toString(
                                            ) !== "Invalid Date" ? new Date(root.selectedDate) : new Date()
        property bool isTimeSelection: false

        background: Rectangle {
            color: "#FFFFFF"
            border.color: "#E0E0E0"
            border.width: 0.5
            radius: 5
        }

        onTempSelectedDateChanged: {
            if (minDate.toString() !== "Invalid Date"
                    && minDate > tempSelectedDate)
                tempSelectedDate = minDate
            else if (maxDate.toString() !== "Invalid Date"
                     && maxDate < tempSelectedDate)
                tempSelectedDate = maxDate
        }

        function setLocaleDate(localeYear, localeMonth, localeDay) {
            var gregorianDate = qDatePicker.localeToGregorianDate(localeYear,
                                                                  localeMonth,
                                                                  localeDay)
            dateTimeDialog.tempSelectedDate = new Date(gregorianDate)
        }

        function isDateInRange(gregorianDate) {
            var minCheckDate = root.minDate
            var maxCheckDate = root.maxDate

            if (!dateTimeDialog.isTimeSelection) {
                minCheckDate = new Date(minCheckDate.setHours(0, 0, 0, 0))
                maxCheckDate = new Date(maxCheckDate.setHours(23, 59, 59, 0))
            }

            if (minCheckDate.toString() !== "Invalid Date"
                    && maxCheckDate.toString() !== "Invalid Date")
                return minCheckDate <= gregorianDate
                        && gregorianDate <= maxCheckDate
            if (minCheckDate.toString() !== "Invalid Date")
                return minCheckDate <= gregorianDate
            else if (maxCheckDate.toString() !== "Invalid Date")
                return gregorianDate <= maxCheckDate

            return true
        }

        header: Pane {
            id: headerRect
            height: 40
            padding: 10
            background: Rectangle {
                color: "#FFFFFF"
            }

            property var selectedDateString: qDatePicker.calendar
                                             !== "" ? qDatePicker.dateToLocalDateString(
                                                          dateTimeDialog.tempSelectedDate.getFullYear(
                                                              ),
                                                          dateTimeDialog.tempSelectedDate.getMonth(
                                                              ) + 1,
                                                          dateTimeDialog.tempSelectedDate.getDate(
                                                              )) : []

            property int selectedYear: Number(selectedDateString[0]) || 0
            property int selectedMonth: Number(selectedDateString[1]) || 0
            property int selectedDay: Number(selectedDateString[2]) || 0
            property string selectedDayWeekName: selectedDateString[3] || ""
            property string selectedMonthName: selectedDateString[4] || ""

            Label {
                anchors.centerIn: parent
                text: "Выберите дату"
                font {
                    family: "Roboto"
                    weight: Font.Normal
                    pixelSize: 16
                }
                visible: !dateTimeDialog.isTimeSelection
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Month/Year navigation
            RowLayout {
                id: navigationRow
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                spacing: 5
                visible: !dateTimeDialog.isTimeSelection

                Button {
                    text: navigationRow.LayoutMirroring.enabled ? ">" : "<"
                    flat: true
                    font.bold: true
                    enabled: dateTimeDialog.isDateInRange(
                                 qDatePicker.localeToGregorianDate(
                                     headerRect.selectedYear,
                                     headerRect.selectedMonth - 1,
                                     headerRect.selectedDay))
                    onClicked: dateTimeDialog.setLocaleDate(
                                   headerRect.selectedYear,
                                   headerRect.selectedMonth - 1,
                                   headerRect.selectedDay)

                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#E0E0E0"
                        border.width: 0.5
                        radius: 5
                    }
                }

                Button {
                    id: monthTxt
                    Layout.fillWidth: true
                    text: headerRect.selectedMonthName
                    flat: true
                    onClicked: monthSelectorPopup.open()
                }

                Button {
                    id: yearTxt
                    Layout.fillWidth: true
                    text: headerRect.selectedYear
                    flat: true
                    onClicked: yearSelectorPopup.open()
                }

                Button {
                    text: navigationRow.LayoutMirroring.enabled ? "<" : ">"
                    flat: true
                    font.bold: true
                    enabled: dateTimeDialog.isDateInRange(
                                 qDatePicker.localeToGregorianDate(
                                     headerRect.selectedYear,
                                     headerRect.selectedMonth + 1,
                                     headerRect.selectedDay))
                    onClicked: dateTimeDialog.setLocaleDate(
                                   headerRect.selectedYear,
                                   headerRect.selectedMonth + 1,
                                   headerRect.selectedDay)

                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#E0E0E0"
                        border.width: 0.5
                        radius: 5
                    }
                }
            }

            // Week days header
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                visible: !dateTimeDialog.isTimeSelection

                Repeater {
                    model: qDatePicker.calendar !== "" ? qDatePicker.getNarrowWeekDaysName(
                                                             ) : []
                    delegate: Label {
                        Layout.fillWidth: true
                        text: modelData
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font {
                            pixelSize: 13
                            bold: true
                        }
                    }
                }
            }

            // Calendar grid
            GridLayout {
                id: calendarGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                columns: 7
                visible: !dateTimeDialog.isTimeSelection

                Repeater {
                    model: qDatePicker.getGridDaysOfMonth(
                               headerRect.selectedYear,
                               headerRect.selectedMonth)
                    delegate: RoundButton {
                        property date gregorianDate: qDatePicker.localeToGregorianDate(
                                                         headerRect.selectedYear,
                                                         headerRect.selectedMonth,
                                                         Number(modelData))

                        text: modelData === "0" ? "" : modelData
                        flat: !highlighted
                        highlighted: Number(
                                         modelData) === headerRect.selectedDay
                        enabled: modelData !== "0"
                                 && dateTimeDialog.isDateInRange(gregorianDate)
                        font.pixelSize: 12

                        onClicked: dateTimeDialog.tempSelectedDate = new Date(gregorianDate)
                    }
                }
            }

            // Buttons row
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                spacing: 10
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.bottomMargin: 10

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Отмена")
                    flat: true
                    onClicked: dateTimeDialog.close()

                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#BDBDBD"
                        border.width: 0.5
                        radius: 5
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("OK")
                    flat: true
                    onClicked: {
                        root.selectedDate = dateTimeDialog.tempSelectedDate
                        root.selectedDateText = Qt.formatDate(
                                    dateTimeDialog.tempSelectedDate,
                                    "dd.MM.yyyy")
                        dateTimeDialog.close()
                    }

                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#BDBDBD"
                        border.width: 0.5
                        radius: 5
                    }
                }
            }
        }

        // Month selector popup
        Popup {
            id: monthSelectorPopup
            x: (monthTxt.width - width) / 2
            y: monthTxt.height
            parent: monthTxt
            width: 120
            height: Math.min(300, mainWindow.height * 0.5)
            modal: true
            dim: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 0.5
                radius: 2
            }

            ScrollView {
                anchors.fill: parent
                clip: true

                Column {
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: qDatePicker.calendar !== "" ? qDatePicker.getShortMonthsName(
                                                                 ) : []
                        delegate: Button {
                            width: parent.width
                            height: 30
                            text: modelData
                            flat: !highlighted
                            highlighted: text === headerRect.selectedMonthName
                            enabled: dateTimeDialog.isDateInRange(
                                         qDatePicker.localeToGregorianDate(
                                             headerRect.selectedYear,
                                             index + 1, headerRect.selectedDay))

                            onClicked: {
                                dateTimeDialog.setLocaleDate(
                                            headerRect.selectedYear, index + 1,
                                            headerRect.selectedDay)
                                monthSelectorPopup.close()
                            }
                        }
                    }
                }
            }
        }

        // Year selector popup
        Popup {
            id: yearSelectorPopup
            x: (yearTxt.width - width) / 2
            y: yearTxt.height
            parent: yearTxt
            width: 120
            height: Math.min(300, mainWindow.height * 0.5)
            modal: true
            dim: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            background: Rectangle {
                color: "#FFFFFF"
                border.color: "#E0E0E0"
                border.width: 0.5
                radius: 2
            }

            ScrollView {
                anchors.fill: parent
                clip: true

                Column {
                    width: parent.width
                    spacing: 2

                    Repeater {
                        model: ListModel {
                            Component.onCompleted: {
                                let currentYear = new Date().getFullYear()
                                for (var year = currentYear; year >= 1900; year--) {
                                    append({
                                               "year": year
                                           })
                                }
                            }
                        }

                        delegate: Button {
                            width: parent.width
                            height: 30
                            text: model.year
                            flat: !highlighted
                            highlighted: Number(
                                             text) === headerRect.selectedYear
                            enabled: dateTimeDialog.isDateInRange(
                                         qDatePicker.localeToGregorianDate(
                                             Number(text),
                                             headerRect.selectedMonth,
                                             headerRect.selectedDay))

                            onClicked: {
                                dateTimeDialog.setLocaleDate(
                                            Number(text),
                                            headerRect.selectedMonth,
                                            headerRect.selectedDay)
                                yearSelectorPopup.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
