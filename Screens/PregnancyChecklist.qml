import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root
    padding: 16

    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#e1bee7"

    ChecklistManager {
        id: checklistManager
        onChecklistsChanged: updateChecklistModels()
        onTasksChanged: updateChecklistModels()
    }

    function updateChecklistModels() {
        firstTrimester.model.clear()
        secondTrimester.model.clear()
        thirdTrimester.model.clear()
        generalRecommendations.model.clear()

        for (var i = 0; i < checklistManager.tasks.length; i++) {
            var task = checklistManager.tasks[i]
            var checklist = getChecklistById(task.checklistId)

            if (!checklist)
                continue

            var taskData = {
                "text": task.title,
                "checked": Boolean(task.isCompleted),
                "taskId"// Явное преобразование в bool
                : task.id
            }

            if (checklist.trimester === 1) {
                firstTrimester.model.append(taskData)
            } else if (checklist.trimester === 2) {
                secondTrimester.model.append(taskData)
            } else if (checklist.trimester === 3) {
                thirdTrimester.model.append(taskData)
            } else if (checklist.category === "general") {
                generalRecommendations.model.append(taskData)
            }
        }
    }

    function getChecklistById(id) {
        for (var i = 0; i < checklistManager.checklists.length; i++) {
            if (checklistManager.checklists[i].id === id) {
                return checklistManager.checklists[i]
            }
        }
        return null
    }

    function handleTaskToggled(taskId, isChecked) {
        checklistManager.updateTaskStatus(taskId, isChecked)
    }

    Component.onCompleted: checklistManager.loadChecklists()

    // Остальной интерфейс остается без изменений
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
                text: "Чеклист беременности"
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
        anchors.fill: parent
        anchors.top: header.bottom
        contentHeight: contentColumn.height
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 20

            PregnancyTrimesterSection {
                id: firstTrimester
                title: "Первый триместр (1-12 недель)"
                indicatorColor: "#e1bee7"
                model: ListModel {}

                // Обработчик изменения состояния задач
                onTaskToggled: function (taskId, isChecked) {
                    handleTaskToggled(taskId, isChecked)
                }
            }

            PregnancyTrimesterSection {
                id: secondTrimester
                title: "Второй триместр (13-27 недель)"
                indicatorColor: "#ce93d8"
                model: ListModel {}
                onTaskToggled: handleTaskToggled
            }

            PregnancyTrimesterSection {
                id: thirdTrimester
                title: "Третий триместр (28-40 недель)"
                indicatorColor: "#ba68c8"
                model: ListModel {}
                onTaskToggled: handleTaskToggled
            }

            PregnancyTrimesterSection {
                id: generalRecommendations
                title: "Общие рекомендации"
                indicatorColor: "#ab47bc"
                model: ListModel {}
                onTaskToggled: handleTaskToggled
            }
        }
    }

    component PregnancyTrimesterSection: ColumnLayout {
        id: sectionRoot
        property string title
        property color indicatorColor
        property ListModel model

        signal taskToggled(int taskId, bool checked)

        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            id: header
            Layout.fillWidth: true
            height: 56
            radius: 12
            color: Qt.lighter(indicatorColor, 1.4)
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 8
                samples: 16
                color: "#20000000"
                verticalOffset: 2
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: sectionRoot.indicatorColor
                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (sectionRoot.title.includes("Первый"))
                                return "1"
                            if (sectionRoot.title.includes("Второй"))
                                return "2"
                            if (sectionRoot.title.includes("Третий"))
                                return "3"
                            return "★"
                        }
                        color: "white"
                        font {
                            pixelSize: 16
                            bold: true
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: titleText.implicitHeight
                    Text {
                        id: titleText
                        anchors.right: progressBar.left
                        anchors.left: parent.left
                        text: sectionRoot.title
                        font {
                            pixelSize: 16
                            bold: true
                            family: "Comfortaa"
                        }
                        color: "#4a148c"
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    ProgressIndicator {
                        id: progressBar
                        width: 80
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        progress: {
                            var completed = 0
                            for (var i = 0; i < sectionRoot.model.count; i++) {
                                if (sectionRoot.model.get(i).checked)
                                    completed++
                            }
                            return completed / sectionRoot.model.count
                        }
                        color: sectionRoot.indicatorColor
                    }
                }
            }
        }

        Repeater {
            model: sectionRoot.model
            delegate: MyComponents.ChecklistItem {
                text: model.text
                checked: model.checked
                taskId: model.taskId
                indicatorColor: sectionRoot.indicatorColor
                Layout.fillWidth: true
                opacity: 0

                NumberAnimation on opacity {
                    from: 0
                    to: 1
                    duration: 300
                    running: true
                }

                onToggled: function (taskId, isChecked) {
                    // Обновляем модель
                    sectionRoot.model.setProperty(index, "checked", isChecked)
                    // Пробрасываем сигнал выше
                    sectionRoot.taskToggled(taskId, isChecked)
                }
            }
        }
    }

    component ProgressIndicator: Item {
        property real progress: 0
        property color color: "#9c27b0"
        implicitWidth: 64
        implicitHeight: 24

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "#e0e0e0"
        }

        Rectangle {
            width: parent.width * parent.progress
            height: parent.height
            radius: height / 2
            color: parent.color
            Behavior on width {
                NumberAnimation {
                    duration: 300
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: Math.round(parent.progress * 100) + "%"
            font {
                pixelSize: 10
                bold: true
            }
            color: "#4a148c"
        }
    }
}
