// fetalkickmanager.cpp
#include "fetalkickmanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>

FetalKickManager::FetalKickManager(QObject *parent) : QObject(parent), m_profileId(1)
{
    loadKickHistory();
}

QVariantList FetalKickManager::kickHistory() const {
    return m_kickHistory;
}

int FetalKickManager::profileId() const {
    return m_profileId;
}

void FetalKickManager::setProfileId(int id) {
    if (m_profileId != id) {
        m_profileId = id;
        emit profileIdChanged();
        loadKickHistory();
    }
}

void FetalKickManager::loadKickHistory() {
    QSqlQuery query;
    query.prepare("SELECT id, sessionDate, startTime, kickCount, durationMinutes, notes "
                  "FROM FetalKicks WHERE profileId = :profileId "
                  "ORDER BY sessionDate DESC, startTime DESC LIMIT 50");
    query.bindValue(":profileId", m_profileId);

    if (!query.exec()) {
        qWarning() << "Failed to load kick history:" << query.lastError();
        return;
    }

    m_kickHistory.clear();
    while (query.next()) {
        QVariantMap session;
        session["id"] = query.value(0);
        session["date"] = query.value(1).toDate().toString("dd.MM.yyyy");
        session["time"] = query.value(2).toTime().toString("hh:mm");
        session["count"] = query.value(3);
        session["duration"] = query.value(4);
        session["notes"] = query.value(5).toString();
        session["saved"] = true;  // Все записи из БД считаем сохраненными
        m_kickHistory.append(session);
    }
    emit kickHistoryChanged();
}

void FetalKickManager::saveKickSession(int kickCount, const QString &notes) {
    if (kickCount <= 0) return;

    QDateTime now = QDateTime::currentDateTime();

    QSqlQuery query;
    query.prepare("INSERT INTO FetalKicks (profileId, sessionDate, startTime, kickCount, notes, isCompleted) "
                  "VALUES (:profileId, :date, :time, :count, :notes, TRUE)");
    query.bindValue(":profileId", m_profileId);
    query.bindValue(":date", now.date());
    query.bindValue(":time", now.time());
    query.bindValue(":count", kickCount);
    query.bindValue(":notes", notes);

    if (!query.exec()) {
        qWarning() << "Failed to save kick session:" << query.lastError();
        return;
    }

    loadKickHistory(); // Обновляем историю
}

void FetalKickManager::deleteKickSession(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM FetalKicks WHERE id = :id AND profileId = :profileId");
    query.bindValue(":id", id);
    query.bindValue(":profileId", m_profileId);

    if (!query.exec()) {
        qWarning() << "Failed to delete kick session:" << query.lastError();
        return;
    }

    loadKickHistory(); // Обновляем историю
}
