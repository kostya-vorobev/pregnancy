import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts

GroupBox {
    property int day: 1
    property var exercises: []

    title: "Программа на день " + day
    background: Rectangle {
        color: "white"
        radius: 10
    }

    ColumnLayout {
        width: parent.width
        spacing: 5

        Repeater {
            model: exercises

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10

                CheckBox {
                    checked: modelData.completed
                    onCheckedChanged: modelData.completed = checked
                }

                Text {
                    text: "Подходов: " + modelData.sets + ", Сжатие: " + modelData.holdTime
                          + "сек" + ", Отдых: " + modelData.restTime + "сек"
                    Layout.fillWidth: true
                }
            }
        }
    }
}
