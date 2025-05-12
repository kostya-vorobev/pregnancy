import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Popup {
    id: root
    modal: true
    dim: true
    width: Math.min(parent.width * 0.9, 500)
    implicitHeight: header.height + contentLayout.implicitHeight + footerLayout.implicitHeight + 40
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay

    property alias weight: weightInput.text
    property alias date: dateInput.text
    property date currentDate: new Date()

    signal accepted(real weight, date date)
    signal rejected

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 200
            }
            NumberAnimation {
                property: "scale"
                from: 0.8
                to: 1
                duration: 300
                easing.type: Easing.OutBack
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 200
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.8
                duration: 200
            }
        }
    }

    background: Rectangle {
        color: "#ffffff"
        radius: 20
        layer.enabled: true
        layer.effect: DropShadow {
            radius: 20
            samples: 41
            color: "#80000000"
            verticalOffset: 5
        }
    }

    Rectangle {
        width: parent.width
        height: 60
        color: "#9c27b0"
        radius: 20
        clip: true

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, parent.height)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.lighter("#9c27b0", 1.3)
                }
                GradientStop {
                    position: 1.0
                    color: "#9c27b0"
                }
            }
        }

        Label {
            text: "Добавить вес"
            anchors.centerIn: parent
            font {
                family: "Comfortaa"
                pixelSize: 20
                bold: true
            }
            color: "white"
        }
    }

    contentItem: Item {
        ColumnLayout {
            id: contentLayout
            width: parent.width
            spacing: 15
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20

            Label {
                text: "Введите данные:"
                font {
                    family: "Comfortaa"
                    pixelSize: 16
                }
                color: "#7b1fa2"
                Layout.topMargin: 10
            }

            TextField {
                id: weightInput
                placeholderText: "Вес (кг)"
                validator: DoubleValidator {
                    bottom: 30
                    top: 300
                    decimals: 1
                }
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                Layout.fillWidth: true
                font {
                    family: "Comfortaa"
                    pixelSize: 16
                }
                padding: 15
                background: Rectangle {
                    color: "#f3e5f5"
                    border.color: "#9c27b0"
                    border.width: 1
                    radius: 10
                }
            }

            TextField {
                id: dateInput
                placeholderText: "Дата (дд.мм.гггг)"
                inputMask: "99.99.9999"
                text: Qt.formatDateTime(root.currentDate, "dd.MM.yyyy")
                Layout.fillWidth: true
                font {
                    family: "Comfortaa"
                    pixelSize: 16
                }
                padding: 15
                background: Rectangle {
                    color: "#f3e5f5"
                    border.color: "#9c27b0"
                    border.width: 1
                    radius: 10
                }
            }
        }
    }

    Item {
        anchors.bottom: parent.bottom
        implicitHeight: footerLayout.implicitHeight
        width: parent.width

        RowLayout {
            id: footerLayout
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            spacing: 15

            Button {
                text: "Отмена"
                font.family: "Comfortaa"
                flat: true
                onClicked: {
                    root.rejected()
                    root.close()
                }
            }

            Button {
                text: "Добавить"
                font.family: "Comfortaa"
                highlighted: true
                onClicked: {
                    var weight = parseFloat(weightInput.text)
                    var dateParts = dateInput.text.split('.')
                    var date = new Date(dateParts[2], dateParts[1] - 1,
                                        dateParts[0])

                    if (!isNaN(weight)) {
                        root.accepted(weight,
                                      isNaN(date.getTime()) ? new Date() : date)
                        root.close()
                    }
                }
            }
        }
    }

    onOpened: {
        weightInput.text = ""
        dateInput.text = Qt.formatDateTime(currentDate, "dd.MM.yyyy")
        weightInput.forceActiveFocus()
    }
}
