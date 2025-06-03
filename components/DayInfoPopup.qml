import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup
    width: parent.width * 0.95
    height: parent.height * 0.8
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    property date selectedDate: new Date()
    property string weightValue: ""
    property string pressureValue: ""
    property string waistValue: ""
    property string moodValue: ""
    property string notesValue: ""
    property var symptomsModel: []

    property var plansModel: plansListModel
    property ListModel symptomsListModel: ListModel {}
    signal saveClicked(var data)
    signal addPlan(date date, var planData)
    signal completePlan(int planId, bool completed)

    //property alias plansModel: plansListModel
    ListModel {
        id: plansListModel
    }

    function loadPlans() {
        plansListModel.clear()
        var dayData = pregnancyCalendarManager.getDayData(Qt.formatDate(
                                                              selectedDate,
                                                              "yyyy-MM-dd"))
        console.log("Loaded day data:", JSON.stringify(dayData))

        if (dayData.plans && dayData.plans.length > 0) {
            for (var i = 0; i < dayData.plans.length; i++) {
                var plan = dayData.plans[i]
                plansListModel.append({
                                          "id": plan.id || -1,
                                          "planType": plan.planType || "",
                                          "description": plan.description || "",
                                          "time": plan.time || "",
                                          "isCompleted": plan.isCompleted
                                                         || false
                                      })
            }
        }
        console.log("Plans in model:", plansListModel.count)
    }

    function loadSymptoms() {
        symptomsListModel.clear()
        var dayData = pregnancyCalendarManager.getDayData(Qt.formatDate(
                                                              selectedDate,
                                                              "yyyy-MM-dd"))

        if (dayData.symptoms && dayData.symptoms.length > 0) {
            dayData.symptoms.forEach(function (symptom) {
                symptomsListModel.append({
                                             "id": symptom.id,
                                             "name": symptom.name,
                                             "category": symptom.category,
                                             "severity": symptom.severity || 0,
                                             "notes": symptom.notes || "",
                                             "isSelected": symptom.severity > 0
                                         })
            })
        }
    }

    function prepareSymptomsData() {
        var symptoms = []
        for (var i = 0; i < symptomsListModel.count; i++) {
            var item = symptomsListModel.get(i)
            if (item.isSelected) {
                symptoms.push({
                                  "id": item.id,
                                  "severity": item.severity,
                                  "notes": item.notes
                              })
            }
        }
        return symptoms
    }

    onAddPlan: function (date, planData) {
        var dateStr = Qt.formatDate(date, "yyyy-MM-dd")
        pregnancyCalendarManager.addDailyPlan(dateStr, planData.type,
                                              planData.description,
                                              planData.time)
        // Добавляем с проверкой на undefined
        plansListModel.append({
                                  "id": pregnancyCalendarManager.lastInsertedPlanId(
                                            ) || -1,
                                  "planType": planTypeCombo.textRoleMap[planData.type]
                                  || "",
                                  "description": planData.description || "",
                                  "time": planData.time || "",
                                  "isCompleted": false
                              })
    }

    onOpened: {
        loadPlans()
        loadSymptoms()
    }
    Component.onCompleted: {
        console.log("Initial plansModel:", JSON.stringify(plansModel))
    }

    background: Rectangle {
        radius: 10
        color: "white"
        border.color: "#e0e0e0"
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + 40
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: 20

            // Header with date
            Rectangle {
                width: parent.width
                height: 60
                color: "#9c27b0"

                Label {
                    anchors.centerIn: parent
                    text: {
                        var date = new Date(selectedDate)
                        return date.getDate() + " " + root.locale.monthName(
                                    date.getMonth(),
                                    Locale.LongFormat) + " " + date.getFullYear(
                                    )
                    }
                    //text: Qt.formatDate(selectedDate, "d MMMM yyyy")
                    font.pixelSize: 18
                    color: "white"
                }

                Button {
                    anchors {
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Сохранить"
                    flat: true
                    onClicked: {
                        var dataToSave = {
                            "date": selectedDate,
                            "weight": weightField.text,
                            "pressure": pressureField.text,
                            "waist": waistField.text,
                            "mood": moodComboBox.currentText,
                            "notes": notesArea.text,
                            "symptoms": prepareSymptomsData()
                        }
                        saveClicked(dataToSave)
                        close()
                    }
                }
            }

            // Indicators block
            GridLayout {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 2
                columnSpacing: 20
                rowSpacing: 15

                // Weight
                Column {
                    Layout.fillWidth: true
                    spacing: 5
                    Layout.columnSpan: 1

                    Label {
                        text: "Вес (кг)"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    CustomTextField {
                        id: weightField
                        width: parent.width + 10
                        text: weightValue
                        placeholderTextValue: "Введите вес"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                // Waist
                Column {
                    Layout.fillWidth: true
                    spacing: 5
                    Layout.columnSpan: 1

                    Label {
                        text: "Обхват талии (см)"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    CustomTextField {
                        id: waistField
                        width: parent.width + 10
                        text: waistValue
                        placeholderTextValue: "Введите обхват"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                    }
                }

                // Pressure
                Column {
                    Layout.fillWidth: true
                    spacing: 5
                    Layout.columnSpan: 2

                    Label {
                        text: "Давление (мм рт.ст.)"
                        font.pixelSize: 14
                        color: "#666"
                    }
                    CustomTextField {
                        id: pressureField
                        width: parent.width
                        text: pressureValue
                        placeholderTextValue: "120/80"
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /^\d{2,3}\/\d{2,3}$/
                        }
                    }
                }
            }

            // Notes
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                Label {
                    text: "Заметки"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                CustomTextField {
                    id: notesArea
                    width: parent.width
                    height: 100
                    text: notesValue
                    placeholderTextValue: "Введите заметки..."
                    wrapMode: TextArea.Wrap
                }
            }

            // Daily plans
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Планы на день"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                Repeater {
                    model: plansListModel
                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: model.isCompleted ? "#e8f5e9" : "#ffebee"
                        radius: 5
                        border.color: "#bdbdbd"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 10

                            CheckBox {
                                checked: model.isCompleted
                                onCheckedChanged: {
                                    pregnancyCalendarManager.setPlanCompleted(
                                                model.id, checked)
                                    plansListModel.setProperty(index,
                                                               "isCompleted",
                                                               checked)
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                Label {
                                    text: model.description
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Label {
                                    text: (model.time ? model.time + " • " : "") + model.planType
                                    font.pixelSize: 12
                                    color: "#616161"
                                }
                            }

                            Button {
                                text: "✕"
                                flat: true
                                onClicked: {
                                    pregnancyCalendarManager.deletePlan(
                                                model.id)
                                    plansListModel.remove(index)
                                }
                            }
                        }
                    }
                }

                Button {
                    width: parent.width
                    text: "+ Добавить план"
                    flat: true
                    onClicked: planDialog.open()
                }
            }
            // Symptoms
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Симптомы"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                Repeater {
                    model: symptomsListModel
                    delegate: Column {
                        width: parent.width
                        spacing: 5

                        RowLayout {
                            width: parent.width
                            spacing: 10

                            CheckBox {
                                checked: model.isSelected
                                onCheckedChanged: {
                                    symptomsListModel.setProperty(index,
                                                                  "isSelected",
                                                                  checked)
                                    symptomsListModel.setProperty(
                                                index, "severity",
                                                checked ? 1 : 0)
                                }
                            }

                            Label {
                                text: model.name
                                Layout.fillWidth: true
                                font.bold: true
                                color: model.category === "pain" ? "#c62828" : (model.category === "mood" ? "#283593" : "#2e7d32")
                            }
                        }

                        RowLayout {
                            width: parent.width
                            visible: model.isSelected
                            spacing: 10

                            Slider {
                                id: severitySlider
                                Layout.fillWidth: true
                                from: 1
                                to: 5
                                value: model.severity
                                stepSize: 1
                                live: true
                                onMoved: {
                                    symptomsListModel.setProperty(index,
                                                                  "severity",
                                                                  value)
                                }
                            }

                            Label {
                                text: model.severity + "/5"
                                font.bold: true
                            }
                        }

                        CustomTextField {
                            width: parent.width
                            leftPadding: 40
                            visible: model.isSelected
                            placeholderTextValue: "Заметки о симптоме..."
                            text: model.notes
                            onTextChanged: {
                                symptomsListModel.setProperty(index,
                                                              "notes", text)
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#e0e0e0"
                            visible: index < symptomsListModel.count - 1
                        }
                    }
                }
            }

            // Mood
            Column {
                width: parent.width - 40
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Label {
                    text: "Настроение"
                    font.pixelSize: 16
                    color: "#4a148c"
                }

                CustomComboBox {
                    id: moodComboBox
                    width: parent.width
                    model: ["", "вдохновленная", "радостная", "безразличная", "грустная", "злая", "возбужденная", "в панике"]
                    currentIndex: {
                        var moodIndex = model.indexOf(moodValue)
                        return moodIndex >= 0 ? moodIndex : 0
                    }
                }
            }
        }
    }

    // Add plan dialog
    Dialog {
        id: planDialog
        title: "Добавить план"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: parent.width * 0.8

        Column {
            width: parent.width
            spacing: 10

            CustomComboBox {
                id: planTypeCombo
                width: parent.width
                // Модель теперь содержит объекты с ключами и значениями
                model: [{
                        "key": "appointment",
                        "value": "Прием"
                    }, {
                        "key": "medication",
                        "value": "Лекарство"
                    }, {
                        "key": "exercise",
                        "value": "Упражнения"
                    }, {
                        "key": "other",
                        "value": "Другое"
                    }]
                // Указываем какие поля использовать
                textRole: "value" // Отображаемое значение
                //valueRole: "key" // Возвращаемое значение
                currentIndex: 0

                // Текущее выбранное значение (ключ)
                property string currentKey: currentIndex >= 0 ? model[currentIndex][valueRole] : ""

                // Текущее отображаемое значение
                property string currentValue: currentIndex >= 0 ? model[currentIndex][textRole] : ""
            }

            CustomTextField {
                id: planDescription
                width: parent.width
                placeholderTextValue: "Описание"
            }

            CustomTextField {
                id: planTime
                width: parent.width
                placeholderTextValue: "Время (HH:MM)"
                inputMask: "99:99"
            }
        }

        onAccepted: {
            if (planDescription.text.trim() !== "") {
                var planData = {
                    "type": planTypeCombo.currentValue,
                    "description": planDescription.text,
                    "time": planTime.text || "00:00"
                }
                addPlan(selectedDate, planData)

                // Reset fields
                planDescription.text = ""
                planTime.text = ""
            }
        }
    }
}
