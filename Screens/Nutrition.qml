import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "../components" as MyComponents

Page {
    id: root
    padding: 20

    property color textColor: "#4a148c"
    property color backgroundColor: "#faf4ff"
    property string currentFilter: "Все диеты"
    property string searchText: ""

    // Полная модель всех диет
    ListModel {
        id: allDietsModel
        ListElement {
            number: "1, 1а, 1б"
            title: "Язвенная болезнь"
            category: "Желудочно-кишечные"
            color: "#e1bee7"
            icon: "qrc:/Images/icons/stomach.svg"
        }
        ListElement {
            number: "2"
            title: "Гастрит с пониженной кислотностью"
            category: "Желудочно-кишечные"
            color: "#ce93d8"
            icon: "qrc:/Images/icons/intestine.svg"
        }
        ListElement {
            number: "3"
            title: "Запоры"
            category: "Желудочно-кишечные"
            color: "#ba68c8"
            icon: "qrc:/Images/icons/constipation.svg"
        }
        ListElement {
            number: "4, 4а, 4б, 4в"
            title: "Болезни кишечника с диареей"
            category: "Желудочно-кишечные"
            color: "#ab47bc"
            icon: "qrc:/Images/icons/diarrhea.svg"
        }
        ListElement {
            number: "5, 5а"
            title: "Заболевания печени и желчных путей"
            category: "Желудочно-кишечные"
            color: "#9c27b0"
            icon: "qrc:/Images/icons/liver.svg"
        }
        ListElement {
            number: "6"
            title: "Мочекаменная болезнь"
            category: "Мочеполовая система"
            color: "#8e24aa"
            icon: "qrc:/Images/icons/kidney.svg"
        }
        ListElement {
            number: "7, 7а, 7б, 7в, 7г"
            title: "Нефрит"
            category: "Мочеполовая система"
            color: "#7b1fa2"
            icon: "qrc:/Images/icons/kidneys.svg"
        }
        ListElement {
            number: "8"
            title: "Ожирение"
            category: "Обмен веществ"
            color: "#6a1b9a"
            icon: "qrc:/Images/icons/obesity.svg"
        }
        ListElement {
            number: "9"
            title: "Сахарный диабет"
            category: "Обмен веществ"
            color: "#5e35b1"
            icon: "qrc:/Images/icons/diabetes.svg"
        }
        ListElement {
            number: "10"
            title: "Сердечно-сосудистые заболевания"
            category: "Сердечно-сосудистые"
            color: "#4a148c"
            icon: "qrc:/Images/icons/heart.svg"
        }
    }

    // Фильтрованная модель для отображения
    ListModel {
        id: filteredDietsModel
    }

    // Функция фильтрации
    function filterDiets() {
        filteredDietsModel.clear()

        for (var i = 0; i < allDietsModel.count; i++) {
            var item = allDietsModel.get(i)
            var matchesFilter = currentFilter === "Все диеты"
                    || item.category === currentFilter
            var matchesSearch = searchText === "" || item.title.toLowerCase(
                        ).includes(searchText.toLowerCase())
                    || item.number.toLowerCase().includes(
                        searchText.toLowerCase())

            if (matchesFilter && matchesSearch) {
                filteredDietsModel.append(item)
            }
        }
    }

    // Применяем фильтры при изменении
    onCurrentFilterChanged: filterDiets()
    onSearchTextChanged: filterDiets()
    Component.onCompleted: filterDiets()

    background: Rectangle {
        color: backgroundColor
    }

    header: ToolBar {
        background: Rectangle {
            color: "#9c27b0"
            layer.enabled: true
            layer.effect: DropShadow {
                verticalOffset: 2
                radius: 8
                samples: 16
                color: "#40000000"
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 16
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            ToolButton {
                icon.source: "qrc:/Images/icons/arrow_back.svg"
                icon.color: "white"
                onClicked: stackView.pop()
            }

            Label {
                text: "Лечебные диеты по Певзнеру"
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

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.height + 40
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: 20

            // Поиск и фильтрация
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TextField {
                    id: searchField
                    placeholderText: "Поиск диет..."
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    background: Rectangle {
                        radius: 8
                        border.color: "#ce93d8"
                        border.width: 1
                    }
                    onTextChanged: {
                        root.searchText = text
                    }
                }

                Button {
                    text: root.currentFilter
                    font.family: "Roboto"
                    onClicked: filterMenu.open()

                    Menu {
                        id: filterMenu
                        MenuItem {
                            text: "Все диеты"
                            onTriggered: root.currentFilter = text
                        }
                        MenuItem {
                            text: "Желудочно-кишечные"
                            onTriggered: root.currentFilter = text
                        }
                        MenuItem {
                            text: "Сердечно-сосудистые"
                            onTriggered: root.currentFilter = text
                        }
                        MenuItem {
                            text: "Мочеполовая система"
                            onTriggered: root.currentFilter = text
                        }
                        MenuItem {
                            text: "Обмен веществ"
                            onTriggered: root.currentFilter = text
                        }
                    }
                }
            }

            // Список диет
            Repeater {
                model: filteredDietsModel
                delegate: MyComponents.DietCard {
                    width: contentColumn.width
                    dietNumber: number
                    title: "Стол №" + number
                    subtitle: title
                    icon: model.icon
                    cardColor: model.color
                    onClicked: {
                        var detailsData = getDietDetails(number)
                        var detailsPage = dietDetails.createObject(stackView, {
                                                                       "model": detailsData,
                                                                       "dietNumber": number,
                                                                       "dietColor": color
                                                                   })
                        stackView.push(detailsPage)
                    }
                }
            }
        }
    }

    Component {
        id: dietDetails

        Page {
            property var model
            property string dietNumber
            property color dietColor

            header: ToolBar {
                background: Rectangle {
                    color: "#9c27b0"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    ToolButton {
                        icon.source: "qrc:/Images/icons/arrow_back.svg"
                        icon.color: "white"
                        onClicked: stackView.pop()
                    }

                    Label {
                        text: "Стол №" + dietNumber
                        font {
                            family: "Comfortaa"
                            pixelSize: 20
                            bold: true
                        }
                        color: "white"
                        Layout.fillWidth: true
                    }
                }
            }

            Flickable {
                anchors.fill: parent
                contentHeight: detailsColumn.height
                clip: true

                ColumnLayout {
                    id: detailsColumn
                    width: parent.width - 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 20

                    MyComponents.SectionHeader {
                        text: "Стол №" + model.number
                        color: dietColor
                    }

                    MyComponents.InfoCard {
                        title: "Показания:"
                        content: model.indications
                    }

                    MyComponents.InfoCard {
                        title: "Режим питания:"
                        content: model.dietSchedule
                    }

                    MyComponents.FoodTable {
                        recommended: model.recommendedFoods
                        excluded: model.excludedFoods
                    }

                    MyComponents.InfoCard {
                        title: "Особенности питания:"
                        content: model.notes
                    }
                }
            }
        }
    }
    function getDietDetails(dietNumber) {
        // Возвращает модель с данными для конкретной диеты
        var details = {
            "1, 1а, 1б": {
                "number": "1, 1а, 1б",
                "color": "#e1bee7",
                "indications": "язвенная болезнь желудка и двенадцатиперстной кишки...",
                "dietSchedule": "4-5 раз в день\nСрок: не менее 2-3 месяцев",
                "recommendedFoods": [{
                        "category": "Хлеб",
                        "items": ["Хлеб белый пшеничный, вчерашний", "Сухое несдобное печенье"]
                    }, {
                        "category": "Первые блюда",
                        "items": ["Супы из протертых круп", "Молочные супы"]
                    }],
                "excludedFoods": [{
                        "category": "Хлеб",
                        "items": ["Черный хлеб", "Сдобные изделия"]
                    }, {
                        "category": "Первые блюда",
                        "items": ["Мясные и рыбные бульоны"]
                    }],
                "notes": "Пищу подают в полужидком или желеобразном виде теплыми..."
            }
            // Добавьте данные для других диет
        }

        return details[dietNumber]
    }
}
