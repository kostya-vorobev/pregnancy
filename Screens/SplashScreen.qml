import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "#f8e9ff"
        }
        GradientStop {
            position: 1.0
            color: "#ffd6e8"
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 40

        Text {
            text: qsTr("Мамино счастье")
            font {
                family: "Comfortaa"
                pixelSize: 28
                weight: Font.Bold
            }
            color: "#6a1b9a"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: 15
            width: 200

            Button {
                text: "Я беременна"
                width: parent.width
                height: 50
                font.pixelSize: 16
                onClicked: stackView.push("qrc:/Screens/PregnantScreen.qml")
            }

            Button {
                text: "Планирую беременность"
                width: parent.width
                height: 50
                font.pixelSize: 16
                onClicked: stackView.push("qrc:/Screens/PlanningScreen.qml")
            }
        }
    }
}
