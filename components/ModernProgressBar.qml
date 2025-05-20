import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

ProgressBar {
    id: root

    // Публичные свойства для настройки
    property color startColor: "#9c27b0"
    property color endColor: "#e91e63"
    property color textColor: "white"
    property color bgColor: "#f0f0f0"
    property int weekNumber: 1
    property int totalWeeks: 40
    property bool showWeekIndicator: true
    property bool showPercentage: true

    value: weekNumber / totalWeeks
    padding: 2

    Behavior on value {
        NumberAnimation {
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    background: Rectangle {
        implicitHeight: 12
        radius: height / 2
        color: root.bgColor
        border {
            color: Qt.darker(root.bgColor, 1.1)
            width: 1
        }

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 2
            samples: 5
            color: "#20000000"
        }
    }

    contentItem: Item {
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: height / 2

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.lighter(root.startColor, 1.1)
                }
                GradientStop {
                    position: 1.0
                    color: root.endColor
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 1
                }
                height: parent.height / 3
                radius: height / 2
                color: "#60ffffff"
            }
        }

        Text {
            visible: root.showPercentage
            anchors {
                right: parent.right
                rightMargin: 5
                verticalCenter: parent.verticalCenter
            }
            text: Math.round(root.value * 100) + "%"
            color: root.value > 0.5 ? root.textColor : root.startColor
            font {
                pixelSize: 10
                bold: true
            }
        }
    }

    Label {
        visible: root.showWeekIndicator
        anchors {
            bottom: parent.top
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 3
        }
        text: "Неделя " + root.weekNumber
        color: root.startColor
        font {
            pixelSize: 12
            bold: true
        }
        background: Rectangle {
            color: root.bgColor
            radius: 4
            opacity: 0.9
        }
        padding: 3
    }
}
