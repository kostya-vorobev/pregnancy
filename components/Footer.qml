import QtQuick
import QtQuick.Controls
import "../components" as MyComponents

Rectangle {
    id: footer
    height: 60
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
            onClicked: {
                stackView.clear()
                stackView.push("qrc:/Screens/HomeScreen.qml")
            }
        }

        // Кнопка "Календарь"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/calendar.svg"
            onClicked: {
                stackView.clear()
                stackView.push("qrc:/Screens/CalendarScreen.qml")
            }
        }

        // Кнопка "Анализы"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/analize.svg"
            onClicked: {
                stackView.clear()
                stackView.push("qrc:/Screens/AnalizeScreen.qml")
            }
        }

        // Кнопка "Анализы"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/menu.svg"
            onClicked: {
                stackView.clear()
                stackView.push("qrc:/Screens/MenuScreen.qml")
            }
        }

        // Кнопка "Профиль"
        MyComponents.FooterButton {
            iconSource: "qrc:/Images/svg/profile.svg"
            onClicked: {
                stackView.push("qrc:/Screens/ProfileScreen.qml")
            }
        }
    }
}
