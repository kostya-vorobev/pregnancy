import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 200
    height: 40

    property date selectedDate: new Date()
    property string placeholderText: "Выберите дату"

    signal dateSelected(date selectedDate)

    Rectangle {
        anchors.fill: parent
        radius: 5
        border.color: "#cccccc"

        Text {
            anchors.centerIn: parent
            text: root.selectedDate.toLocaleDateString(Qt.locale(),
                                                       "dd.MM.yyyy")
                  || root.placeholderText
        }

        MouseArea {
            anchors.fill: parent
            onClicked: dateDialog.open()
        }
    }

    Dialog {
        id: dateDialog
        width: 300
        height: 400
        modal: true

        DatePickerDialogContent {
            selectedDate: root.selectedDate
            onDateAccepted: {
                root.selectedDate = date
                root.dateSelected(date)
                dateDialog.close()
            }
        }
    }
}
