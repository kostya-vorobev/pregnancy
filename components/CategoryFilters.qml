import QtQuick
import QtQuick.Controls
import "../components" as MyComponents

Row {
    id: root
    property var types: []
    property string selectedType: "Все"
    signal typeSelected(string type)
    height: 50
    spacing: 10

    Flickable {
        width: parent.width
        height: parent.height
        contentWidth: contentRow.width
        contentHeight: parent.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: contentRow
            spacing: root.spacing
            height: parent.height

            Repeater {
                model: root.types
                delegate: MyComponents.CategoryButton {
                    text: modelData
                    selected: modelData === root.selectedType
                    onClicked: {
                        root.selectedType = modelData
                        root.typeSelected(modelData)
                    }
                }
            }
        }
    }
}
