import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolBar {
    property alias title: headerText.text
    property alias backButtonVisible: backBtn.visible

    signal backClicked

    background: Rectangle {
        color: "#9c27b0"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 20

        ToolButton {
            id: backBtn
            icon.source: "qrc:/Images/icons/arrow_back.svg"
            icon.color: "white"
            onClicked: backClicked()
        }

        Label {
            id: headerText
            color: "white"
            font {
                family: "Comfortaa"
                pixelSize: 20
                bold: true
            }
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }
}
