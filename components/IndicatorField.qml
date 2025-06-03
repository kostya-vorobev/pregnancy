import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: root
    spacing: 5
    Layout.fillWidth: true

    property string label: ""
    property string value: ""
    property string placeholder: ""
    property var validator: null

    //signal valueChanged(string value)
    Label {
        text: root.label
        font.pixelSize: 14
        color: "#666"
    }

    CustomTextField {
        id: field
        width: parent.width
        text: root.value
        placeholderTextValue: root.placeholder
        font.pixelSize: 16
        validator: root.validator
        onTextChanged: root.valueChanged(text)

        background: Rectangle {
            radius: 5
            border.color: field.activeFocus ? "#9c27b0" : "#e0e0e0"
            border.width: 1
        }
    }
}
