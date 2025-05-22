import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: root
    spacing: 10

    property var symptomsModel: []
    signal symptomsChanged(var symptoms)

    Label {
        text: "Симптомы"
        font.pixelSize: 16
        color: "#4a148c"
    }

    Repeater {
        model: root.symptomsModel

        delegate: SymptomItem {
            symptom: modelData
            onSymptomChanged: {
                var updated = root.symptomsModel
                updated[index] = symptom
                root.symptomsChanged(updated)
            }
        }
    }

    Button {
        text: "+ Добавить симптом"
        flat: true
        font.bold: true
        onClicked: symptomDialog.open()
    }

    SymptomDialog {
        id: symptomDialog
        onAccepted: {
            var updated = root.symptomsModel
            updated.push({
                             "name": symptomName,
                             "severity": severity,
                             "notes": ""
                         })
            root.symptomsChanged(updated)
        }
    }
}
