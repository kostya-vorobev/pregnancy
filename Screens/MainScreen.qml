import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../components" as MyComponents

Item {
    id: mainWindow
    height: parent.height
    width: parent.width
    visible: true

    // Цветовая палитра
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#f3e5f5"
    property color textColor: "#4a148c"
    property real defaultRadius: 14
    property real shadowSize: 6

    // Главный контейнер
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainScreen
    }

    // Главный экран
    Component {
        id: mainScreen
        Rectangle {
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: secondaryColor
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

                Text {
                    text: "Выберите ваш статус"
                    font {
                        family: "Comfortaa"
                        pixelSize: 22
                        weight: Font.Bold
                    }
                    color: textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Column {
                    spacing: 20
                    width: parent.width

                    // Кнопка "Я беременна"
                    MyComponents.CustomButton {
                        width: parent.width
                        height: 80
                        text: "Я беременна"
                        onClicked: stackView.push(
                                       "qrc:/Screens/PregnantScreen.qml")
                    }

                    // Кнопка "Планирую беременность"
                    MyComponents.CustomButton {
                        width: parent.width
                        height: 80
                        text: "Планирую беременность"
                        onClicked: stackView.push(
                                       "qrc:/Screens/PlanningScreen.qml")
                    }
                }
            }
        }
    }
}
