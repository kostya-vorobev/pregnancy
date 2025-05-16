import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

import "../components" as MyComponents

Rectangle {
    id: root
    property string foodName
    property var foodAliases
    property var foodCategories
    property url imageSource
    property int verticalPadding: 12
    property int horizontalPadding: 12
    property int textSpacing: 8
    property int categorySpacing: 10
    property int imageSize: 80

    width: ListView.view ? ListView.view.width : parent.width
    height: contentRow.height + 2 * verticalPadding
    radius: 8
    color: "#FFFFFF"
    border.color: "#EEEEEE"
    border.width: 1

    Row {
        id: contentRow
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: horizontalPadding
            topMargin: verticalPadding
            bottomMargin: verticalPadding
        }
        height: Math.max(foodImage.height + 30, infoColumn.height + 30)
        spacing: 15

        // Изображение продукта
        Image {
            id: foodImage
            width: imageSize
            height: imageSize
            source: imageSource
            fillMode: Image.PreserveAspectFit
            mipmap: true
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: foodImage.width
                    height: foodImage.height
                    radius: 8
                }
            }
        }

        // Текстовая информация
        Column {
            id: infoColumn
            width: parent.width - foodImage.width - parent.spacing
            spacing: textSpacing
            height: categoriesFlow.height + nameText.height + aliasesText.height
            // Название и синонимы
            Column {
                width: parent.width
                spacing: 4

                Text {
                    id: nameText
                    width: parent.width
                    text: foodName
                    font {
                        family: "Microsoft YaHei"
                        pixelSize: 18
                        bold: true
                    }
                    color: "#333333"
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }

                Text {
                    id: aliasesText
                    width: parent.width
                    text: foodAliases.join(", ")
                    font.pixelSize: 14
                    color: "#666666"
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    visible: text !== ""
                }
            }

            // Категории
            Flow {
                id: categoriesFlow
                width: parent.width
                spacing: categorySpacing

                Repeater {
                    model: foodCategories
                    delegate: MyComponents.StatusBadge {
                        category: modelData.name
                        status: modelData.status
                    }
                }
            }
        }
    }
}
