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
                                     int currentWeek, const QDate &lastUpdated, const QDate &estimatedDueDate,
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

void PregnancyProgress::calculateStartDateFromWeek(int week) {
    if (week <= 0) return;

    QDate newStartDate = QDate::currentDate().addDays(-7 * week);
    setStartDate(newStartDate);

    // Рассчитываем предполагаемую дату родов (40 недель от новой даты начала)
    emit estimatedDueDateChanged();
}

QDate PregnancyProgress::estimatedDueDate() const {
    if (!m_startDate.isValid()) return QDate();

    // Беременность длится примерно 40 недель
    return m_startDate.addDays(40 * 7);
}

QDate PregnancyProgress::calculateDueDate() const {
    return estimatedDueDate();
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
        m_estimatedDueDate = progress->estimatedDueDate();

        progress->deleteLater();
        emit dataLoaded();
        return true;
    }

    // Если данные не найдены, инициализируем пустые значения
    m_id = -1;
    m_startDate = QDate();
    m_currentWeek = 0;
    m_lastUpdated = QDate::currentDate();
    m_estimatedDueDate = QDate();

    return false;
}

// Database operations
bool PregnancyProgress::save() {
    if (!isDataValid()) {
        qWarning() << "Invalid pregnancy data, cannot save";
        return false;
    }

    QSqlQuery query;
    QDate dueDate = calculateDueDate();
    QDate currentDate = QDate::currentDate();

    // Для отладки
    qDebug() << "Attempting to save pregnancy data:";
    qDebug() << "ID:" << m_id;
    qDebug() << "Profile ID:" << m_profileId;
    qDebug() << "Start Date:" << m_startDate;
    qDebug() << "Current Week:" << m_currentWeek;
    qDebug() << "Due Date:" << dueDate;

    if (m_id == -1) {
        // INSERT запрос
        if (!query.prepare("INSERT INTO PregnancyProgress "
                           "(profileId, startDate, currentWeek, lastUpdated, estimatedDueDate) "
                           "VALUES (:profileId, :startDate, :currentWeek, :lastUpdated, :estimatedDueDate)")) {
            qWarning() << "Prepare INSERT failed:" << query.lastError();
            return false;
        }

        query.bindValue(":profileId", m_profileId);
        query.bindValue(":startDate", m_startDate.toString(Qt::ISODate));
        query.bindValue(":currentWeek", m_currentWeek);
        query.bindValue(":lastUpdated", currentDate.toString(Qt::ISODate));
        query.bindValue(":estimatedDueDate", dueDate.toString(Qt::ISODate));
    } else {
        // UPDATE запрос
        if (!query.prepare("UPDATE PregnancyProgress SET "
                           "profileId = :profileId, "
                           "startDate = :startDate, "
                           "currentWeek = :currentWeek, "
                           "lastUpdated = :lastUpdated, "
                           "estimatedDueDate = :estimatedDueDate "
                           "WHERE id = :id")) {
            qWarning() << "Prepare UPDATE failed:" << query.lastError();
            return false;
        }

        query.bindValue(":profileId", m_profileId);
        query.bindValue(":startDate", m_startDate.toString(Qt::ISODate));
        query.bindValue(":currentWeek", m_currentWeek);
        query.bindValue(":lastUpdated", currentDate.toString(Qt::ISODate));
        query.bindValue(":estimatedDueDate", dueDate.toString(Qt::ISODate));
        query.bindValue(":id", m_id);
    }

    if (!query.exec()) {
        qWarning() << "Failed to execute query:" << query.lastError().text();
        qWarning() << "Query:" << query.lastQuery();
        qWarning() << "Bound values:" << query.boundValues();
        return false;
    }

    if (m_id == -1) {
        m_id = query.lastInsertId().toInt();
    }

    qDebug() << "Pregnancy data saved successfully";
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
            query.value("lastUpdated").toDate(),
            query.value("estimatedDueDate").toDate()
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
            query.value("lastUpdated").toDate(),
            query.value("estimatedDueDate").toDate()
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
            query.value("lastUpdated").toDate(),
            query.value("estimatedDueDate").toDate()
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
