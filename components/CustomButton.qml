import QtQuick
import QtQuick.Effects

Rectangle {
    id: root
    property alias text: buttonText.text
    property color textColor: "white"
    property color buttonColor: "#9c27b0"
    property int fontSize: 16
    signal clicked

    radius: height / 2
    color: buttonColor
    width: parent.width
    height: 50

    Text {
        id: buttonText
        text: "Button"
        color: textColor
        anchors.centerIn: parent
        font {
            family: "Comfortaa"
            pixelSize: fontSize
            weight: Font.Medium
        }
    }

    MultiEffect {
        anchors.fill: parent
        source: root
        shadowEnabled: true
        shadowColor: "#60000000"
        shadowVerticalOffset: 3
        shadowBlur: 0.3
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("Button clicked:", text)
            root.clicked()
        }
        hoverEnabled: true
        onEntered: root.scale = 0.98
        onExited: root.scale = 1.0
    }

    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }
}
