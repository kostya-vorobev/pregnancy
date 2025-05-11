import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Page {
    id: root

    property var tips: [{
            "question": "Какие витамины нужно принимать?",
            "answer": "В первом триместре обязательна фолиевая кислота (400 мкг/день). По назначению врача - йод, железо, витамин D и другие. Избегайте избытка витамина А.",
            "tags": ["витамины", "питание"],
            "icon": "💊"
        }, {
            "question": "Можно ли заниматься спортом?",
            "answer": "Да, но с умеренной интенсивностью. Рекомендуются:\n• Йога для беременных\n• Плавание\n• Ходьба\nИзбегайте травмоопасных видов спорта.",
            "tags": ["спорт", "активность"],
            "icon": "🏃‍♀️"
        }, {
            "question": "Как бороться с токсикозом?",
            "answer": "Эффективные методы:\n1. Ешьте маленькими порциями\n2. Пейте имбирный чай\n3. Избегайте резких запахов\nПри сильном токсикозе обратитесь к врачу.",
            "tags": ["здоровье", "токсикоз"],
            "icon": "🤢"
        }, {
            "question": "Когда начинать готовиться к родам?",
            "answer": "Рекомендуемый график:\n- Курсы для беременных (с 20 недели)\n- Сбор сумки в роддом (к 36 неделе)\n- Выбор роддома (к 30 неделе)",
            "tags": ["роды", "подготовка"],
            "icon": "👶"
        }, {
            "question": "Какой режим сна оптимален?",
            "answer": "Советы:\n• Спать 8-10 часов ночью\n• Дневной отдых 1-2 часа\n• После 20 недель спать на боку\n• Использовать подушки для удобства",
            "tags": ["сон", "режим"],
            "icon": "😴"
        }]

    property var dailyTip: tips[new Date().getDay() % tips.length]
    property string searchText: ""

    function filteredTips() {
        if (searchText === "")
            return tips
        return tips.filter(
                    tip => tip.question.toLowerCase().includes(
                        searchText.toLowerCase())
                    || tip.answer.toLowerCase().includes(
                        searchText.toLowerCase())
                    || tip.tags.some(tag => tag.toLowerCase(
                                         ).includes(searchText.toLowerCase())))
    }

    background: Rectangle {
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#faf4ff"
            }
            GradientStop {
                position: 1.0
                color: "#eedfff"
            }
        }
    }

    header: ToolBar {
        background: Rectangle {
            color: "#9c27b0"
        }

        RowLayout {
            anchors.fill: parent
            spacing: 10

            ToolButton {
                icon.source: "qrc:/images/arrow_back.svg"
                icon.color: "white"
                onClicked: stackView.pop()
            }

            Label {
                text: "Советы для беременных"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                color: "white"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // Поисковая строка
        MyComponents.Card {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "🔍"
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Поиск советов..."
                    font.pixelSize: 14
                    background: Item {}
                    onTextChanged: searchText = text
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        // Совет дня
        MyComponents.Card {
            Layout.fillWidth: true
            Layout.preferredHeight: dailyTipColumn.implicitHeight + 24

            ColumnLayout {
                id: dailyTipColumn
                width: parent.width
                spacing: 10
                anchors.margins: 12

                RowLayout {
                    spacing: 15

                    Text {
                        text: dailyTip.icon
                        font.pixelSize: 28
                    }

                    Text {
                        text: "Совет дня"
                        font {
                            pixelSize: 18
                            bold: true
                            family: "Comfortaa"
                        }
                        color: "#7b1fa2"
                    }
                }

                Text {
                    text: dailyTip.question
                    font {
                        pixelSize: 16
                        bold: true
                    }
                    color: "#4a148c"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Text {
                    text: dailyTip.answer
                    font.pixelSize: 14
                    color: "#4a148c"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                }

                Flow {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.topMargin: 10

                    Repeater {
                        model: dailyTip.tags
                        delegate: MyComponents.Tag {
                            text: "#" + modelData
                            backgroundColor: "#e1bee7"
                            textColor: "#7b1fa2"
                            Layout.alignment: Qt.AlignLeft
                        }
                    }
                }
            }
        }

        // Разделитель
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#d1c4e9"
            opacity: 0.5
        }

        // Частые вопросы
        Text {
            text: "Частые вопросы"
            font {
                pixelSize: 18
                bold: true
                family: "Comfortaa"
            }
            color: "#7b1fa2"
            Layout.leftMargin: 5
        }

        // Список вопросов
        ListView {
            id: questionsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 15
            model: filteredTips()

            delegate: MyComponents.Card {
                width: questionsList.width
                height: questionColumn.implicitHeight
                        + (expanded ? answerColumn.implicitHeight : 0) + 24

                Column {
                    id: questionColumn
                    width: parent.width
                    padding: 12
                    spacing: 5

                    Row {
                        width: parent.width - 24
                        spacing: 15

                        Text {
                            text: modelData.icon
                            font.pixelSize: 28
                        }

                        Text {
                            width: parent.width - 100
                            text: modelData.question
                            font {
                                pixelSize: 16
                                bold: true
                            }
                            color: "#4a148c"
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }

                        Text {
                            text: expanded ? "▲" : "▼"
                            font.pixelSize: 16
                            opacity: 0.6
                        }
                    }
                }

                Column {
                    id: answerColumn
                    width: parent.width
                    padding: 12

                    spacing: 10
                    visible: expanded

                    Text {
                        width: parent.width - 24
                        text: modelData.answer
                        font.pixelSize: 14
                        color: "#4a148c"
                        wrapMode: Text.WordWrap
                    }

                    Flow {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: modelData.tags
                            delegate: MyComponents.Tag {
                                text: "#" + modelData
                                backgroundColor: "#f3e5f5"
                                textColor: "#7b1fa2"
                            }
                        }
                    }
                }

                property bool expanded: false

                MouseArea {
                    anchors.fill: parent
                    onClicked: parent.expanded = !parent.expanded
                }
            }
        }
    }
}
