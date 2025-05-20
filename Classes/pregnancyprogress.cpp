#include "pregnancyprogress.h"
#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDateTime>

PregnancyProgress::PregnancyProgress(QObject *parent)
    : QObject(parent), m_id(-1), m_profileId(-1), m_currentWeek(0)
{
    m_lastUpdated = QDate::currentDate();
}

PregnancyProgress::PregnancyProgress(int id, int profileId, const QDate &startDate,
                                     int currentWeek, const QDate &lastUpdated,
                                     QObject *parent)
    : QObject(parent), m_id(id), m_profileId(profileId),
    m_startDate(startDate), m_currentWeek(currentWeek),
    m_lastUpdated(lastUpdated)
{
}

// Getters implementation
int PregnancyProgress::id() const { return m_id; }
int PregnancyProgress::profileId() const { return m_profileId; }
QDate PregnancyProgress::startDate() const { return m_startDate; }
int PregnancyProgress::currentWeek() const { return m_currentWeek; }
QDate PregnancyProgress::lastUpdated() const { return m_lastUpdated; }

// Setters implementation
void PregnancyProgress::setProfileId(int profileId) {
    if (m_profileId != profileId) {
        m_profileId = profileId;
        emit profileIdChanged();
    }
}

void PregnancyProgress::setStartDate(const QDate &startDate) {
    if (m_startDate != startDate) {
        m_startDate = startDate;
        emit startDateChanged();
    }
}

void PregnancyProgress::setCurrentWeek(int currentWeek) {
    if (m_currentWeek != currentWeek) {
        m_currentWeek = currentWeek;
        emit currentWeekChanged();
    }
}

