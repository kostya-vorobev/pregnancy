import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page {
    id: root

    // Модель данных
    property var tips: [{
            "title": "Питание во время беременности",
            "content": "Основные принципы питания:\n\n• Увеличьте потребление белка\n• Ешьте больше овощей и фруктов\n• Пейте достаточное количество воды\n• Ограничьте кофеин и исключите алкоголь",
            "tags": ["питание", "здоровье"],
            "icon": "🍎",
            "source": "Журнал 'Мама и малыш'"
        }, {
            "title": "Подготовка к родам",
            "content": "Что нужно знать:\n\n1. Пройдите курсы для будущих родителей\n2. Подготовьте сумку в роддом\n3. Изучите техники дыхания\n4. Выберите роддом и врача",
            "tags": ["роды", "подготовка"],
            "icon": "👶",
            "source": "Книга 'Осознанные роды'"
        }, {
            "title": "Развитие плода по неделям",
            "content": "Основные этапы развития:\n\n• 1-12 недель: формирование органов\n• 13-27 недель: активный рост\n• 28-40 недель: подготовка к рождению",
            "tags": ["развитие", "календарь"],
            "icon": "📅",
            "source": "Сайт baby.ru"
        }]

    property var dailyTip: tips[Math.floor(Math.random() * tips.length)]
    property string searchText: ""

    // Функция фильтрации
    function filteredTips() {
        if (!searchText)
            return tips
        const query = searchText.toLowerCase()
        return tips.filter(tip => tip.title.toLowerCase().includes(query)
                           || tip.content.toLowerCase().includes(query)
                           || tip.tags.some(tag => tag.toLowerCase(
                                                ).includes(query)))
    }

    // Фон страницы
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
                text: "Популярные статьи"
                font {
                    family: "Comfortaa"
                    pixelSize: 20
                    bold: true
                }
                Layout.fillWidth: true
            }
        }
    }

    // Основное содержимое
    ColumnLayout {
        anchors.fill: parent
        spacing: 15

        // Поиск
        Rectangle {
            id: searchRect
            anchors.top: toolBarTop.bottom
            anchors.margins: 10
            Layout.fillWidth: true
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
                    onTextChanged: searchText = text
                    background: Item {}
                }
            }
        }

        // Совет дня
        Rectangle {
            id: daylyTipsRect
            anchors.top: searchRect.bottom
            anchors.margins: 10
            Layout.fillWidth: true
            radius: 12
            height: daylyTipsContainer.height
            color: "white"
            border.color: "#e1bee7"
            border.width: 1

            Column {
                id: daylyTipsContainer
                width: parent.width
                padding: 15
                spacing: 10

                Row {
                    spacing: 15
                    width: parent.width

                    Text {
                        text: dailyTip.icon
                        font.pixelSize: 28
                    }

                    Text {
                        text: "Статья дня"
                        font.bold: true
                        color: "#7b1fa2"
                    }
                }

                Text {
                    width: parent.width - 20
                    text: dailyTip.title
                    font.bold: true
                    wrapMode: Text.WordWrap
                }

                Text {
                    width: parent.width
                    text: dailyTip.content
                    wrapMode: Text.WordWrap
                }

                Flow {
                    width: parent.width
                    spacing: 8
                    padding: 5

                    Repeater {
                        model: dailyTip.tags
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
        ListView {
            id: listView
            anchors.margins: 10
            anchors.top: daylyTipsRect.bottom
            Layout.fillWidth: true
            height: 1000
            clip: true
            spacing: 15
            model: filteredTips()

            delegate: Rectangle {
                width: listView.width - 20 // Добавляем небольшой отступ по бокам
                height: expanded ? title.height + content.height + tags.height
                                   + 60 : title.height + 50
                anchors.horizontalCenter: parent.horizontalCenter // Центрируем элемент
                radius: 12
                color: "white"
                border.color: "#e1bee7"
                border.width: 1

                property bool expanded: false

                Column {
                    width: parent.width
                    padding: 15
                    spacing: 10

                    // Вопрос
                    Row {
                        width: parent.width
                        spacing: 15

                        Text {
                            text: modelData.icon
                            font.pixelSize: 24
                        }
                        Column {
                            width: parent.width
                            spacing: 5
                            Text {
                                id: title
                                width: parent.width - 70
                                text: modelData.title
                                font.bold: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: expanded ? 0 : 2
                                elide: Text.ElideRight
                            }
                            Text {
                                id: source
                                width: parent.width - 70
                                text: modelData.source
                                wrapMode: Text.WordWrap
                                maximumLineCount: expanded ? 0 : 2
                                elide: Text.ElideRight
                            }
                        }
                    }

                    // Ответ
                    Text {
                        id: content
                        width: parent.width - 20
                        text: modelData.content
                        visible: expanded
                        wrapMode: Text.WordWrap
                    }

                    // Теги
                    Row {
                        id: tags
                        width: parent.width
                        spacing: 8
                        visible: expanded

                        Repeater {
                            model: modelData.tags
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
}
