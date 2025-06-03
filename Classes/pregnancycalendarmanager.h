#ifndef PREGNANCYCALENDARMANAGER_H
#define PREGNANCYCALENDARMANAGER_H

#include <QObject>
#include <QDate>
#include <QVariantMap>
#include "databasemanager.h"

class PregnancyCalendarManager : public QObject
{
    Q_OBJECT
public:
    explicit PregnancyCalendarManager(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap loadPregnancyData();
    Q_INVOKABLE QVariantMap getDayData(const QString &date);
    Q_INVOKABLE void saveDayData(const QString &date, const QString &weight,
                                 const QString &pressure, const QString &waist,
                                 const QString &mood, const QString &notes);
    Q_INVOKABLE QVariantList getAvailableSymptoms();
    Q_INVOKABLE void saveSymptoms(const QString &date, const QVariantList &symptoms);
    Q_INVOKABLE void addDailyPlan(const QString &date, const QString &planType,
                                  const QString &description, const QString &time);
    Q_INVOKABLE int lastInsertedPlanId();
    Q_INVOKABLE void deletePlan(int planId);

private:
    DatabaseManager& m_dbManager;
};

#endif // PREGNANCYCALENDARMANAGER_H
