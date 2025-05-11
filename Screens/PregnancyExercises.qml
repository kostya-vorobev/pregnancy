import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page {
    id: root
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#e1bee7"

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

    // Модель данных для программы тренировок
    property var trainingProgram: [{
            "day": 1,
            "exercises": [{
                    "sets": 3,
                    "holdTime": 3,
                    "restTime": 5,
                    "completed": false
                }, {
                    "sets": 3,
                    "holdTime": 5,
                    "restTime": 5,
                    "completed": false
                }]
        }, {
            "day": 2,
            "exercises": [{
                    "sets": 4,
                    "holdTime": 3,
                    "restTime": 5,
                    "completed": false
                }, {
                    "sets": 3,
                    "holdTime": 5,
                    "restTime": 5,
                    "completed": false
                }]
        } // ... можно добавить больше дней
    ]

    property int currentDay: 1
    property int currentExercise: 0
    property int currentSet: 0
    property bool isRunning: false
    property int timeLeft: 0
    property string currentPhase: "готово"

    Timer {
        id: exerciseTimer
        interval: 1000
        repeat: true
        onTriggered: {
            timeLeft--
            if (timeLeft <= 0) {
                nextPhase()
            }
        }
    }

    function startExercise() {
        var ex = trainingProgram[currentDay - 1].exercises[currentExercise]
        timeLeft = ex.holdTime
        currentPhase = "сжатие"
        isRunning = true
        exerciseTimer.start()
    }

    function nextPhase() {
        var ex = trainingProgram[currentDay - 1].exercises[currentExercise]

        if (currentPhase === "сжатие") {
            timeLeft = ex.restTime
            currentPhase = "отдых"
        } else {
            currentSet++
            if (currentSet >= ex.sets) {
                currentSet = 0
                currentExercise++
                if (currentExercise >= ex.length) {
                    exerciseComplete()
                    return
                }
            }
            timeLeft = ex.holdTime
            currentPhase = "сжатие"
        }
    }

    function exerciseComplete() {
        trainingProgram[currentDay - 1].exercises[currentExercise].completed = true
        isRunning = false
        currentPhase = "упражнение завершено!"
        exerciseTimer.stop()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // Прогресс выполнения
        Rectangle {
            Layout.fillWidth: true
            height: 30
            radius: 15
            color: "#e0e0e0"

            Rectangle {
                width: parent.width * (currentDay / trainingProgram.length)
                height: parent.height
                radius: 15
                color: primaryColor
            }

            Text {
                text: "День " + currentDay + " из " + trainingProgram.length
                anchors.centerIn: parent
                color: "white"
                font.bold: true
            }
        }

        // Текущее упражнение
        GroupBox {
            Layout.fillWidth: true
            title: "Текущее упражнение"
            background: Rectangle {
                color: "white"
                radius: 10
            }

            ColumnLayout {
                width: parent.width
                spacing: 10

                Text {
                    text: "Фаза: " + currentPhase
                    font.bold: true
                    font.pixelSize: 16
                }

                Text {
                    text: "Осталось: " + timeLeft + " сек"
                    font.pixelSize: 24
                    color: primaryColor
                    Layout.alignment: Qt.AlignHCenter
                }

                ProgressBar {
                    Layout.fillWidth: true
                    value: {
                        var ex = trainingProgram[currentDay - 1].exercises[currentExercise]
                        if (currentPhase === "сжатие")
                            return 1 - (timeLeft / ex.holdTime)
                        else
                            return 1 - (timeLeft / ex.restTime)
                    }
                }

                Button {
                    text: isRunning ? "Пауза" : "Начать"
                    Layout.fillWidth: true
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
            Layout.fillWidth: true
            title: "Программа на день " + currentDay
            background: Rectangle {
                color: "white"
                radius: 10
            }

            ColumnLayout {
                width: parent.width
                spacing: 5

                Repeater {
                    model: trainingProgram[currentDay - 1].exercises

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        CheckBox {
                            checked: modelData.completed
                            onCheckedChanged: modelData.completed = checked
                        }

                        Text {
                            text: "Подходов: " + modelData.sets + ", Сжатие: " + modelData.holdTime
                                  + "сек" + ", Отдых: " + modelData.restTime + "сек"
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // Навигация по дням
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "Предыдущий день"
                Layout.fillWidth: true
                enabled: currentDay > 1
                onClicked: {
                    currentDay--
                    currentExercise = 0
                    currentSet = 0
                    currentPhase = "готово"
                }
            }

            Button {
                text: "Следующий день"
                Layout.fillWidth: true
                enabled: currentDay < trainingProgram.length
                onClicked: {
                    currentDay++
                    currentExercise = 0
                    currentSet = 0
                    currentPhase = "готово"
                }
            }
        }

        // Инструкция
        GroupBox {
            Layout.fillWidth: true
            title: "Инструкция"
            background: Rectangle {
                color: "white"
                radius: 10
            }

            Text {
                width: parent.width
                text: "1. Лягте на спину, согните ноги в коленях\n"
                      + "2. Напрягите мышцы тазового дна (как будто сдерживаете мочеиспускание)\n"
                      + "3. Удерживайте напряжение указанное время\n"
                      + "4. Полностью расслабьте мышцы на время отдыха\n"
                      + "5. Повторите указанное количество подходов"
                wrapMode: Text.WordWrap
                font.pixelSize: 14
            }
        }
    }
}
