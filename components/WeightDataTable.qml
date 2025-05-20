import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Rectangle {
    id: root
    property var weightData: []
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#f3e5f5"

    // Сигнал для удаления с передачей ID записи
    signal deleteRequested(var measurementData)

    radius: 15
    color: "#ffffff"
    implicitHeight: Math.min(400, Math.max(100, weightData.length * 50 + 40))
    width: parent ? parent.width : 300

    ListView {
        id: dataTable
        anchors.fill: parent
        anchors.margins: 10
        clip: true
        model: root.weightData
        spacing: 5
        boundsBehavior: Flickable.StopAtBounds

        header: Row {
            width: dataTable.width - 20
            spacing: 10
            topPadding: 10
            bottomPadding: 10

            Text {
                width: parent.width * 0.4
                text: "Дата"
                font.pixelSize: 16
                font.bold: true
                color: Qt.darker(root.primaryColor, 1.2)
            }

            Text {
                width: parent.width * 0.3
                text: "Вес (кг)"
                font.pixelSize: 16
                font.bold: true
                color: Qt.darker(root.primaryColor, 1.2)
            }

            // Пустой элемент для выравнивания
            Item {
                width: parent.width * 0.3
                height: 1
            }
        }

        delegate: Rectangle {
            id: delegateItem
            width: dataTable.width - 20
            height: 40
            radius: 8
            color: index % 2 === 0 ? root.secondaryColor : "#ffffff"

            Row {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                leftPadding: 10
                rightPadding: 10

                Text {
                    width: parent.width * 0.4
                    text: Qt.formatDate(modelData.date, "dd.MM.yyyy")
                    font.pixelSize: 14
                    color: Qt.darker(root.primaryColor, 1.2)
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width * 0.3
                    text: modelData.weight.toFixed(1) + " кг"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.primaryColor
                }

                Button {
                    width: parent.width * 0.3 - 20
                    height: 30
                    text: "Удалить"
                    font.pixelSize: 12
                    Material.foreground: "#e53935"
                    Material.background: "transparent"
                    onClicked: root.deleteRequested(modelData)
                }
            }
        }
    }

    DropShadow {
        anchors.fill: parent
        source: parent
        radius: 8
        samples: 16
        color: "#20000000"
        verticalOffset: 2
    }
}
