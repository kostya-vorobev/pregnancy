import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Style"

Dialog {
    id: root
    title: "Добавить симптом"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: Math.min(parent.width * 0.9, 400)
    implicitHeight: contentLayout.implicitHeight + 120
    anchors.centerIn: parent
    padding: 15

    property string symptomName: ""
    property int severity: 1

    signal accepted(string symptomName, int severity)

    background: Rectangle {
        radius: Style.radiusMedium
        color: Style.backgroundColor
        border.color: Style.borderColor
        layer.enabled: true
        layer.effect: Style.dropShadow
    }

    ColumnLayout {
        id: contentLayout
        width: parent.width
        spacing: Style.spacingMedium

        // Заголовок
        Label {
            text: "Новый симптом"
            font.pixelSize: Style.titleFontSize
            font.bold: true
            color: Style.textColor
            Layout.alignment: Qt.AlignHCenter
        }

        // Выбор симптома
        Column {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Label {
                text: "Симптом:"
                font.pixelSize: Style.labelFontSize
                color: Style.textSecondaryColor
            }

            CustomComboBoxStandart {
                id: symptomCombo
                width: parent.width
                model: ["Тошнота", "Головная боль", "Боль в спине", "Изжога", "Отеки", "Судороги"]
                currentIndex: 0
                onCurrentTextChanged: root.symptomName = currentText
            }
        }

        // Интенсивность
        Column {
            Layout.fillWidth: true
            spacing: Style.spacingSmall

            Label {
                text: "Интенсивность:"
                font.pixelSize: Style.labelFontSize
                color: Style.textSecondaryColor
            }

            RowLayout {
                width: parent.width
                spacing: Style.spacingMedium

                CustomSlider {
                    id: severitySlider
                    Layout.fillWidth: true
                    from: 1
                    to: 5
                    stepSize: 1
                    value: root.severity
                    onMoved: root.severity = value
                }

                Label {
                    text: root.severity
                    font.pixelSize: Style.valueFontSize
                    color: Style.textColor
                    Layout.minimumWidth: 30
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: Style.spacingSmall
            // Кнопки
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.spacingMedium

                CustomButton {
                    text: "Отмена"
                    flat: true
                    Layout.fillWidth: true
                    onClicked: root.reject()
                }

                CustomButton {
                    text: "Добавить"
                    Layout.fillWidth: true
                    enabled: symptomCombo.currentText.length > 0
                    onClicked: {
                        root.symptomName = symptomCombo.currentText
                        root.accepted(root.symptomName, root.severity)
                        root.close()
                    }
                }
            }
        }
    }

    // Инициализация
    Component.onCompleted: {
        if (symptomCombo.count > 0) {
            symptomCombo.currentIndex = 0
            root.symptomName = symptomCombo.currentText
        }
    }
}
