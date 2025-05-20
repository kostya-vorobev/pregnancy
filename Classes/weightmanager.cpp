// weightmanager.cpp
#include "weightmanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDate>

WeightManager::WeightManager(QObject *parent) : QObject(parent), m_profileId(1)
{
    loadWeightData();
}

QVariantList WeightManager::weightData() const {
    return m_weightData;
}

int WeightManager::profileId() const {
    return m_profileId;
}

void WeightManager::setProfileId(int id) {
    if (m_profileId != id) {
        m_profileId = id;
        emit profileIdChanged();
        loadWeightData();
    }
}

void WeightManager::loadWeightData() {
    QSqlQuery query;
    query.prepare("SELECT id, weight, measurementDate, note FROM WeightMeasurements "
                  "WHERE profileId = :profileId ORDER BY measurementDate ASC");
    query.bindValue(":profileId", m_profileId);

    if (!query.exec()) {
        qWarning() << "Failed to load weight data:" << query.lastError();
        return;
    }

    m_weightData.clear();
    while (query.next()) {
        QVariantMap measurement;
        measurement["id"] = query.value(0);
        measurement["weight"] = query.value(1);
        measurement["date"] = query.value(2).toDate();
        measurement["note"] = query.value(3);
        m_weightData.append(measurement);
    }
    emit weightDataChanged();
}

bool WeightManager::addWeightMeasurement(double weight, const QDate &date, const QString &note) {
    if (weight <= 0) return false;

    QSqlQuery query;
    query.prepare("INSERT INTO WeightMeasurements (profileId, weight, measurementDate, note) "
                  "VALUES (:profileId, :weight, :date, :note)");
    query.bindValue(":profileId", m_profileId);
    query.bindValue(":weight", weight);
    query.bindValue(":date", date);
    query.bindValue(":note", note);

    if (!query.exec()) {
        qWarning() << "Failed to add weight measurement:" << query.lastError();
        return false;
    }

    loadWeightData(); // Перезагружаем данные
    return true;
}

bool WeightManager::removeWeightMeasurement(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM WeightMeasurements WHERE id = :id AND profileId = :profileId");
    query.bindValue(":id", id);
    query.bindValue(":profileId", m_profileId);

    if (!query.exec()) {
        qWarning() << "Failed to remove weight measurement:" << query.lastError();
        return false;
    }

    // Обновляем данные после удаления
    loadWeightData();
    return true;
}
