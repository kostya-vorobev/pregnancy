import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
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

    ScrollView {
        anchors.fill: parent
        padding: 15

        ColumnLayout {
            width: parent.width
            spacing: 15

            Text {
                text: "Статьи и материалы"
                font {
                    family: "Comfortaa"
                    pixelSize: 22
                    bold: true
                }
                color: "#9c27b0"
                Layout.alignment: Qt.AlignHCenter
            }

            Repeater {
                model: [{
                        "title": "Питание во время беременности",
                        "source": "Журнал 'Мама и малыш'"
                    }, {
                        "title": "Подготовка к родам",
                        "source": "Книга 'Осознанные роды'"
                    }, {
                        "title": "Развитие плода по неделям",
                        "source": "Сайт baby.ru"
                    }, {
                        "title": "Йога для беременных",
                        "source": "Видеокурс"
                    }, {
                        "title": "Что взять в роддом",
                        "source": "Список от гинеколога"
                    }]

                delegate: Rectangle {
                    color: "white"
                    radius: 10
                    Layout.fillWidth: true
                    height: 80

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        Text {
                            text: modelData.title
                            font {
                                bold: true
                                pixelSize: 16
                            }
                            color: "#9c27b0"
                        }

                        Text {
                            text: modelData.source
                            font {
                                italic: true
                                pixelSize: 12
                            }
                            color: "#666"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(
                                       "https://example.com/articles/" + index)
                    }
                }
            }
        }
    }
}
