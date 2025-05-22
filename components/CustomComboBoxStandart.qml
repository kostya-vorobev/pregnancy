import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ComboBox {
    id: control
    font.pixelSize: 14
    padding: 8

    // Стилевые свойства (можно переопределять)
    property color backgroundColor: "#ffffff"
    property color borderColor: "#e0e0e0"
    property color highlightColor: "#9c27b0"
    property color textColor: "#333333"
    property int radius: 4

    delegate: ItemDelegate {
        width: control.width
        height: 40
        text: modelData
        font: control.font
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: modelData
            font: parent.font
            color: parent.highlighted ? "#ffffff" : control.textColor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
        }

        background: Rectangle {
            color: parent.highlighted ? control.highlightColor : control.backgroundColor
            radius: control.radius
        }
    }

    contentItem: Text {
        leftPadding: 10
        rightPadding: control.indicator.width + 10
        text: control.displayText
        font: control.font
        color: control.enabled ? control.textColor : "#999999"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40
        radius: control.radius
        color: control.backgroundColor
        border.color: control.activeFocus ? control.highlightColor : control.borderColor
        border.width: control.activeFocus ? 2 : 1
    }

    popup: Popup {
        y: control.height + 2
        width: control.width
        implicitHeight: Math.min(contentItem.implicitHeight, 400)
        padding: 2

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            radius: control.radius
            color: control.backgroundColor
            border.color: control.borderColor
            layer.enabled: true

            layer.effect: DropShadow {
                transparentBorder: true
                radius: 5
                samples: 10
                color: "#30000000"
            }
        }
    }

    indicator: Canvas {
        x: control.width - width - 10
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = control.activeFocus ? control.highlightColor : control.textColor
            ctx.fill()
        }
    }
}
