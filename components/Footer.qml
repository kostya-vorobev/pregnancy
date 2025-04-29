import QtQuick
import QtQuick.Controls
import "../components" as MyComponents

Rectangle {
    id: footer
    height: 40
    width: parent.width
    color: "#ffffff"
    border.color: "#dddddd"
    border.width: 1

    Row {
        anchors.fill: parent
        spacing: 0

        // Кнопка "Главная"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/home.svg"
            onClicked: mainWindow.showMainScreen()
        }

        // Кнопка "Данные"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/calendar.svg"
            onClicked: stackView.push("qrc:/Screens/PersonalDataScreen.qml")
        }

        // Кнопка "Беременность"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/analize.svg"
            onClicked: stackView.push("qrc:/Screens/PregnantScreen.qml")
        }

        // Кнопка "Календарь"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/profile.svg"
            onClicked: stackView.push("qrc:/Screens/CalendarScreen.qml")
        }
    }
}
