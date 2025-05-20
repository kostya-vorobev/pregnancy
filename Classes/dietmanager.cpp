// dietmanager.cpp
#include "dietmanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

DietManager::DietManager(QObject *parent) : QObject(parent)
{
    loadData();
}

QVariantList DietManager::diets() const {
    return m_filteredDiets;
}

QVariantList DietManager::categories() const {
    return m_categories;
}

void DietManager::loadData()
{
    // Загрузка категорий
    QSqlQuery categoryQuery("SELECT id, name, icon FROM DietCategories");
    m_categories.clear();

    while (categoryQuery.next()) {
        QVariantMap category;
        category["id"] = categoryQuery.value(0);
        category["name"] = categoryQuery.value(1);
        category["icon"] = categoryQuery.value(2);
        m_categories.append(category);
    }
    emit categoriesChanged();

    // Загрузка диет
    QSqlQuery dietQuery("SELECT d.id, d.number, d.title, d.color, d.icon, "
                        "c.name as categoryName FROM Diets d "
                        "JOIN DietCategories c ON d.categoryId = c.id");

    m_allDiets.clear();
    while (dietQuery.next()) {
        QVariantMap diet;
        diet["id"] = dietQuery.value(0);
        diet["number"] = dietQuery.value(1);
        diet["title"] = dietQuery.value(2);
        diet["color"] = dietQuery.value(3);
        diet["icon"] = dietQuery.value(4);
        diet["categoryName"] = dietQuery.value(5);
        m_allDiets.append(diet);
    }

    // Показываем все диеты по умолчанию
    m_filteredDiets = m_allDiets;
    emit dietsChanged();
    emit dataLoaded();
}

void DietManager::filterByCategory(const QString &category)
{
    if (category == "Все диеты") {
        m_filteredDiets = m_allDiets;
    } else {
        m_filteredDiets.clear();
        for (const QVariant &diet : m_allDiets) {
            if (diet.toMap()["categoryName"] == category) {
                m_filteredDiets.append(diet);
            }
        }
    }
    emit dietsChanged();
}

QVariantMap DietManager::getDietDetails(const QString &dietNumber)
{
    QVariantMap details;

    // Основная информация о диете
    QSqlQuery dietQuery;
    dietQuery.prepare("SELECT d.title, dd.indications, dd.dietSchedule, dd.notes "
                      "FROM Diets d JOIN DietDetails dd ON d.id = dd.dietId "
                      "WHERE d.number = :number");
    dietQuery.bindValue(":number", dietNumber);

    if (!dietQuery.exec() || !dietQuery.next()) {
        qWarning() << "Failed to get diet details:" << dietQuery.lastError();
        return details;
    }

    details["number"] = dietNumber;
    details["title"] = dietQuery.value(0);
    details["indications"] = dietQuery.value(1);
    details["dietSchedule"] = dietQuery.value(2);
    details["notes"] = dietQuery.value(3);

    // Рекомендуемые продукты
    QSqlQuery recQuery;
    recQuery.prepare("SELECT category, item FROM RecommendedFoods "
                     "WHERE dietId = (SELECT id FROM Diets WHERE number = :number)");
    recQuery.bindValue(":number", dietNumber);
    recQuery.exec();

    QVariantList recommended;
    while (recQuery.next()) {
        QVariantMap item;
        item["category"] = recQuery.value(0);
        item["items"] = QStringList(recQuery.value(1).toString());
        recommended.append(item);
    }
    details["recommendedFoods"] = recommended;

    // Исключенные продукты
    QSqlQuery exclQuery;
    exclQuery.prepare("SELECT category, item FROM ExcludedFoods "
                      "WHERE dietId = (SELECT id FROM Diets WHERE number = :number)");
    exclQuery.bindValue(":number", dietNumber);
    exclQuery.exec();

    QVariantList excluded;
    while (exclQuery.next()) {
        QVariantMap item;
        item["category"] = exclQuery.value(0);
        item["items"] = QStringList(exclQuery.value(1).toString());
        excluded.append(item);
    }
    details["excludedFoods"] = excluded;

    return details;
}
