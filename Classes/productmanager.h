// productmanager.h
#pragma once

#include <QObject>
#include <QVector>
#include <QVariantMap>

class ProductManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList products READ products NOTIFY productsChanged)
    Q_PROPERTY(QVariantList productTypes READ productTypes NOTIFY productTypesChanged)
    Q_PROPERTY(QVariantList lifeCategories READ lifeCategories NOTIFY lifeCategoriesChanged)

public:
    explicit ProductManager(QObject *parent = nullptr);

    QVariantList products() const;
    QVariantList productTypes() const;
    QVariantList lifeCategories() const;

    Q_INVOKABLE void loadProducts();
    Q_INVOKABLE void filterByType(int typeId);

signals:
    void productsChanged();
    void productTypesChanged();
    void lifeCategoriesChanged();

private:
    QVariantList m_products;
    QVariantList m_productTypes;
    QVariantList m_lifeCategories;
};
