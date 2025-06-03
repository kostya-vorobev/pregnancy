import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts

Rectangle {
    id: root
    property alias text: buttonText.text
    property color textColor: flat ? buttonColor : "white"
    property color buttonColor: "#9c27b0"
    property color pressedColor: Qt.darker(buttonColor, 1.2)
    property color hoverColor: Qt.lighter(buttonColor, 1.1)
    property int fontSize: 16
    property bool boldText: false
    property real shadowSize: 2
    property real shadowOpacity: 0.1
    property bool showBorder: true
    property bool showShadow: true
    property alias fontFamily: buttonText.font.family
    property bool flat: false // Новое свойство flat

    signal clicked
    signal pressed
    signal released

    implicitWidth: Math.max(100, buttonText.implicitWidth + 40)
    implicitHeight: 50
    radius: height / 2
    color: flat ? "transparent" : (internal.down ? pressedColor : (internal.containsMouse ? hoverColor : buttonColor))
    border.color: flat ? buttonColor : "transparent"
    border.width: flat ? 1 : 0

    // Эффекты включаем только для не-flat кнопок


    /*layer.enabled: !flat
    layer.effect: MultiEffect {
        shadowEnabled: !flat && shadowSize > 0
        shadowColor: Qt.rgba(0, 0, 0, shadowOpacity)
        shadowVerticalOffset: shadowSize
        shadowBlur: 0.1
        shadowScale: 1
    }*/
    layer.enabled: showShadow
    layer.effect: DropShadow {
        transparentBorder: true
        radius: 8
        samples: 16
        color: "#20000000"
        verticalOffset: 5
        visible: showShadow
    }

    Text {
        id: buttonText
        text: "Button"
        color: textColor
        anchors.centerIn: parent
        font {
            family: "Comfortaa"
            pixelSize: fontSize
            weight: boldText ? Font.Bold : Font.Medium
        }
    }

    QtObject {
        id: internal
        property bool down: false
        property bool containsMouse: false
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true

        onPressed: {
            internal.down = true
            root.pressed()
            pressAnim.start()
        }
        onReleased: {
            internal.down = false
            root.released()
            releaseAnim.start()
        }
        onClicked: {
            console.log("Button clicked:", text)
            root.clicked()
            clickAnim.start()
        }
        onEntered: {
            internal.containsMouse = true
            hoverAnim.start()
        }
        onExited: {
            internal.containsMouse = false
            hoverAnim.start()
        }
    }

    SequentialAnimation {
        id: pressAnim
        PropertyAction {
            target: root
            property: "scale"
            value: 0.98
        }
        PropertyAction {
            target: root
            property: "z"
            value: 1
        }
    }

    SequentialAnimation {
        id: releaseAnim
        PropertyAction {
            target: root
            property: "z"
            value: 0
        }
        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "scale"
                to: internal.containsMouse ? 1.02 : 1.0
                duration: 100
                easing.type: Easing.OutBack
            }
        }
    }

    SequentialAnimation {
        id: clickAnim
        PropertyAction {
            target: root
            property: "scale"
            value: 0.95
        }
        PauseAnimation {
            duration: 50
        }
        PropertyAction {
            target: root
            property: "scale"
            value: 1.0
        }
    }

    ParallelAnimation {
        id: hoverAnim
        NumberAnimation {
            target: root
            property: "scale"
            to: internal.containsMouse ? 1.02 : 1.0
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    Behavior on color {
        enabled: !flat // Отключаем анимацию цвета для flat кнопок
        ColorAnimation {
            duration: 200
        }
    }

    Behavior on border.color {
        enabled: flat // Анимация только для flat кнопок
        ColorAnimation {
            duration: 200
        }
    }
}
