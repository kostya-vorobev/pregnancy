import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

TextField {
    id: textField
    property real fontSize: 16
    property color accentColor: "#7E57C2"
    property color textColor: "#333333"
    property color placeholderColor: "#999999"
    property color backgroundColor: "#FFFFFF"
    property bool showBorder: true
    property bool showShadow: true
    property bool showClearButton: true
    property string placeholderTextValue: ""

    height: 50
    font {
        family: "Comfortaa"
        pixelSize: fontSize
        weight: Font.Normal
    }
    color: textColor
    padding: 15
    verticalAlignment: Text.AlignVCenter
    selectByMouse: true
    selectedTextColor: "#FFFFFF"
    selectionColor: accentColor
    placeholderTextColor: placeholderColor

    // Анимация при фокусе
    property real focusAnimationDuration: 150
    property real borderWidth: focus ? 2 : 1

    Behavior on placeholderTextColor {
        enabled: false
    }

    Behavior on borderWidth {
        NumberAnimation {
            duration: focusAnimationDuration
        }
    }

    // Стилизованный фон
    background: Rectangle {
        radius: 8
        color: backgroundColor
        border.color: showBorder ? (textField.focus ? accentColor : "#E0E0E0") : "transparent"
        border.width: textField.borderWidth

        // Тень
        layer.enabled: showShadow
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 8
            samples: 16
            color: "#20000000"
            verticalOffset: 2
            visible: showShadow
        }
    }

    // Кнопка очистки
    Text {
        id: clearButton
        visible: showClearButton && textField.text.length > 0
                 && textField.activeFocus
        anchors {
            right: parent.right
            rightMargin: 15
            verticalCenter: parent.verticalCenter
        }
        text: "×"
        font {
            family: "Comfortaa"
            pixelSize: fontSize * 1.5
            bold: true
        }
        color: accentColor
        opacity: 0.7

        MouseArea {
            anchors.fill: parent
            onClicked: {
                textField.text = ""
                textField.focus = true
            }
            onPressed: parent.opacity = 1.0
            onReleased: parent.opacity = 0.7
        }
    }

    // Кастомный плейсхолдер
    Text {
        id: customPlaceholder
        visible: textField.text.length === 0
        text: placeholderTextValue // или свойство
        color: textField.placeholderColor
        font: textField.font
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: textField.leftPadding
            rightMargin: textField.rightPadding + (clearButton.visible ? clearButton.width : 0)
        }
        width: parent.width - (textField.leftPadding + textField.rightPadding
                               + (clearButton.visible ? clearButton.width : 0))
        elide: Text.ElideRight
    }

    // Анимация при наведении
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onEntered: if (!textField.focus)
                       textField.borderWidth = 1.5
        onExited: if (!textField.focus)
                      textField.borderWidth = 1
        onClicked: textField.forceActiveFocus()
    }

    onTextChanged: {
        checkPlaceholderText()
    }

    onFocusChanged: {
        checkPlaceholderText()
    }

    function checkPlaceholderText() {
        if (text.length > 0) {
            placeholderText = ""
        } else {
            placeholderText = ""
        }
    }
}
