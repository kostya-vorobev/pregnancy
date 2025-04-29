import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    height: parent.height
    width: parent.width
    Rectangle {
        anchors.fill: parent
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

        Column {
            anchors.centerIn: parent
            spacing: 40
            width: parent.width * 0.8

            // Логотип с эффектами
            Item {
                width: 140
                height: 140
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: logo
                    source: "qrc:/Images/logo.png"
                    width: 120
                    height: 120
                    anchors.centerIn: parent
                    opacity: 0
                    scale: 0.5

                    MultiEffect {
                        anchors.fill: parent
                        source: logo
                        colorization: 0.7
                        colorizationColor: primaryColor
                        shadowEnabled: true
                        shadowColor: "#80000000"
                        shadowVerticalOffset: 4
                        shadowBlur: 0.5
                    }
                }

                PropertyAnimation {
                    target: logo
                    property: "opacity"
                    to: 1
                    duration: 800
                    running: true
                }
                PropertyAnimation {
                    target: logo
                    property: "scale"
                    to: 1
                    duration: 600
                    running: true
                }
            }

            // Текст с тенью
            Item {
                width: parent.width
                height: 40

                Text {
                    id: titleText
                    text: "Дневник беременности"
                    font {
                        family: "Comfortaa"
                        pixelSize: 26
                        weight: Font.Bold
                    }
                    color: textColor
                    anchors.centerIn: parent
                    opacity: 0
                    y: 20
                }

                MultiEffect {
                    anchors.fill: titleText
                    source: titleText
                    shadowEnabled: true
                    shadowColor: "#40000000"
                    shadowVerticalOffset: 2
                    shadowBlur: 0.3
                }

                PropertyAnimation {
                    target: titleText
                    property: "opacity"
                    to: 1
                    duration: 600
                    running: true
                }
                PropertyAnimation {
                    target: titleText
                    property: "y"
                    to: 0
                    duration: 500
                    running: true
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        onTriggered: stackView.replace("qrc:/Screens/MainScreen.qml")
    }
}
