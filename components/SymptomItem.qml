import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    width: parent.width
    spacing: 10

    property var symptom: ({})

    //signal symptomChanged(var symptom)
    ChecklistItem {
        checked: root.symptom.severity > 0
        onCheckedChanged: {
            var updated = root.symptom
            updated.severity = checked ? 1 : 0
            root.symptomChanged(updated)
        }
    }

    Label {
        text: root.symptom.name
        Layout.fillWidth: true
    }

    Slider {
        from: 1
        to: 5
        value: root.symptom.severity > 0 ? root.symptom.severity : 1
        stepSize: 1
        visible: root.symptom.severity > 0
        onMoved: {
            var updated = root.symptom
            updated.severity = value
            root.symptomChanged(updated)
        }
    }

    Label {
        text: root.symptom.severity > 0 ? root.symptom.severity + "/5" : ""
        visible: root.symptom.severity > 0
    }
}
