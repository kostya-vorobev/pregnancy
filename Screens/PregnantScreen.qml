import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../components" as MyComponents

Item {
    id: root
    height: parent.height
    width: parent.width
    visible: true

    property color primaryColor: "#9c27b0"
    property color textColor: "#4a148c"
    property real defaultRadius: 14
    property int currentWeek: 2

    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#f3e5f5"
            }
            GradientStop {
                position: 1.0
                color: "#e1bee7"
            }
        }

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: contentColumn.width
            contentHeight: contentColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentColumn
                spacing: 15
                padding: 20
                width: root.width - padding * 2
                Text {
                    text: "Ваша беременность"
                    font {
                        family: "Comfortaa"
                        pixelSize: Math.min(24, root.width * 0.07)
                        weight: Font.Bold
                    }
                    color: textColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // Выбор недели
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Срок беременности:"
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(16, root.width * 0.045)
                        }
                        color: textColor
                    }

                    MyComponents.CustomComboBox {
                        id: weekComboBox
                        width: parent.width
                        model: Array.from({
                                              "length": 42
                                          }, (_, i) => `${i + 1} неделя`)
                        currentIndex: currentWeek - 1
                        fontSize: Math.min(16, root.width * 0.045)
                        onActivated: index => currentWeek = index + 1
                    }
                }

                // Информационный блок
                Rectangle {
                    width: parent.width
                    height: infoText.height + 30
                    radius: 8
                    color: "#f1f8e9"
                    border.color: "#dcedc8"

                    Text {
                        id: infoText
                        text: getWeekInfo(currentWeek)
                        font {
                            family: "Comfortaa"
                            pixelSize: Math.min(14, root.width * 0.04)
                        }
                        color: "#2e7d32"
                        width: parent.width - 20
                        wrapMode: Text.WordWrap
                        anchors {
                            top: parent.top
                            left: parent.left
                            margins: 15
                        }
                    }
                }

                // Кнопка подтверждения
                MyComponents.CustomButton {
                    width: parent.width
                    text: "Подтвердить"
                    fontSize: Math.min(16, root.width * 0.045)
                    onClicked: console.log("Выбрана неделя:", currentWeek)
                }

                // Кнопка назад
                MyComponents.CustomButton {
                    width: parent.width
                    text: "Назад"
                    buttonColor: "#e0e0e0"
                    textColor: root.textColor
                    fontSize: Math.min(16, root.width * 0.045)
                    onClicked: if (typeof stackView !== 'undefined')
                                   stackView.pop()
                }
            }
        }
    }

    function getWeekInfo(week) {
        if (week < 12)
            return `На ${week} неделе:\n● Формируются основные органы\n● Начинается сердцебиение`
        if (week < 28)
            return `На ${week} неделе:\n● Активный рост плода\n● Развитие органов чувств`
        return `На ${week} неделе:\n● Завершающий этап развития\n● Подготовка к родам`
    }

    Component.onCompleted: {
        console.log("Размеры экрана:", Screen.width, "x", Screen.height)
        console.log("Размеры окна:", width, "x", height)
    }
}
