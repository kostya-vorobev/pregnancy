// components/WeightDataTable.qml
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    property var weightData: []
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#f3e5f5"

    radius: 15
    color: "#ffffff"
    implicitHeight: Math.min(200, Math.max(100, weightData.length * 50))

    ListView {
        id: dataTable
        anchors.fill: parent
        anchors.margins: 10
        clip: true
        model: root.weightData
        spacing: 5

        header: Row {
            width: parent.width
            spacing: 20
            topPadding: 10
            bottomPadding: 10

            Text {
                width: parent.width * 0.6
                text: "Дата"
                font {
                    family: "Comfortaa"
                    pixelSize: 16
                    bold: true
                }
                color: Qt.darker(root.primaryColor, 1.2)
            }

            Text {
                width: parent.width * 0.4 - 20
                text: "Вес (кг)"
                font {
                    family: "Comfortaa"
                    pixelSize: 16
                    bold: true
                }
                color: Qt.darker(root.primaryColor, 1.2)
            }
        }

        delegate: Rectangle {
            width: parent.width
            height: 40
            radius: 8
            color: index % 2 === 0 ? root.secondaryColor : "#ffffff"

            Row {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20
                leftPadding: 10
                rightPadding: 10

                Text {
                    width: parent.width * 0.6
                    text: modelData.date.toLocaleDateString(Qt.locale("ru_RU"),
                                                            "dd.MM.yyyy")
                    font {
                        family: "Comfortaa"
                        pixelSize: 14
                    }
                    color: Qt.darker(root.primaryColor, 1.2)
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width * 0.4 - 20
                    text: modelData.weight.toFixed(1) + " кг"
                    font {
                        family: "Comfortaa"
                        pixelSize: 14
                        bold: true
                    }
                    color: root.primaryColor
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
