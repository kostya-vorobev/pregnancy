pragma Singleton

import QtQuick
import Qt5Compat.GraphicalEffects

QtObject {
    // Цвета
    readonly property color primaryColor: "#9c27b0"
    readonly property color backgroundColor: "#ffffff"
    readonly property color textColor: "#333333"
    readonly property color textSecondaryColor: "#666666"
    readonly property color borderColor: "#e0e0e0"

    // Размеры
    readonly property int radiusSmall: 4
    readonly property int radiusMedium: 8
    readonly property int titleFontSize: 18
    readonly property int labelFontSize: 14
    readonly property int valueFontSize: 16

    // Отступы
    readonly property int spacingSmall: 5
    readonly property int spacingMedium: 10

    // Эффекты
    property Component dropShadow: DropShadow {
        radius: 8
        samples: 16
        color: "#40000000"
        spread: 0.1
    }
}
