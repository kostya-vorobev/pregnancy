import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../components" as MyComponents
import PregnancyApp 1.0

Page {
    id: root
    anchors.fill: parent

    // Менеджер продуктов (C++ класс)
    ProductManager {
        id: productManager
        onProductsChanged: updateFilteredProducts()
        onProductTypesChanged: updateTypes()
    }

    property string selectedType: "Все"
    property var filteredFoodData: []
    property var types: ["Все"]

    function updateTypes() {
        var newTypes = ["Все"]
        for (var i = 0; i < productManager.productTypes.length; i++) {
            newTypes.push(productManager.productTypes[i].name)
        }
        root.types = newTypes
    }

    function updateFilteredProducts() {
        if (selectedType === "Все") {
            root.filteredFoodData = productManager.products
        } else {
            var filtered = []
            for (var i = 0; i < productManager.products.length; i++) {
                if (productManager.products[i].typeName === selectedType) {
                    filtered.push(productManager.products[i])
                }
            }
            root.filteredFoodData = filtered
        }
    }

    function getCategoriesForProduct(product) {
        var categories = []
        if (product.recommendations) {
            for (var i = 0; i < product.recommendations.length; i++) {
                categories.push({
                                    "name": product.recommendations[i].category,
                                    "status": product.recommendations[i].status
                                })
            }
        }
        return categories
    }

    Component.onCompleted: {
        productManager.loadProducts()
    }

    // Остальной интерфейс остается аналогичным, но с небольшими изменениями:
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        MyComponents.CategoryFilters {
            id: typeFilters
            Layout.fillWidth: true
            types: root.types
            selectedType: root.selectedType
            onTypeSelected: {
                root.selectedType = type
                if (type === "Все") {
                    productManager.filterByType(-1)
                } else {
                    // Найти ID выбранного типа
                    for (var i = 0; i < productManager.productTypes.length; i++) {
                        if (productManager.productTypes[i].name === type) {
                            productManager.filterByType(
                                        productManager.productTypes[i].id)
                            break
                        }
                    }
                }
            }
        }

        Flickable {
            id: flickable
            width: parent.width
            height: parent.height - typeFilters.height - 20
            contentWidth: contentRow.width
            contentHeight: productsColumn.height
            clip: true

            Column {
                id: productsColumn
                width: flickable.width
                spacing: 10

                Repeater {
                    model: root.filteredFoodData
                    delegate: MyComponents.FoodCard {
                        width: productsColumn.width
                        foodName: modelData.name
                        foodAliases: [] // Можно добавить aliases в базу данных
                        foodCategories: getCategoriesForProduct(modelData)
                        imageSource: modelData.imageSource
                    }
                }
            }
        }
    }
}
