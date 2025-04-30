import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents

Item {
    id: root
    width: parent.width * 0.98
    height: parent.height

    // 1. Расширенная модель данных
    readonly property var analysisData: {
        "blood": {
            "hemoglobin": {
                "value": 125,
                "min": 110,
                "max": 140,
                "unit": "г/л",
                "trend": "stable"
            },
            "glucose": {
                "value": 4.8,
                "min": 3.3,
                "max": 5.5,
                "unit": "ммоль/л",
                "trend": "decreasing"
            },
            "wbc": {
                "value": 8.2,
                "min": 4.0,
                "max": 9.0,
                "unit": "×10⁹/л",
                "trend": "increasing"
            }
        },
        "urine": {
            "protein": {
                "value": 0.1,
                "max": 0.3,
                "unit": "г/л",
                "trend": "stable"
            },
            "leukocytes": {
                "value": 1,
                "max": 5,
                "unit": "в поле зрения"
            }
        },
        "ultrasound": {
            "bpd": {
                "value": 24,
                "min": 21,
                "max": 27,
                "unit": "мм",
                "gestational_age": "12 недель"
            },
            "fl": {
                "value": 9,
                "min": 8,
                "max": 11,
                "unit": "мм"
            }
        }
    }

    // 2. Фильтрация и поиск
    property string searchQuery: ""
    property var filteredData: {
        let result = {}
        for (const category in analysisData) {
            result[category] = {}
            for (const param in analysisData[category]) {
                const name = getParameterName(param).toLowerCase()
                if (name.includes(searchQuery.toLowerCase())) {
                    result[category][param] = analysisData[category][param]
                }
            }
        }
        return result
    }

    // 3. Состояние интерфейса
    property string selectedCategory: "blood"
    property bool showDetails: false
    property var currentDetails: ({})

    // 4. Функции преобразования данных
    function getParameterName(key) {
        const names = {
            "hemoglobin": "Гемоглобин",
            "glucose": "Глюкоза",
            "wbc": "Лейкоциты",
            "protein": "Белок",
            "leukocytes": "Лейкоциты",
            "bpd": "Бипариетальный размер",
            "fl": "Длина бедренной кости"
        }
        return names[key] || key
    }

    function getTrendIcon(trend) {
        return {
            "increasing": "↑",
            "decreasing": "↓",
            "stable": "→"
        }[trend] || ""
    }

    // 5. Основной интерфейс
    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Панель поиска и фильтров
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Поиск показателей..."
                onTextChanged: searchQuery = text
            }

            MyComponents.CustomButton {
                text: "Сброс"
                onClicked: {
                    searchQuery = ""
                    searchField.text = ""
                }
            }
        }

        // Переключение категорий
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: 0

            Repeater {
                model: ["Кровь", "Моча", "УЗИ"]
                TabButton {
                    text: modelData
                    onClicked: selectedCategory = ["blood", "urine", "ultrasound"][index]
                }
            }
        }

        // Список показателей
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Column {
                width: parent.width
                spacing: 8

                Repeater {
                    model: Object.keys(filteredData[selectedCategory] || {})

                    MyComponents.AnalysisSection {
                        width: parent.width
                        title: "Биохимия крови"
                        dataModel: {
                            "glucose": {
                                "value": 5.1,
                                "min": 3.9,
                                "max": 6.1,
                                "unit": "ммоль/л",
                                "trend": "stable"
                            },
                            "creatinine": {
                                "value": 78,
                                "min": 50,
                                "max": 90,
                                "unit": "мкмоль/л"
                            }
                        }
                        backgroundColor: "#f0f8ff"
                        itemHeight: 80
                    }
                }
            }
        }

        // Кнопки действий
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MyComponents.CustomButton {
                text: "Добавить анализ"
                Layout.fillWidth: true
                onClicked: addAnalysisDialog.open()
            }

            MyComponents.CustomButton {
                text: "История"
                Layout.fillWidth: true
                onClicked: historyPopup.open()
            }
        }
    }

    // 6. Детализация показателя
    Popup {
        id: detailsPopup
        width: parent.width * 0.9
        height: parent.height * 0.7
        anchors.centerIn: parent
        modal: true
        visible: showDetails

        ColumnLayout {
            width: parent.width
            spacing: 15

            Label {
                text: currentDetails.name || ""
                font.bold: true
                font.pixelSize: 20
                Layout.alignment: Qt.AlignHCenter
            }

            GridLayout {
                columns: 2
                columnSpacing: 20
                rowSpacing: 10
                Layout.fillWidth: true

                Label {
                    text: "Текущее значение:"
                    font.bold: true
                }
                Label {
                    text: currentDetails.value + " " + currentDetails.unit
                }

                Label {
                    text: "Референсные значения:"
                    font.bold: true
                }
                Label {
                    text: (currentDetails.min !== undefined ? currentDetails.min + "-" : "")
                          + (currentDetails.max || "")
                }

                Label {
                    text: "Тренд:"
                    font.bold: true
                }
                Label {
                    text: getTrendIcon(currentDetails.trend)
                }

                Label {
                    text: "Рекомендации:"
                    font.bold: true
                }
                Label {
                    text: getRecommendations(currentDetails)
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: parent.width * 0.7
                }
            }

            Button {
                text: "Закрыть"
                Layout.alignment: Qt.AlignHCenter
                onClicked: showDetails = false
            }
        }

        function getRecommendations(details) {
            if (!details.value)
                return "Нет данных для рекомендаций"

            if (details.min !== undefined && details.value < details.min) {
                return "• Увеличьте потребление железосодержащих продуктов\n• Проконсультируйтесь с врачом"
            }

            if (details.max !== undefined && details.value > details.max) {
                return "• Соблюдайте диету\n• Пройдите дополнительные обследования"
            }

            return "Показатель в норме. Продолжайте текущий режим."
        }
    }

    // 7. Диалог добавления анализа

    // В корневом Item добавьте:
    MyComponents.AddAnalysisDialog {
        id: addAnalysisDialog
        anchors.centerIn: parent
        onAnalysisAdded: function (category, parameter, value, testDate) {
            console.log("Добавлен анализ:", category, parameter,
                        value, testDate)
            // Здесь логика добавления в историю и обновления данных
        }
    }

    MyComponents.HistoryPopup {
        id: historyPopup
        anchors.centerIn: parent
    }
}
