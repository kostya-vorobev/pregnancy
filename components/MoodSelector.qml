import QtQuick
import QtQuick.Controls

Column {
    id: root
    spacing: 10

    property string currentMood: ""
    signal moodSelected(string mood)

    Label {
        text: "Настроение"
        font.pixelSize: 16
        color: "#4a148c"
    }

    CustomComboBoxStandart {
        id: moodCombo
        width: parent.width
        model: ["", "Отличное", "Хорошее", "Нормальное", "Плохое", "Ужасное"]
        currentIndex: {
            switch (root.currentMood) {
            case "Отличное":
                return 1
            case "Хорошее":
                return 2
            case "Нормальное":
                return 3
            case "Плохое":
                return 4
            case "Ужасное":
                return 5
            default:
                return 0
            }
        }
        onActivated: root.moodSelected(currentText)

        delegate: ItemDelegate {
            width: parent.width
            text: modelData
            highlighted: moodCombo.highlightedIndex === index
        }
    }
}
