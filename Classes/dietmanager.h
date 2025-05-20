// dietmanager.h
#ifndef DIETMANAGER_H
#define DIETMANAGER_H

#include <QObject>
#include <QVariantList>

class DietManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList diets READ diets NOTIFY dietsChanged)
    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)

public:
    explicit DietManager(QObject *parent = nullptr);

    QVariantList diets() const;
    QVariantList categories() const;

    Q_INVOKABLE void loadData();
    Q_INVOKABLE void filterByCategory(const QString &category);
    Q_INVOKABLE QVariantMap getDietDetails(const QString &dietNumber);

signals:
    void dietsChanged();
    void categoriesChanged();
    void dataLoaded();

private:
    QVariantList m_allDiets;
    QVariantList m_filteredDiets;
    QVariantList m_categories;
};

#endif // DIETMANAGER_H
