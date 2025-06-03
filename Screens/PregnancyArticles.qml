import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root

    ArticleManager {
        id: articleManager
        onArticlesChanged: updateFilteredArticles()
        onDailyArticleChanged: updateDailyArticleUI()
    }

    property string searchText: ""

    function updateFilteredArticles() {
        if (!searchText) {
            listView.model = articleManager.articles
            return
        }

        const query = searchText.toLowerCase()
        var filtered = []
        for (var i = 0; i < articleManager.articles.length; i++) {
            var article = articleManager.articles[i]
            var matches = article.title.toLowerCase().includes(query)
                    || article.content.toLowerCase().includes(query)

            if (!matches) {
                // Проверяем категории
                for (var j = 0; j < article.categories.length; j++) {
                    if (article.categories[j].toLowerCase().includes(query)) {
                        matches = true
                        break
                    }
                }
            }

            if (!matches) {
                // Проверяем теги
                for (var k = 0; k < article.tags.length; k++) {
                    if (article.tags[k].toLowerCase().includes(query)) {
                        matches = true
                        break
                    }
                }
            }

            if (matches) {
                filtered.push(article)
            }
        }
        listView.model = filtered
    }

    function updateDailyArticleUI() {
        dailyArticleData = articleManager.dailyArticle
    }

    property var dailyArticleData: ({})

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

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: mainColumn.height
        clip: true

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: 15

            // Поиск
            Rectangle {
                id: searchRect
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
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

                    MyComponents.CustomTextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderTextValue: "Поиск статей..."
                        onTextChanged: {
                            searchText = text
                            updateFilteredArticles()
                        }
                        background: Item {}
                    }
                }
            }

            // Заголовок списка статей
            Text {
                text: "Все статьи"
                font {
                    family: "Comfortaa"
                    pixelSize: 18
                    bold: true
                }
                color: "#7b1fa2"
                Layout.leftMargin: 15
            }

            // Список статей
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.preferredHeight: contentHeight
                implicitHeight: contentHeight
                clip: true
                spacing: 15
                model: articleManager.articles

                delegate: Rectangle {
                    width: listView.width - 20
                    height: expanded ? contentColumn.height + 40 : titleRow.height + 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    radius: 12
                    color: "white"
                    border.color: modelData.isFavorite ? "#ffeb3b" : "#e1bee7"
                    border.width: 2

                    property bool expanded: false

                    Column {
                        id: contentColumn
                        width: parent.width
                        padding: 15
                        spacing: 10

                        // Заголовок
                        Row {
                            id: titleRow
                            width: parent.width
                            spacing: 15

                            Text {
                                text: modelData.icon || "📖"
                                font.pixelSize: 24
                            }

                            Column {
                                width: parent.width - 70
                                spacing: 5

                                Text {
                                    width: parent.width
                                    text: modelData.title
                                    font.bold: true
                                    font.pixelSize: 15
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: expanded ? 0 : 2
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.source
                                    font.pixelSize: 12
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: expanded ? 0 : 1
                                    elide: Text.ElideRight
                                }
                            }

                            Button {
                                icon.source: modelData.isFavorite ? "qrc:/Images/icons/favorite_filled.svg" : "qrc:/Images/icons/favorite_border.svg"
                                icon.color: modelData.isFavorite ? "#ffc107" : "#9e9e9e"
                                flat: true
                                onClicked: articleManager.toggleFavorite(
                                               modelData.id)
                            }
                        }

                        // Содержание
                        Text {
                            width: parent.width - 20
                            text: modelData.content
                            visible: expanded
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                        }

                        // Время чтения
                        Text {
                            visible: expanded && modelData.readTimeMinutes
                            text: "⏱ " + modelData.readTimeMinutes + " мин. чтения"
                            font.pixelSize: 12
                            color: "#666"
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

                    TapHandler {
                        onTapped: parent.expanded = !parent.expanded
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        articleManager.loadArticles()
    }
}
