import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: root
    width: parent.width
    spacing: 15

    property string weightValue: ""
    property string pressureValue: ""
    property string waistValue: ""

    signal weightChanged(string weight)
    signal pressureChanged(string pressure)
    signal waistChanged(string waist)

    GridLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        columns: 1
        columnSpacing: 20
        rowSpacing: 15

        // Вес
        IndicatorField {
            label: "Вес"
            value: root.weightValue
            placeholder: "Введите вес (кг)"
            validator: DoubleValidator {
                bottom: 0
            }
            onValueChanged: root.weightChanged(value)
        }

        // Давление
        IndicatorField {
            label: "Давление"
            value: root.pressureValue
            placeholder: "120/80"
            validator: RegularExpressionValidator {
                regularExpression: /^\d{2,3}\/\d{2,3}$/
            }
            onValueChanged: root.pressureChanged(value)
        }

        // Живот
        IndicatorField {
            label: "Обхват талии"
            value: root.waistValue
            placeholder: "Введите обхват (см)"
            validator: DoubleValidator {
                bottom: 0
            }
            onValueChanged: root.waistChanged(value)
        }
    }
}
