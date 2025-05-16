import QtQuick
import QtQuick.Layouts

Rectangle {
    property var recommended
    property var excluded

    width: parent.width
    height: Math.max(recommendedCol.height, excludedCol.height) + 40
    radius: 8
    color: "#ffffff"
    border.color: "#e1bee7"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15

        // Рекомендованные продукты
        ColumnLayout {
            id: recommendedCol
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Рекомендовано:"
                font {
                    family: "Roboto"
                    pixelSize: 14
                    bold: true
                }
                color: "#4caf50"
                wrapMode: Text.Wrap
            }

            Repeater {
                model: recommended
                delegate: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        text: modelData.category + ":"
                        font {
                            family: "Roboto"
                            pixelSize: 13
                            bold: true
                        }
                        color: "#7b1fa2"
                        wrapMode: Text.Wrap
                    }

                    Repeater {

                        model: modelData.items
                        delegate: Text {
                            Layout.fillWidth: true
                            text: "• " + modelData
                            font.pixelSize: 12
                            color: "#666"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        // Исключенные продукты
        ColumnLayout {
            id: excludedCol
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Исключить:"
                font {
                    family: "Roboto"
                    pixelSize: 14
                    bold: true
                }
                color: "#f44336"
                wrapMode: Text.Wrap
            }

            Repeater {
                model: excluded
                delegate: ColumnLayout {
                    Text {
                        Layout.fillWidth: true
                        text: modelData.category + ":"
                        font {
                            family: "Roboto"
                            pixelSize: 13
                            bold: true
                        }
                        color: "#7b1fa2"
                        wrapMode: Text.Wrap
                    }

                    Repeater {
                        model: modelData.items
                        delegate: Text {
                            Layout.fillWidth: true
                            text: "• " + modelData
                            font.pixelSize: 12
                            color: "#666"
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }
    }
}
