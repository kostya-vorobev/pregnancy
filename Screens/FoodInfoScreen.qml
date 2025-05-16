import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../components" as MyComponents

Page {
    id: root
    anchors.fill: parent

    //width: parent.width
    //height: contentColumn.implicitHeight + 40
    //radius: 12
    //color: "#FFFFFF"
    //border.color: "#EEEEEE"
    //border.width: 1
    property var foodData: [{
            "name": "Яблоки",
            "aliases": ["Яблоко"],
            "imageSource": "qrc:/Images/food/apple.svg",
            "type": "Фрукты",
            "categories": [{
                    "name": "Беременность",
                    "status": "Умеренно"
                }, {
                    "name": "Грудное вскармливание",
                    "status": "Умеренно"
                }, {
                    "name": "После родов",
                    "status": "Осторожно"
                }, {
                    "name": "Младенцы",
                    "status": "Нельзя"
                }]
        }, {
            "name": "Молоко",
            "aliases": ["Коровье молоко"],
            "imageSource": "qrc:/Images/food/milk.svg",
            "type": "Молочные продукты",
            "categories": [{
                    "name": "Беременность",
                    "status": "Умеренно"
                }, {
                    "name": "Грудное вскармливание",
                    "status": "Умеренно"
                }, {
                    "name": "После родов",
                    "status": "Осторожно"
                }, {
                    "name": "Младенцы",
                    "status": "Нельзя"
                }]
        }, {
            "name": "Морковь",
            "aliases": [],
            "imageSource": "qrc:/Images/food/carrot.svg",
            "type": "Овощи",
            "categories": [{
                    "name": "Беременность",
                    "status": "Умеренно"
                }, {
                    "name": "Грудное вскармливание",
                    "status": "Умеренно"
                }, {
                    "name": "После родов",
                    "status": "Осторожно"
                }, {
                    "name": "Младенцы",
                    "status": "Нельзя"
                }]
        }]

    // Текущий выбранный тип продукта для фильтрации
    property string selectedType: "Все"

    // Получаем уникальные типы продуктов для фильтров
    function getProductTypes() {
        var types = ["Все"]
        for (var i = 0; i < foodData.length; i++) {
            if (foodData[i].type && types.indexOf(foodData[i].type) === -1) {
                types.push(foodData[i].type)
            }
        }
        return types
    }

    // Фильтрованный список продуктов
    property var filteredFoodData: {
        if (selectedType === "Все") {
            return foodData
        } else {
            return foodData.filter(function (food) {
                return food.type === selectedType
            })
        }
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
                text: "Каталог продуктов"
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
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Фильтры по типам продуктов
        MyComponents.CategoryFilters {
            id: typeFilters
            Layout.fillWidth: true
            types: getProductTypes()
            selectedType: root.selectedType
            onTypeSelected: {
                root.selectedType = type
            }
        }

        // Список продуктов
        // Исправленный Flickable для списка продуктов
        Flickable {
            id: flickable
            width: parent.width
            height: parent.height + 20
            contentWidth: contentRow.width
            contentHeight: parent.height
            clip: true

            Column {
                id: productsColumn
                width: flickable.width
                spacing: 10

                Repeater {
                    model: root.filteredFoodData
                    delegate: MyComponents.FoodCard {
                        width: productsColumn.width
                        // Убедитесь, что у FoodCard есть явная высота
                        foodName: modelData.name
                        foodAliases: modelData.aliases
                        foodCategories: modelData.categories
                        imageSource: modelData.imageSource
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 8
            }
        }
    }
}
