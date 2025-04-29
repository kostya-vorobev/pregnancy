import QtQuick
import QtQuick.Controls
import QtQuick.Effects

ApplicationWindow {
    id: mainWindow
    width: Math.min(Screen.width * 0.9)
    height: Math.min(Screen.height * 0.9)
    visible: true
    title: "Дневник беременности"

    // Цветовая палитра
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#f3e5f5"
    property color accentColor: "#e91e63"
    property color textColor: "#4a148c"
    property real defaultRadius: 14
    property real shadowSize: 6

    StackView {
        id: stackView
        initialItem: "qrc:/Screens/WelcomeScreen.qml"
        anchors.fill: parent
    }
}
