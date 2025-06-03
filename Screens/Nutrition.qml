import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root
    anchors.fill: parent

    // Менеджер диет (C++ класс)
    DietManager {
        id: dietManager
        onDietsChanged: updateFilteredDiets()
        onCategoriesChanged: updateCategories()
    }

    property string selectedCategory: "Все диеты"
    property var filteredDiets: []
    property var categories: ["Все диеты"]

    function updateCategories() {
        var newCategories = ["Все диеты"]
        for (var i = 0; i < dietManager.categories.length; i++) {
            if (dietManager.categories[i].name !== "Все диеты") {
                newCategories.push(dietManager.categories[i].name)
            }
        }
        root.categories = newCategories
    }

    function updateFilteredDiets() {
        if (selectedCategory === "Все диеты") {
            root.filteredDiets = dietManager.diets
        } else {
            var filtered = []
            for (var i = 0; i < dietManager.diets.length; i++) {
                if (dietManager.diets[i].categoryName === selectedCategory) {
                    filtered.push(dietManager.diets[i])
                }
            }
            root.filteredDiets = filtered
        }
    }

    Component.onCompleted: {
        dietManager.loadData()
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Фильтр по категориям
        MyComponents.CategoryFilters {
            id: categoryFilters
            Layout.fillWidth: true
            types: root.categories
            selectedType: root.selectedCategory
            onTypeSelected: {
                root.selectedCategory = type
                dietManager.filterByCategory(type)
            }
        }

        // Поле поиска
        MyComponents.CustomTextField {
            id: searchField
            Layout.fillWidth: true
            placeholderTextValue: "Поиск диет..."
            onTextChanged: {
                var searchText = text.toLowerCase()
                if (searchText === "") {
                    updateFilteredDiets()
                } else {
                    var filtered = []
                    for (var i = 0; i < root.filteredDiets.length; i++) {
                        var diet = root.filteredDiets[i]
                        if (diet.title.toLowerCase().includes(searchText)
                                || diet.number.toLowerCase().includes(
                                    searchText)) {
                            filtered.push(diet)
                        }
                    }
                    root.filteredDiets = filtered
                }
            }
        }

        // Список диет
        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: dietsColumn.height
            clip: true

            Column {
                id: dietsColumn
                width: parent.width
                spacing: 10

                Repeater {
                    model: root.filteredDiets
                    delegate: MyComponents.DietCard {
                        width: dietsColumn.width
                        dietNumber: modelData.number
                        title: "Стол №" + modelData.number
                        subtitle: modelData.title
                        icon: modelData.icon
                        cardColor: modelData.color
                        onClicked: {
                            var details = dietManager.getDietDetails(
                                        modelData.number)
                            var page = dietDetails.createObject(stackView, {
                                                                    "model": details,
                                                                    "dietNumber": modelData.number,
                                                                    "dietColor": modelData.color
                                                                })
                            stackView.push(page)
                        }
                    }
                }
            }
        }
    }

    // Компонент деталей диеты
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
                        anchors.bottomMargin: 10
                        text: "Стол №" + model.number + " (" + model.title + ")"
                        color: dietColor
                    }

                    MyComponents.InfoCard {
                        title: "Показания:"
                        content: model.indications
                        Layout.fillWidth: true
                    }

                    MyComponents.InfoCard {
                        title: "Режим питания:"
                        content: model.dietSchedule
                        Layout.fillWidth: true
                    }

                    MyComponents.FoodTable {
                        recommended: model.recommendedFoods
                        excluded: model.excludedFoods
                        Layout.fillWidth: true
                    }

                    MyComponents.InfoCard {
                        title: "Особенности питания:"
                        content: model.notes
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
