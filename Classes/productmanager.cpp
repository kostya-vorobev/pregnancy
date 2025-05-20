// productmanager.cpp
#include "productmanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

ProductManager::ProductManager(QObject *parent) : QObject(parent)
{
    loadProducts();
}

QVariantList ProductManager::products() const {
    return m_products;
}

QVariantList ProductManager::productTypes() const {
    return m_productTypes;
}

QVariantList ProductManager::lifeCategories() const {
    return m_lifeCategories;
}

void ProductManager::loadProducts() {
    // Загрузка типов продуктов
    QSqlQuery typeQuery("SELECT id, name, icon FROM ProductTypes");
    m_productTypes.clear();
    while (typeQuery.next()) {
        QVariantMap type;
        type["id"] = typeQuery.value(0);
        type["name"] = typeQuery.value(1);
        type["icon"] = typeQuery.value(2);
        m_productTypes.append(type);
    }
    emit productTypesChanged();

    // Загрузка категорий жизни
    QSqlQuery categoryQuery("SELECT id, name, description FROM LifeCategories");
    m_lifeCategories.clear();
    while (categoryQuery.next()) {
        QVariantMap category;
        category["id"] = categoryQuery.value(0);
        category["name"] = categoryQuery.value(1);
        category["description"] = categoryQuery.value(2);
        m_lifeCategories.append(category);
    }
    emit lifeCategoriesChanged();

    // Загрузка продуктов
    filterByType(-1); // Загрузить все продукты
}

void ProductManager::filterByType(int typeId) {
    QString queryStr = "SELECT p.id, p.name, p.typeId, p.imageSource, p.description, "
                       "t.name as typeName FROM Products p "
                       "JOIN ProductTypes t ON p.typeId = t.id ";

    if (typeId >= 0) {
        queryStr += "WHERE p.typeId = :typeId";
    }

    QSqlQuery query;
    query.prepare(queryStr);
    if (typeId >= 0) {
        query.bindValue(":typeId", typeId);
    }

    if (!query.exec()) {
        qWarning() << "Failed to execute products query:" << query.lastError();
        return;
    }

    m_products.clear();
    while (query.next()) {
        QVariantMap product;
        product["id"] = query.value(0);
        product["name"] = query.value(1);
        product["typeId"] = query.value(2);
        product["imageSource"] = query.value(3);
        product["description"] = query.value(4);
        product["typeName"] = query.value(5);

        // Загрузка рекомендаций для продукта
        QSqlQuery recQuery;
        recQuery.prepare("SELECT c.name, r.status, r.recommendation "
                         "FROM ProductRecommendations r "
                         "JOIN LifeCategories c ON r.categoryId = c.id "
                         "WHERE r.productId = :productId");
        recQuery.bindValue(":productId", product["id"]);
        recQuery.exec();

        QVariantList recommendations;
        while (recQuery.next()) {
            QVariantMap rec;
            rec["category"] = recQuery.value(0);
            rec["status"] = recQuery.value(1);
            rec["recommendation"] = recQuery.value(2);
            recommendations.append(rec);
        }
        product["recommendations"] = recommendations;

        m_products.append(product);
    }

    emit productsChanged();
}
