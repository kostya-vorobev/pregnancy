// components/DietCard.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    id: root
    property string dietNumber: ""
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property color cardColor: "#9c27b0"
    signal clicked

    width: parent ? parent.width : 400
    height: 100
    radius: 12
    color: "white"
    border.color: Qt.darker(cardColor, 1.1)
    border.width: 1

    // Эффект при наведении
    states: [
        State {
            name: "hovered"
            when: mouseArea.containsMouse
            PropertyChanges {
                target: root
                scale: 1.02
                border.color: Qt.darker(cardColor, 1.3)
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            properties: "scale"
            duration: 150
        }
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowVerticalOffset: 2
        shadowBlur: 8
        shadowScale: 1.02
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 15

        // Номер диеты в кружке
        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            radius: width / 2
            color: cardColor

            Text {
                text: dietNumber
                anchors.centerIn: parent
                font {
                    pixelSize: 20
                    bold: true
                    family: "Comfortaa"
                }
                color: "white"
            }

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 4
                samples: 8
                color: "#60000000"
                verticalOffset: 1
            }
        }

        // Текстовое содержимое
        ColumnLayout {
            spacing: 6
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            // Заголовок
            Text {
                text: title
                font {
                    pixelSize: 16
                    bold: true
                    family: "Roboto"
                }
                color: "#4a148c"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Подзаголовок
            Text {
                text: subtitle
                font {
                    pixelSize: 14
                    family: "Roboto"
                }
                color: "#666"
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Иконка со стрелкой
        RowLayout {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            // Тематическая иконка
            Image {
                source: icon
                sourceSize.width: 28
                sourceSize.height: 28
                opacity: 0.8
            }

            // Стрелка перехода
            Image {
                source: "qrc:/Images/icons/arrow_right.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                opacity: 0.6
            }
        }
    }

    // Область клика
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
