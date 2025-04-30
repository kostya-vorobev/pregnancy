import QtQuick
import QtQuick.Controls

Item {
    property alias title: titleField.text
    property alias content: contentArea.text

    Column {
        anchors.fill: parent
        spacing: 10

        TextField {
            id: titleField
            width: parent.width
            placeholderText: "Заголовок"
        }

        TextArea {
            id: contentArea
            width: parent.width
            height: 200
            placeholderText: "Текст заметки..."
        }
    }
}
