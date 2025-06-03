import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page {
    id: root
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#e1bee7"

    // Свойства для работы с базой данных
    property var currentProgram: ({
                                      "days": []
                                  })
    property int currentProgramId: 1
    property int currentDayIndex: 0
    property int currentExerciseIndex: 0
    property int currentSet: 0
    property bool isRunning: false
    property int timeLeft: 0
    property string currentPhase: "готово"
    property string programDescription: ""

    // Модель для списка программ
    ListModel {
        id: programsModel
    }

    Component.onCompleted: {
        loadProgramsList()
    }

    function loadProgramsList() {
        programsModel.clear()
        var programs = exerciseManager.getAllTrainingPrograms()
        programs.forEach(function (program) {
            programsModel.append({
                                     "id": program.id,
                                     "name": program.name,
                                     "description": program.description
                                 })
        })
        if (programsModel.count > 0) {
            currentProgramId = programsModel.get(0).id
            loadTrainingProgram()
        }
    }

    function loadTrainingProgram() {
        var programData = exerciseManager.getTrainingProgram(currentProgramId)
        console.log("Loaded program data:", JSON.stringify(programData))

        if (programData && programData.days) {
            currentProgram = programData
            var currentDay = exerciseManager.getCurrentDayForProgram(
                        currentProgramId)
            currentDayIndex = Math.max(currentDay - 1, 0)

            // Сброс состояния тренировки
            currentExerciseIndex = 0
            currentSet = 0
            isRunning = false
            timeLeft = 0
            currentPhase = "готово"
            updateProgramDescription()
            updateInstructions()
        } else {
            console.error("Program data is empty or invalid")
        }
    }

    function updateProgramDescription() {
        for (var i = 0; i < programsModel.count; i++) {
            if (programsModel.get(i).id === currentProgramId) {
                programDescription = programsModel.get(i).description
                break
            }
        }
    }

    function updateInstructions() {
        var instructions = {
            "1": "1. Медленно сожмите мышцы на выдохе\n" + "2. Удерживайте 5-10 секунд\n"
                 + "3. Полностью расслабьтесь\n" + "4. Повторите 8-10 раз",
            "2": "1. Быстро сокращайте мышцы 8-10 раз подряд\n"
                 + "2. Короткий отдых между подходами\n"
                 + "3. Особенно полезно при стрессовом недержании",
            "3": "1. Постепенно увеличивайте интенсивность сокращения\n"
                 + "2. Удерживайте максимальное напряжение до 10 сек\n"
                 + "3. Медленно расслабляйтесь",
            "4": "1. Сокращайте мышцы поэтапно (как этажи лифта)\n"
                 + "2. На каждом уровне задерживайтесь на 2-3 сек\n"
                 + "3. Так же постепенно расслабляйтесь",
            "5": "1. Чередуйте быстрые и медленные сокращения\n"
                 + "2. 5 сек медленно, затем 1 сек быстро\n" + "3. 10 повторений на подход"
        }
        instructionText.text = instructions[currentProgramId]
                || "Выберите программу тренировки"
    }

    header: ToolBar {
        Material.foreground: "white"
        background: Rectangle {
            color: root.primaryColor
        }

        RowLayout {
            anchors.fill: parent
            ToolButton {
                icon.source: "qrc:/Images/icons/arrow_back.svg"
                onClicked: stackView.pop()
            }
            Label {
                text: "Упражнения Кегеля"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                Layout.fillWidth: true
            }
        }
    }

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

    Timer {
        id: exerciseTimer
        interval: 1000
        repeat: true
        onTriggered: {
            timeLeft--
            if (timeLeft <= 0)
                nextPhase()
        }
    }

    function startExercise() {
        if (currentProgram.days.length > 0
                && currentDayIndex < currentProgram.days.length
                && currentExerciseIndex < currentProgram.days[currentDayIndex].exercises.length) {

            var ex = currentProgram.days[currentDayIndex].exercises[currentExerciseIndex]

            switch (currentProgramId) {
            case 2:
                // Быстрые сокращения
                timeLeft = ex.sets * ex.holdTime
                currentPhase = "быстрые сокращения"
                break
            case 5:
                // Чередование
                timeLeft = (currentSet % 2 === 0) ? ex.holdTime : 1
                currentPhase = (currentSet % 2 === 0) ? "медленное сжатие" : "быстрое сжатие"
                break
            default:
                timeLeft = ex.holdTime
                currentPhase = "сжатие"
            }

            isRunning = true
            exerciseTimer.start()
        }
    }

    function nextPhase() {
        var day = currentProgram.days[currentDayIndex]
        var ex = day.exercises[currentExerciseIndex]

        switch (currentProgramId) {
        case 2:
            if (currentPhase === "быстрые сокращения") {
                currentSet++
                if (currentSet >= ex.sets) {
                    exerciseComplete()
                    return
                }
                timeLeft = ex.holdTime
            }
            break
        case 5:
            if (currentPhase.includes("сжатие")) {
                currentSet++
                if (currentSet >= ex.sets * 2) {
                    exerciseComplete()
                    return
                }
                timeLeft = (currentSet % 2 === 0) ? ex.holdTime : 1
                currentPhase = (currentSet % 2 === 0) ? "медленное сжатие" : "быстрое сжатие"
            }
            break
        default:
            if (currentPhase === "сжатие") {
                timeLeft = ex.restTime
                currentPhase = "отдых"
            } else {
                currentSet++
                if (currentSet >= ex.sets) {
                    currentSet = 0
                    currentExerciseIndex++
                    if (currentExerciseIndex >= day.exercises.length) {
                        exerciseComplete()
                        return
                    }
                    exerciseManager.markExerciseCompleted(ex.id, true)
                }
                timeLeft = ex.holdTime
                currentPhase = "сжатие"
            }
        }
    }

    function exerciseComplete() {
        var day = currentProgram.days[currentDayIndex]
        var ex = day.exercises[currentExerciseIndex]

        exerciseManager.markExerciseCompleted(ex.id, true)

        isRunning = false
        currentPhase = "упражнение завершено!"
        exerciseTimer.stop()

        var completedCount = exerciseManager.getCompletedExercisesCount(day.id)
        if (completedCount === day.exercises.length) {
            exerciseManager.markDayCompleted(day.id, true)
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: contentColumn.height + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width - 20
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10

            // Выбор программы
            GroupBox {
                width: parent.width
                title: "Программа тренировок"
                background: Rectangle {
                    color: "white"
                    radius: 10
                }

                Column {
                    width: parent.width
                    spacing: 10
                    leftPadding: 10
                    rightPadding: 10

                    ComboBox {
                        id: programSelector
                        width: parent.width - 20
                        model: programsModel
                        textRole: "name"
                        onActivated: function (index) {
                            currentProgramId = programsModel.get(index).id
                            exerciseManager.setCurrentProgram(currentProgramId)
                            loadTrainingProgram()
                        }
                    }

                    Text {
                        text: programDescription
                        width: parent.width - 20
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        color: "#555"
                    }
                }
            }

            // Прогресс выполнения
            Rectangle {
                width: parent.width
                height: 30
                radius: 15
                color: "#e0e0e0"
                visible: currentProgram.days && currentProgram.days.length > 0

                Rectangle {
                    width: parent.width * ((currentDayIndex + 1)
                                           / (currentProgram.days ? currentProgram.days.length : 1))
                    height: parent.height
                    radius: 15
                    color: primaryColor
                }

                Text {
                    text: currentProgram.days && currentProgram.days.length
                          > 0 ? "День " + (currentDayIndex + 1) + " из "
                                + currentProgram.days.length : "Загрузка..."
                    anchors.centerIn: parent
                    color: "white"
                    font.bold: true
                }
            }

            // Текущее упражнение
            GroupBox {
                width: parent.width
                title: "Текущее упражнение"
                background: Rectangle {
                    color: "white"
                    radius: 10
                }
                visible: currentProgram.days && currentProgram.days.length > 0

                Column {
                    width: parent.width
                    spacing: 10
                    leftPadding: 10
                    rightPadding: 10

                    Text {
                        text: "Фаза: " + currentPhase
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: "Осталось: " + timeLeft + " сек"
                        font.pixelSize: 24
                        color: primaryColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ProgressBar {
                        width: parent.width - 20
                        value: {
                            if (currentProgram.days
                                    && currentProgram.days.length > 0
                                    && currentDayIndex < currentProgram.days.length
                                    && currentExerciseIndex
                                    < currentProgram.days[currentDayIndex].exercises.length) {

                                var ex = currentProgram.days[currentDayIndex].exercises[currentExerciseIndex]
                                if (currentPhase === "сжатие"
                                        || currentPhase === "медленное сжатие"
                                        || currentPhase === "быстрое сжатие")
                                    return 1 - (timeLeft / ex.holdTime)
                                else if (currentPhase === "отдых")
                                    return 1 - (timeLeft / ex.restTime)
                                else if (currentPhase === "быстрые сокращения")
                                    return 1 - (timeLeft / (ex.sets * ex.holdTime))
                            }
                            return 0
                        }
                    }

                    Button {
                        width: parent.width - 20
                        text: isRunning ? "Пауза" : "Начать"
                        Material.background: primaryColor
                        Material.foreground: "white"
                        onClicked: {
                            if (isRunning) {
                                exerciseTimer.stop()
                                isRunning = false
                            } else {
                                if (currentPhase === "готово")
                                    startExercise()
                                else
                                    exerciseTimer.start()
                                isRunning = true
                            }
                        }
                    }
                }
            }

            // Программа на день
            GroupBox {
                width: parent.width
                title: "Программа на день " + (currentDayIndex + 1)
                background: Rectangle {
                    color: "white"
                    radius: 10
                }
                visible: currentProgram.days && currentProgram.days.length > 0

                Column {
                    width: parent.width
                    spacing: 5
                    leftPadding: 10
                    rightPadding: 10

                    Repeater {
                        model: currentProgram.days && currentProgram.days.length
                               > 0 ? currentProgram.days[currentDayIndex].exercises : 0

                        delegate: Row {
                            width: parent.width
                            spacing: 10
                            topPadding: 5
                            bottomPadding: 5

                            CheckBox {
                                checked: modelData.isCompleted
                                onCheckedChanged: exerciseManager.markExerciseCompleted(
                                                      modelData.id, checked)
                            }

                            Text {
                                text: {
                                    var txt = "Подходов: " + modelData.sets
                                    if (currentProgramId === 2) {
                                        txt += ", Быстрых сокращений: " + modelData.holdTime + "сек"
                                    } else if (currentProgramId === 5) {
                                        txt += ", Чередование: " + modelData.holdTime
                                                + "сек медленно + 1сек быстро"
                                    } else {
                                        txt += ", Сжатие: " + modelData.holdTime + "сек"
                                    }
                                    txt += ", Отдых: " + modelData.restTime + "сек"
                                    return txt
                                }
                                width: parent.width - 50
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            // Навигация по дням
            Row {
                width: parent.width
                spacing: 10
                visible: currentProgram.days && currentProgram.days.length > 0
                leftPadding: 10
                rightPadding: 10

                Button {
                    width: (parent.width - 20) / 2
                    text: "Предыдущий день"
                    enabled: currentDayIndex > 0
                    onClicked: {
                        currentDayIndex--
                        currentExerciseIndex = 0
                        currentSet = 0
                        currentPhase = "готово"
                    }
                }

                Button {
                    width: (parent.width - 20) / 2
                    text: "Следующий день"
                    enabled: currentDayIndex < currentProgram.days.length - 1
                    onClicked: {
                        currentDayIndex++
                        currentExerciseIndex = 0
                        currentSet = 0
                        currentPhase = "готово"
                    }
                }
            }

            // Инструкция
            GroupBox {
                id: instructionBox
                width: parent.width
                title: "Инструкция"
                background: Rectangle {
                    color: "white"
                    radius: 10
                }

                Text {
                    id: instructionText
                    width: parent.width - 20
                    leftPadding: 10
                    rightPadding: 10
                    wrapMode: Text.WordWrap
                    font.pixelSize: 14
                }
            }
        }
    }
}
