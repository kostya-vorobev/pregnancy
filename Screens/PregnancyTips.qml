import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root

    TipManager {
        id: tipManager
        onTipsChanged: updateFilteredTips()
        onDailyTipChanged: updateDailyTipUI()
    }

    property string searchText: ""

    function updateFilteredTips() {
        if (!searchText) {
            listView.model = tipManager.tips
            return
        }

        const query = searchText.toLowerCase()
        var filtered = []
        for (var i = 0; i < tipManager.tips.length; i++) {
            var tip = tipManager.tips[i]
            var matches = tip.question.toLowerCase().includes(query)
                    || tip.answer.toLowerCase().includes(query)

            if (!matches) {
                // Проверяем теги
                for (var j = 0; j < tip.tags.length; j++) {
                    if (tip.tags[j].toLowerCase().includes(query)) {
                        matches = true
                        break
                    }
                }
            }

            if (matches) {
                filtered.push(tip)
            }
        }
        listView.model = filtered
    }

    function updateDailyTipUI() {
        dailyTipData = tipManager.dailyTip
    }

    property var dailyTipData: ({})

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
                text: "Советы для беременных"
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
        spacing: 15

        // Поиск
        Rectangle {
            id: searchRect
            Layout.fillWidth: true
            Layout.topMargin: 10
            height: 50
            radius: 25
            color: "white"
            border.color: "#d1c4e9"
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10

                Text {
                    text: "🔍"
                    font.pixelSize: 20
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Поиск советов..."
                    onTextChanged: {
                        searchText = text
                        updateFilteredTips()
                    }
                    background: Item {}
                }
            }
        }

        // Совет дня
        Rectangle {
            id: dailyTipRect
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            radius: 12
            height: dailyTipContainer.height
            color: "white"
            border.color: "#e1bee7"
            border.width: 1

            Column {
                id: dailyTipContainer
                width: parent.width
                height: 200
                padding: 15
                spacing: 10

                Row {
                    spacing: 15
                    width: parent.width

                    Text {
                        text: dailyTipData.icon || "💡"
                        font.pixelSize: 28
                    }

                    Text {
                        text: "Совет дня"
                        font.bold: true
                        color: "#7b1fa2"
                    }
                }

                Text {
                    width: parent.width - 20
                    text: dailyTipData.question || "Загрузка..."
                    font.bold: true
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: dailyTipData.answer || ""
                    wrapMode: Text.WordWrap
                }

                Flow {
                    width: parent.width
                    spacing: 8
                    padding: 5

                    Repeater {
                        model: dailyTipData.tags || []
                        delegate: Rectangle {
                            height: 25
                            radius: 12
                            color: "#e1bee7"
                            width: tagText.width + 20

                            Text {
                                id: tagText
                                text: "#" + modelData
                                anchors.centerIn: parent
                                color: "#7b1fa2"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }

        // Список советов
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            clip: true
            spacing: 15
            model: tipManager.tips

            delegate: Rectangle {
                width: listView.width - 20
                height: expanded ? contentColumn.height + 40 : questionRow.height + 30
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 12
                color: "white"
                border.color: "#e1bee7"
                border.width: 1

                property bool expanded: false

                Column {
                    id: contentColumn
                    width: parent.width
                    padding: 15
                    spacing: 10

                    // Вопрос
                    Row {
                        id: questionRow
                        width: parent.width
                        spacing: 15

                        Text {
                            text: modelData.icon || "💡"
                            font.pixelSize: 24
                        }

                        Text {
                            width: parent.width - 70
                            text: modelData.question
                            font.bold: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: expanded ? 0 : 2
                            elide: Text.ElideRight
                        }

                        Button {
                            icon.source: modelData.isFavorite ? "qrc:/Images/icons/favorite_filled.svg" : "qrc:/Images/icons/favorite_border.svg"
                            flat: true
                            onClicked: tipManager.toggleFavorite(modelData.id)
                        }
                    }

                    // Ответ
                    Text {
                        width: parent.width - 20
                        text: modelData.answer
                        visible: expanded
                        wrapMode: Text.WordWrap
                    }

                    // Теги
                    Flow {
                        width: parent.width
                        spacing: 8
                        visible: expanded

                        Repeater {
                            model: modelData.tags || []
                            delegate: Rectangle {
                                height: 25
                                radius: 12
                                color: "#f3e5f5"
                                width: tagText1.width + 20

                                Text {
                                    id: tagText1
                                    text: "#" + modelData
                                    anchors.centerIn: parent
                                    color: "#7b1fa2"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                TapHandler {
                    onTapped: parent.expanded = !parent.expanded
                }
            }
        }
    }

    Component.onCompleted: {
        tipManager.loadTips()
    }
}
