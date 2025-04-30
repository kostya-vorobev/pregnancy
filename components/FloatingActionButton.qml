import QtQuick 2.15
import QtQuick.Controls 2.15

RoundButton {
    width: 56
    height: 56
    radius: 28
    highlighted: true

    Image {
        anchors.centerIn: parent
        source: parent.iconSource
        width: 24
        height: 24
    }
}
