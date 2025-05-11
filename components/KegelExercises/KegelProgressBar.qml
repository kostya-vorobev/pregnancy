import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    property int currentDay: 1
    property int totalDays: 30

    width: parent.width
    height: 30
    radius: 15
    color: "#e0e0e0"

    Rectangle {
        width: parent.width * (currentDay / totalDays)
        height: parent.height
        radius: 15
        color: "#9c27b0"
    }

    Text {
        text: "День " + currentDay + " из " + totalDays
        anchors.centerIn: parent
        color: "white"
        font.bold: true
    }
}
