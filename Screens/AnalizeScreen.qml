import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components" as MyComponents
import PregnancyApp 1.0

Item {
    id: root
    width: parent.width * 0.98
    height: parent.height
    AnalysisManager {
        id: analysisManager

        onAnalysisDataChanged: {
            console.log("Analysis data changed:",
                        JSON.stringify(analysisData, null, 2))
            if (analysisData && Object.keys(analysisData).length > 0) {
                console.log("First category:", Object.keys(analysisData)[0])
                var firstCategory = analysisData[Object.keys(analysisData)[0]]
                if (firstCategory) {
                    var firstParam = Object.keys(firstCategory)[0]
                    console.log("First parameter in category:",
                                firstParam, "Data:",
                                JSON.stringify(firstCategory[firstParam], null,
                                               2))
                }
            }
            console.log("Formatted analysis data:",
                        JSON.stringify(analysisData, null, 2))
            if (analysisData) {
                console.log("Available categories:", Object.keys(analysisData))
            }
        }

        Component.onCompleted: {
            console.log("Initial data:",
                        JSON.stringify(analysisManager.analysisData, null, 2))
        }
    }

    // Динамические данные из базы
    property var analysisData: analysisManager.getFormattedAnalysisData()

    // Фильтрация и поиск
    property string searchQuery: ""
    property var filteredData: {
        if (!analysisData)
            return {}

        let result = {}
        for (const category in analysisData) {
            if (!analysisData[category])
                continue

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

    function getCategoryName(categoryKey) {
        const names = {
            "blood": "Биохимия крови",
            "urine": "Анализ мочи",
            "ultrasound": "УЗИ показатели",
            "Кровь": "Биохимия крови",
            "Моча": "Анализ мочи",
            "УЗИ": "УЗИ показатели"
        }
        return names[categoryKey] || categoryKey
    }

    property var categoryColors: {
        "blood": "#fff0f0",
        "urine": "#f0fff0",
        "ultrasound": "#f0f8ff",
        "Кровь": "#fff0f0",
        "Моча"// Добавлено для русских ключей
        : "#f0fff0",
        "УЗИ"// Добавлено для русских ключей
        : "#f0f8ff" // Добавлено для русских ключей
    }

    // 4. Функции преобразования данных
    function getParameterName(fullKey) {
        // Извлекаем имя параметра из ключа (формат "name_date_id")
        var paramKey = fullKey.split('_')[0]

        const names = {
            "hgb": "Гемоглобин",
            "hemoglobin": "Гемоглобин",
            "wbc": "Лейкоциты",
            "glu": "Глюкоза",
            "glucose": "Глюкоза",
            "pro": "Белок",
            "protein": "Белок",
            "bpd": "Бипариетальный размер",
            "fl": "Длина бедренной кости"
        }
        return names[paramKey.toLowerCase()] || paramKey
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

        // 1. Панель поиска и фильтров (фиксированная высота)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50 // Явно задаем высоту
            spacing: 10

            MyComponents.CustomTextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Поиск показателей..."
                onTextChanged: searchQuery = text
            }

            MyComponents.CustomButton {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                text: "Сброс"
                onClicked: {
                    searchQuery = ""
                    searchField.text = ""
                }
            }
        }

        // 2. Переключение категорий (фиксированная высота)
        MyComponents.CategoryTabs {
            id: categoryTabs
            Layout.fillWidth: true
            Layout.preferredHeight: 60 // Явно задаем высоту
            currentIndex: 0
            onCategorySelected: category => {
                                    console.log("Выбрана категория:", category)
                                    selectedCategory = category
                                }
        }

        // 3. Список показателей (гибкое пространство)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true // Занимает все оставшееся пространство

            Flickable {
                id: scrollView
                anchors.fill: parent
                contentWidth: width
                contentHeight: contentColumn.height
                clip: true

                Column {
                    id: contentColumn
                    width: scrollView.width
                    spacing: 20

                    Repeater {
                        model: {
                            if (!filteredData
                                    || !filteredData[selectedCategory])
                                return []
                            var categoryData = filteredData[selectedCategory]
                            return Object.keys(categoryData).map(key => {
                                                                     return {
                                                                         "paramKey": key.split(
                                                                                         '_')[0],
                                                                         "data"// Извлекаем оригинальное имя параметра
                                                                         : categoryData[key]
                                                                     }
                                                                 })
                        }

                        delegate: MyComponents.AnalysisSection {
                            width: contentColumn.width - 20
                            title: getCategoryName(selectedCategory)
                            dataModel: {
                                var result = {}
                                result[modelData.paramKey] = modelData.data
                                return result
                            }
                            backgroundColor: categoryColors[selectedCategory]
                                             || "#f0f8ff"
                            itemHeight: 80
                            onShowDetailsRequested: {
                                parameterDetailsPopup.parameterData = parameterData
                                parameterDetailsPopup.parameterName = parameterName
                                parameterDetailsPopup.open()
                            }
                        }
                    }
                }
            }
        }

        // 5. Попап (не занимает места в layout)
        MyComponents.ParameterDetailsPopup {
            id: parameterDetailsPopup
            anchors.centerIn: Overlay.overlay
        }

        // Кнопки действий
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            MyComponents.CustomButton {
                text: "Добавить анализ"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                onClicked: addAnalysisDialog.open()
            }
        }
    }

    // 7. Диалог добавления анализа

    // В корневом Item добавьте:
    MyComponents.AddAnalysisDialog {
        id: addAnalysisDialog
        analysisManager: analysisManager
        anchors.centerIn: parent

        onAnalysisAdded: function (typeId, value, testDate, notes, laboratory, isFasting) {
            if (analysisManager.addAnalysis(typeId, value, testDate, notes,
                                            laboratory, isFasting)) {
                console.log("Анализ успешно добавлен")
            } else {
                console.log("Ошибка при добавлении анализа")
            }
        }
    }

    MyComponents.HistoryPopup {
        id: historyPopup
        anchors.centerIn: parent
        parameterName: "Гемоглобин"
        parameterUnit: "г/л"

        onRequestHistory: function (typeId) {
            // Запросить данные из базы
            var history = analysisManager.getAnalysisHistory(typeId)
            historyPopup.historyModel = history
        }
    }
}
