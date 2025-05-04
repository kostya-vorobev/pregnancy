import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Column {
    id: root
    property string title
    property var dataModel
    property color textColor: "#4a148c"
    property color warningColor: "#e91e63"
    property color highValueColor: "#ff9800"
    property color normalColor: "#4caf50"
    property color backgroundColor: "#f5f5f5"
    property int itemHeight: 72
    property int itemRadius: 8
    signal showDetailsRequested(var parameterData, string parameterName)
    spacing: 12

    // Заголовок секции с иконкой
    RowLayout {
        width: parent.width
        spacing: 10

        Label {
            text: title
            font {
                pixelSize: 18
                bold: true
            }
            color: "#9c27b0"
            leftPadding: 10
            Layout.fillWidth: true
        }

        GearButton {
            tooltipText: "Настройки " + title

            onClicked: {
                console.log("Настройки раздела", title)
                // Дополнительные действия при клике
            }
        }
    }

    // Список показателей
    Repeater {
        model: Object.keys(dataModel)

        delegate: AnalysisItemDelegate {
            width: root.width
            height: root.itemHeight
            radius: root.itemRadius
            parameterData: dataModel[modelData]
            parameterName: getParameterName(modelData)
            showTrend: true
            onClicked: {
                console.log("Выбран параметр:", modelData)
                // Можно добавить дополнительную логику
            }
        }
    }

    // Вспомогательные функции
    function getParameterName(key) {
        const names = {
            "hemoglobin": qsTr("Гемоглобин"),
            "glucose": qsTr("Глюкоза"),
            "protein": qsTr("Белок"),
            "bpd": qsTr("БПР (бипариетальный размер)"),
            "fl": qsTr("Длина бедра"),
            "hc": qsTr("Окружность головы"),
            "ac": qsTr("Окружность живота"),
            "wbc": qsTr("Лейкоциты"),
            "rbc": qsTr("Эритроциты")
        }
        return names[key] || key
    }

    // Вложенный компонент для элемента анализа
    component AnalysisItemDelegate: Rectangle {
        id: delegateRoot
        property var parameterData
        property string parameterName
        property bool showTrend: false
        signal clicked

        property bool isLow: parameterData.min !== undefined
                             && parameterData.value < parameterData.min
        property bool isHigh: parameterData.max !== undefined
                              && parameterData.value > parameterData.max
        property bool isNormal: !isLow && !isHigh

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 16

            // Иконка статуса с анимацией
            Rectangle {
                id: statusIndicator
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: {
                    if (isLow)
                        return root.warningColor
                    if (isHigh)
                        return root.highValueColor
                    return root.normalColor
                }

                Label {
                    anchors.centerIn: parent
                    text: {
                        if (isLow)
                            return "↓"
                        if (isHigh)
                            return "↑"
                        return "✓"
                    }
                    color: "white"
                    font.bold: true
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
                }
            }

            // Основная информация
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                // Название параметра с возможностью настройки
                Label {
                    text: delegateRoot.parameterName
                    font {
                        pixelSize: 15
                        bold: true
                    }
                    color: root.textColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                // Значение и единицы измерения
                Row {
                    spacing: 6
                    Label {
                        text: parameterData.value
                        font {
                            pixelSize: 13
                            bold: true
                        }
                        color: delegateRoot.isNormal ? "#666" : (delegateRoot.isLow ? root.warningColor : root.highValueColor)
                    }

                    Label {
                        text: parameterData.unit
                        font.pixelSize: 13
                        color: "#666"
                    }

                    // Отображение тренда если доступно
                    Label {
                        visible: showTrend && parameterData.trend
                        text: {
                            switch (parameterData.trend) {
                            case "increasing":
                                return "↗"
                            case "decreasing":
                                return "↘"
                            case "stable":
                                return "→"
                            default:
                                return ""
                            }
                        }
                        color: {
                            if (parameterData.trend === "increasing")
                                return root.highValueColor
                            if (parameterData.trend === "decreasing")
                                return root.warningColor
                            return root.normalColor
                        }
                        font.bold: true
                    }
                }

                // Референсные значения
                Label {
                    text: getNormalRangeText(parameterData)
                    font.pixelSize: 11
                    color: "#888"
                }
            }

            // Кнопка детализации
            ToolButton {
                text: "›"
                font.pixelSize: 20
                onClicked: delegateRoot.clicked()
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                delegateRoot.clicked()
                // Передаем данные в родительский компонент
                root.showDetailsRequested(parameterData, parameterName)
            }
            hoverEnabled: true
            onEntered: delegateRoot.color = Qt.lighter(root.backgroundColor,
                                                       1.1)
            onExited: delegateRoot.color = root.backgroundColor
        }

        function getNormalRangeText(data) {
            if (data.min !== undefined && data.max !== undefined) {
                return qsTr("Норма") + ": " + data.min + "-" + data.max + " " + data.unit
            } else if (data.max !== undefined) {
                return qsTr("Макс") + ": " + data.max + " " + data.unit
            } else if (data.min !== undefined) {
                return qsTr("Мин") + ": " + data.min + " " + data.unit
            }
            return ""
        }
    }
}