void PregnancyProgress::setId(int id) {
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void PregnancyProgress::setLastUpdated(const QDate &lastUpdated) {
    if (m_lastUpdated != lastUpdated) {
        m_lastUpdated = lastUpdated;
        emit lastUpdatedChanged();
    }
}

bool PregnancyProgress::loadData()
{
    if (m_profileId <= 0) {
        qWarning() << "Invalid profileId for loading data";
        return false;
    }

    PregnancyProgress* progress = PregnancyProgress::getProgressByProfile(m_profileId);
    if (progress) {
        m_id = progress->id();
        m_startDate = progress->startDate();
        m_currentWeek = progress->currentWeek();
        m_lastUpdated = progress->lastUpdated();

        progress->deleteLater();
        emit dataLoaded();
        return true;
    }

    // Если данные не найдены, инициализируем пустые значения
    m_id = -1;
    m_startDate = QDate();
    m_currentWeek = 0;
    m_lastUpdated = QDate::currentDate();

    return false;
}

// Database operations
bool PregnancyProgress::save()
{
    QSqlQuery query;

    if (m_id == -1) {
        // Insert new record
        query.prepare("INSERT INTO PregnancyProgress (profileId, startDate, currentWeek, lastUpdated) "
                      "VALUES (:profileId, :startDate, :currentWeek, :lastUpdated)");
    } else {
        // Update existing record
        query.prepare("UPDATE PregnancyProgress SET "
                      "profileId = :profileId, "
                      "startDate = :startDate, "
                      "currentWeek = :currentWeek, "
                      "lastUpdated = :lastUpdated "
                      "WHERE id = :id");
        query.bindValue(":id", m_id);
    }

    query.bindValue(":profileId", m_profileId);
    query.bindValue(":startDate", m_startDate);
    query.bindValue(":currentWeek", m_currentWeek);
    query.bindValue(":lastUpdated", m_lastUpdated);

    if (!query.exec()) {
        qWarning() << "Failed to save pregnancy progress:" << query.lastError().text();
        return false;
    }

    if (m_id == -1) {
        m_id = query.lastInsertId().toInt();
    }

    emit dataLoaded();
    return true;
}

bool PregnancyProgress::remove()
{
    if (m_id == -1) {
        return false;
    }

    QSqlQuery query;
    query.prepare("DELETE FROM PregnancyProgress WHERE id = :id");
    query.bindValue(":id", m_id);

    if (!query.exec()) {
        qWarning() << "Failed to remove pregnancy progress:" << query.lastError().text();
        return false;
    }

    return true;
}

PregnancyProgress* PregnancyProgress::getProgress(int id)
{
    QSqlQuery query;
    query.prepare("SELECT * FROM PregnancyProgress WHERE id = :id");
    query.bindValue(":id", id);

    if (!query.exec()) {
        qWarning() << "Failed to get pregnancy progress:" << query.lastError().text();
        return nullptr;
    }

    if (query.next()) {
        return new PregnancyProgress(
            query.value("id").toInt(),
            query.value("profileId").toInt(),
            query.value("startDate").toDate(),
            query.value("currentWeek").toInt(),
            query.value("lastUpdated").toDate()
            );
    }

    return nullptr;
}

PregnancyProgress* PregnancyProgress::getProgressByProfile(int profileId)
{
    QSqlQuery query;
    query.prepare("SELECT * FROM PregnancyProgress WHERE profileId = :profileId");
    query.bindValue(":profileId", profileId);

    if (!query.exec()) {
        qWarning() << "Failed to get pregnancy progress by profile:" << query.lastError().text();
        return nullptr;
    }

    if (query.next()) {
        return new PregnancyProgress(
            query.value("id").toInt(),
            query.value("profileId").toInt(),
            query.value("startDate").toDate(),
            query.value("currentWeek").toInt(),
            query.value("lastUpdated").toDate()
            );
    }

    return nullptr;
}

QList<PregnancyProgress*> PregnancyProgress::getAllProgress()
{
    QList<PregnancyProgress*> progressList;
    QSqlQuery query("SELECT * FROM PregnancyProgress");

    while (query.next()) {
        progressList.append(new PregnancyProgress(
            query.value("id").toInt(),
            query.value("profileId").toInt(),
            query.value("startDate").toDate(),
            query.value("currentWeek").toInt(),
            query.value("lastUpdated").toDate()
            ));
    }

    return progressList;
}

bool PregnancyProgress::updateCurrentWeek(int newWeek)
{
    if (m_currentWeek == newWeek) {
        return true;
    }

    m_currentWeek = newWeek;
    m_lastUpdated = QDate::currentDate();

    QSqlQuery query;
    query.prepare("UPDATE PregnancyProgress SET "
                  "currentWeek = :currentWeek, "
                  "lastUpdated = :lastUpdated "
                  "WHERE id = :id");
    query.bindValue(":currentWeek", m_currentWeek);
    query.bindValue(":lastUpdated", m_lastUpdated);
    query.bindValue(":id", m_id);

    if (!query.exec()) {
        qWarning() << "Failed to update current week:" << query.lastError().text();
        return false;
    }

    emit currentWeekChanged();
    emit lastUpdatedChanged();
    emit dataLoaded();
    return true;
}

bool PregnancyProgress::updateLastUpdated()
{
    m_lastUpdated = QDate::currentDate();

    QSqlQuery query;
    query.prepare("UPDATE PregnancyProgress SET "
                  "lastUpdated = :lastUpdated "
                  "WHERE id = :id");
    query.bindValue(":lastUpdated", m_lastUpdated);
    query.bindValue(":id", m_id);

    if (!query.exec()) {
        qWarning() << "Failed to update last updated date:" << query.lastError().text();
        return false;
    }

    emit lastUpdatedChanged();
    emit dataLoaded();
    return true;
}

// Helper methods
int PregnancyProgress::calculateCurrentWeek() const
{
    if (!m_startDate.isValid()) {
        return 0;
    }

    int days = m_startDate.daysTo(QDate::currentDate());
    if (days < 0) {
        return 0;
    }

    return (days / 7) + 1; // +1 потому что первая неделя начинается с 1 дня
}

bool PregnancyProgress::isDataValid() const
{
    return m_profileId > 0 && m_startDate.isValid() && m_currentWeek > 0 && m_lastUpdated.isValid();
}
