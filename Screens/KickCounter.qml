import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root
    padding: 20

    FetalKickManager {
        id: kickManager
        onKickHistoryChanged: {
            console.log("Received history data:",
                        JSON.stringify(kickManager.kickHistory))
            internalKickHistory.clear()
            if (kickManager.kickHistory && kickManager.kickHistory.length > 0) {
                for (var i = 0; i < kickManager.kickHistory.length; i++) {
                    var item = kickManager.kickHistory[i]
                    console.log("Adding item:", JSON.stringify(item))
                    internalKickHistory.append({
                                                   "id": item.id || 0,
                                                   "date": item.date || "",
                                                   "time": item.time || "",
                                                   "count": item.count || 0,
                                                   "duration": item.duration
                                                               || 0,
                                                   "notes": item.notes || "",
                                                   "saved": true
                                               })
                }
            }
        }
    }

    property int kickCount: 0
    property alias kickHistory: internalKickHistory
    property string lastKickTime: ""
    property date sessionStartTime: new Date()
    property bool isSessionActive: false

    ListModel {
        id: internalKickHistory
    }

    background: Rectangle {
        color: "#faf4ff"
    }

    function startNewSession() {
        kickCount = 0
        lastKickTime = ""
        sessionStartTime = new Date()
        isSessionActive = true
    }

    function saveCurrentSession() {
        if (kickCount > 0) {
            var duration = Math.floor((new Date() - sessionStartTime) / 60000)
            saveDialog.sessionData = {
                "count": kickCount,
                "duration": duration,
                "date": sessionStartTime.toLocaleDateString(Qt.locale(),
                                                            Locale.ShortFormat),
                "time": sessionStartTime.toLocaleTimeString(Qt.locale(),
                                                            "hh:mm")
            }
            saveDialog.open()
        }
    }
    property color primaryColor: "#9c27b0"

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
                text: "Толчки малыша"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                Layout.fillWidth: true
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        // Основной счетчик
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16
            width: 200
            height: 200
            radius: width / 2
            color: isSessionActive ? "#f3e5f5" : "#e1bee7"
            border.color: isSessionActive ? "#ba68c8" : "#9c27b0"
            border.width: 4

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#40000000"
                shadowVerticalOffset: 4
                shadowBlur: 8
            }

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: isSessionActive ? "Толчков" : "Нажмите чтобы начать"
                    font {
                        pixelSize: 16
                        family: "Comfortaa"
                    }
                    color: "#7b1fa2"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: root.kickCount
                    font {
                        pixelSize: 48
                        bold: true
                        family: "Comfortaa"
                    }
                    color: "#9c27b0"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    visible: root.lastKickTime !== ""
                    text: "Последний: " + root.lastKickTime
                    font.pixelSize: 12
                    color: "#ab47bc"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!isSessionActive) {
                        startNewSession()
                    } else {
                        kickCount++
                        lastKickTime = new Date().toLocaleTimeString(
                                    Qt.locale(), "hh:mm")
                    }
                }
            }
        }

        // Кнопки управления
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            MyComponents.CustomButton {
                id: resetButton
                text: "Сбросить"
                Layout.preferredWidth: 120
                Layout.preferredHeight: 48
                enabled: isSessionActive
                onClicked: startNewSession()
            }

            MyComponents.CustomButton {
                id: saveButton
                text: "Сохранить"
                Layout.preferredWidth: 120
                Layout.preferredHeight: 48
                enabled: isSessionActive && kickCount > 0
                onClicked: saveCurrentSession()
            }
        }

        // История
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Label {
                text: "История наблюдений"
                font {
                    family: "Comfortaa"
                    pixelSize: 18
                    bold: true
                }
                color: "#7b1fa2"
                Layout.alignment: Qt.AlignLeft
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#ffffff"
                border.color: "#e1bee7"
                border.width: 1

                ListView {
                    id: historyList
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    model: kickHistory
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds

                    Label {
                        anchors.centerIn: parent
                        text: "Нет сохраненных данных"
                        visible: kickHistory.count === 0
                        font.pixelSize: 16
                        color: "#9c27b0"
                    }

                    delegate: Rectangle {
                        width: historyList.width
                        height: 60
                        radius: 8
                        color: model.saved ? "#f3e5f5" : "#faf4ff"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Column {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: model.date + " в " + model.time
                                    font {
                                        pixelSize: 14
                                        family: "Roboto"
                                    }
                                    color: "#4a148c"
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: model.notes
                                    text: model.notes
                                    font {
                                        pixelSize: 11
                                        family: "Roboto"
                                        italic: true
                                    }
                                    color: "#7b1fa2"
                                    width: parent.width
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            Text {
                                text: model.count + " толчков"
                                font {
                                    pixelSize: 16
                                    family: "Comfortaa"
                                    bold: true
                                }
                                color: "#9c27b0"
                                Layout.minimumWidth: 100
                                horizontalAlignment: Text.AlignRight
                            }

                            Button {
                                width: 30
                                height: 30
                                icon.source: "qrc:/Images/icons/delete.svg"
                                icon.color: "#e53935"
                                flat: true
                                onClicked: {
                                    deleteDialog.sessionId = model.id
                                    deleteDialog.open()
                                }
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 8
                    }
                }
            }

            // Подсказка
            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 8
                text: isSessionActive ? "Нажимайте на круг при каждом толчке малыша" : "Нажмите на круг, чтобы начать новый сеанс"
                font.pixelSize: 12
                color: "#ab47bc"
            }
        }
    }

    // Диалог сохранения
    Dialog {
        id: saveDialog
        title: "Сохранение сеанса"
        standardButtons: Dialog.Save | Dialog.Cancel
        modal: true
        Layout.fillWidth: true
        property var sessionData: ({})

        ColumnLayout {
            width: parent.width
            spacing: 15

            Label {
                text: `Будет сохранена сессия:\n${sessionData.count} толчков за ${sessionData.duration} минут`
                wrapMode: Text.WordWrap
            }

            MyComponents.CustomTextField {
                id: notesField
                Layout.fillWidth: true
                placeholderTextValue: "Заметки (необязательно)"
            }
        }

        onAccepted: {
            kickManager.saveKickSession(sessionData.count, notesField.text)
            root.isSessionActive = false
            notesField.text = ""
        }
    }

    // Диалог удаления
    Dialog {
        id: deleteDialog
        title: "Удаление записи"
        standardButtons: Dialog.Yes | Dialog.No
        modal: true
        width: 300
        property int sessionId: -1

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            text: "Вы действительно хотите удалить эту запись?"
        }

        onAccepted: kickManager.deleteKickSession(sessionId)
    }

    Component.onCompleted: {
        console.log("Initializing kick counter...")
        kickManager.loadKickHistory()
    }
}
