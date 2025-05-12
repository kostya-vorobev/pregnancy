// components/WeightChartCard.qml
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property var weightData: []
    property color chartColor: "#9c27b0"

    implicitHeight: 250

    Rectangle {
        id: chartCard
        anchors.fill: parent
        radius: 15
        color: "#ffffff"
        border.width: 0

        Canvas {
            id: weightChart
            anchors.fill: parent
            anchors.topMargin: 20
            anchors.rightMargin: 20
            clip: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                if (root.weightData.length === 0)
                    return

                // Расчет min/max с отступами
                var minWeight = Math.min.apply(null, root.weightData.map(
                                                   item => item.weight))
                var maxWeight = Math.max.apply(null, root.weightData.map(
                                                   item => item.weight))
                var range = maxWeight - minWeight || 10
                minWeight -= range * 0.15
                maxWeight += range * 0.15

                // Ось Y
                ctx.strokeStyle = root.chartColor
                ctx.lineWidth = 1.5
                ctx.beginPath()
                ctx.moveTo(30, 0)
                ctx.lineTo(30, height - 30)
                ctx.lineTo(width, height - 30)
                ctx.stroke()

                // Подписи оси Y
                ctx.font = "12px Comfortaa"
                ctx.fillStyle = Qt.darker(root.chartColor, 1.2)
                var steps = 5
                for (var i = 0; i <= steps; i++) {
                    var weight = minWeight + (maxWeight - minWeight) * (1 - i / steps)
                    var y = (height - 35) * (i / steps)
                    ctx.fillText(weight.toFixed(1) + " кг", 5, y + 5)
                }

                // График с плавными линиями
                ctx.strokeStyle = root.chartColor
                ctx.lineWidth = 3
                ctx.beginPath()

                var xStep = (width - 50) / (root.weightData.length - 1)
                root.weightData.forEach((item, index) => {
                                            var x = 35 + index * xStep
                                            var y = (height - 35)
                                            * (1 - (item.weight - minWeight)
                                               / (maxWeight - minWeight))

                                            if (index === 0) {
                                                ctx.moveTo(x, y)
                                            } else {
                                                var prevX = 35 + (index - 1) * xStep
                                                var prevY = (height - 35)
                                                * (1 - (root.weightData[index - 1].weight
                                                        - minWeight) / (maxWeight - minWeight))
                                                ctx.bezierCurveTo(
                                                    prevX + (x - prevX) / 2,
                                                    prevY,
                                                    prevX + (x - prevX) / 2, y,
                                                    x, y)
                                            }
                                        })
                ctx.stroke()

                // Рисуем точки
                ctx.fillStyle = root.chartColor
                root.weightData.forEach((item, index) => {
                                            var x = 35 + index * xStep
                                            var y = (height - 35)
                                            * (1 - (item.weight - minWeight)
                                               / (maxWeight - minWeight))
                                            ctx.beginPath()
                                            ctx.arc(x, y, 5, 0, Math.PI * 2)
                                            ctx.fill()
                                        })
            }
        }
    }

    DropShadow {
        anchors.fill: chartCard
        source: chartCard
        radius: 12
        samples: 24
        color: "#40000000"
        transparentBorder: true
        verticalOffset: 3
    }

    function requestPaint() {
        weightChart.requestPaint()
    }
}
