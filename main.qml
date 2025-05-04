import QtQuick
import QtQuick.Controls
import QtQuick.Effects

// Импорт компонентов
ApplicationWindow {
    id: mainWindow

    width: Math.min(Screen.width * 0.9, 400)
    height: Math.min(Screen.height * 0.9, 800)
    visible: true
    title: "Дневник беременности"

    // Свойство для управления видимостью футера
    property bool showFooter: false
    // Цветовая палитра
    property color primaryColor: "#9c27b0"
    property color secondaryColor: "#f3e5f5"
    property color accentColor: "#e91e63"
    property color textColor: "#4a148c"
    property real defaultRadius: 14
    property real shadowSize: 6
    signal showFooterRequested(bool show)
    function setFooterVisible(visible) {
        showFooter = visible
    }
    Item {
        id: safeItemTop
        anchors.top: parent.top
        height: 20
    }

    StackView {

        id: stackView
        initialItem: "qrc:/Screens/WelcomeScreen.qml"
        anchors {
            top: safeItemTop.bottom
            left: parent.left
            right: parent.right
            bottom: showFooter ? footer.top : parent.bottom
        }
    }

    // Подключаем нижнюю панель через прямой путь
    Loader {
        id: footer
        anchors.bottom: safeItemBottom.top
        visible: showFooter
        width: parent.width
        source: "qrc:/components/Footer.qml"
    }

    Item {
        id: safeItemBottom
        anchors.bottom: parent.bottom
        height: 20
    }
}
