#include "databasehandler.h"
#include "databasehandler.h"
#include "backupmanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QDateTime>
#include <QSqlError>

DatabaseHandler::DatabaseHandler(QObject *parent) : QObject(parent)
{
    initializePaths();
    initializeTimer();
}

DatabaseHandler::~DatabaseHandler()
{
    if (m_backupTimer) {
        m_backupTimer->stop();
        delete m_backupTimer;
    }
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseHandler::initializePaths()
{
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(appDataPath);
    if (!dir.exists() && !dir.mkpath(appDataPath)) {
        qCritical() << "Failed to create application data directory";
        return false;
    }
    m_dbPath = appDataPath + "/pregnancy_app.db";
    return true;
}

bool DatabaseHandler::initializeTimer()
{
    if (!m_backupTimer) {
        m_backupTimer = new QTimer(this);
        connect(m_backupTimer, &QTimer::timeout, this, &DatabaseHandler::createScheduledBackup);
    }
    return true;
}

bool DatabaseHandler::initializeDatabase()
{
    if (m_db.isOpen()) {
        return true;
    }

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_dbPath);

    if (!m_db.open()) {
        qCritical() << "Failed to open database:" << m_db.lastError();
        return false;
    }

    return true;
}

bool DatabaseHandler::openDatabase()
{
    if (m_db.isOpen()) {
        return true;
    }

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_dbPath);

    if (!m_db.open()) {
        qCritical() << "Failed to open database:" << m_db.lastError();
        return false;
    }

    // Enable foreign keys and other pragmas
    QSqlQuery pragmaQuery;
    if (!pragmaQuery.exec("PRAGMA foreign_keys = ON")) {
        qWarning() << "Failed to enable foreign keys:" << pragmaQuery.lastError();
    }
    if (!pragmaQuery.exec("PRAGMA journal_mode = WAL")) {
        qWarning() << "Failed to set journal mode:" << pragmaQuery.lastError();
    }

    return true;
}

bool DatabaseHandler::validateDatabase() const
{
    try {
        const QStringList requiredTables = {
            "Profile", "PregnancyWeeks", "DailyTips", "PregnancyProgress"
        };

        foreach (const QString &table, requiredTables) {
            QSqlQuery query(m_db);
            if (!query.exec(QString("SELECT 1 FROM %1 LIMIT 1").arg(table))) {
                qWarning() << "Table validation failed for:" << table;
                return false;
            }
        }
        return true;
    } catch (const std::exception &e) {
        qCritical() << "Database validation error:" << e.what();
        return false;
    }
}

bool DatabaseHandler::tableExists(const QString &tableName)
{
    QSqlQuery query;
    query.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name=?");
    query.addBindValue(tableName);
    return query.exec() && query.next();
}

bool DatabaseHandler::repairDatabase()
{
    BackupManager backupManager;

    if (m_db.isOpen()) {
        m_db.close();
    }

    if (QFile::exists(m_dbPath) && !QFile::remove(m_dbPath)) {
        qCritical() << "Failed to remove corrupted database";
        return false;
    }

    if (!backupManager.restoreFromBackup(backupManager.getDefaultBackupPath(), m_dbPath)) {
        qCritical() << "Failed to restore from backup";
        return false;
    }

    return openDatabase() && validateDatabase();
}

bool DatabaseHandler::executeQuery(QSqlQuery &query, const QString &errorMessage)
{
    if (!query.exec()) {
        qWarning() << errorMessage << ":" << query.lastError();
        return false;
    }
    return true;
}

QVariantMap DatabaseHandler::getHomeScreenData(int profileId)
{
    QVariantMap result;

    // Получаем текущую неделю беременности
    QSqlQuery weekQuery;
    weekQuery.prepare("SELECT currentWeek FROM PregnancyProgress WHERE profileId = ?");
    weekQuery.addBindValue(profileId);

    if (!weekQuery.exec() || !weekQuery.next()) {
        qWarning() << "Failed to get current week:" << weekQuery.lastError();
        return result;
    }

    int currentWeek = weekQuery.value(0).toInt();
    result["currentWeek"] = currentWeek;

    // Получаем информацию о текущей неделе
    QSqlQuery weekInfoQuery;
    weekInfoQuery.prepare("SELECT babySize, babySizeImage FROM PregnancyWeeks WHERE weekNumber = ?");
    weekInfoQuery.addBindValue(currentWeek);

    if (weekInfoQuery.exec() && weekInfoQuery.next()) {
        result["babySize"] = weekInfoQuery.value(0).toString();
        result["babySizeImage"] = weekInfoQuery.value(1).toString();
    } else {
        qWarning() << "Failed to get week info:" << weekInfoQuery.lastError();
    }

    // Получаем случайный совет дня
    QSqlQuery tipQuery;
    int trimester = currentWeek / 13 + 1; // 1-3 триместр
    tipQuery.prepare("SELECT tipText FROM DailyTips WHERE forTrimester = ? OR forTrimester IS NULL ORDER BY RANDOM() LIMIT 1");
    tipQuery.addBindValue(trimester);

    if (tipQuery.exec() && tipQuery.next()) {
        result["dailyTip"] = tipQuery.value(0).toString();
    } else {
        result["dailyTip"] = "Сегодня хороший день, чтобы отдохнуть и позаботиться о себе.";
    }

    return result;
}

void DatabaseHandler::scheduleBackups(int intervalHours)
{
    if (!m_backupTimer) {
        if (!initializeTimer()) {
            qWarning() << "Failed to initialize backup timer";
            return;
        }
    }

    // Проверяем допустимость интервала
    if (intervalHours <= 0) {
        qWarning() << "Invalid backup interval:" << intervalHours << "hours";
        return;
    }

    int intervalMs = intervalHours * 60 * 60 * 1000;
    if (intervalMs <= 0) { // Проверка на переполнение
        qWarning() << "Interval calculation overflow, using default 24 hours";
        intervalMs = 24 * 60 * 60 * 1000;
    }

    m_backupTimer->start(intervalMs);
    qDebug() << "Backup scheduler started with interval:" << intervalHours << "hours";
}

void DatabaseHandler::createScheduledBackup()
{
    if (!m_db.isOpen()) {
        qWarning() << "Database is not open, cannot create backup";
        return;
    }

    BackupManager backupManager;
    QString dbPath = backupManager.getDefaultDatabasePath();
    QString backupPath = backupManager.getDefaultBackupPath();

    qDebug() << "Attempting to create scheduled backup...";
    if (!backupManager.createBackup(dbPath, backupPath)) {
        qWarning() << "Failed to create scheduled backup";
    } else {
        qDebug() << "Backup created successfully at" << QDateTime::currentDateTime().toString();
    }
}

QVariantMap DatabaseHandler::getWeekInfo(int week)
{
    QVariantMap result;

    if (!m_db.isOpen()) {
        qWarning() << "Database is not open";
        return result;
    }

    QSqlQuery query;
    query.prepare("SELECT babySize, babySizeImage, babyLength, babyWeight, developmentDescription, baby3dModel "
                  "FROM PregnancyWeeks WHERE weekNumber = ?");
    query.addBindValue(week);

    if (!query.exec()) {
        qWarning() << "Failed to execute week info query:" << query.lastError();
        return result;
    }

    if (query.next()) {
        result["babySize"] = query.value(0).toString();
        result["babySizeImage"] = query.value(1).toString();
        result["babyLength"] = query.value(2).toDouble();
        result["babyWeight"] = query.value(3).toDouble();
        result["description"] = query.value(4).toString();
        result["baby3dModel"] = query.value(4).toString();
    } else {
        qWarning() << "No data for week" << week;
    }

    return result;
}

bool DatabaseHandler::updateCurrentWeek(int profileId, int week)
{
    if (!m_db.isOpen()) {
        qWarning() << "Database is not open";
        return false;
    }

    QSqlQuery query;
    query.prepare("UPDATE PregnancyProgress SET currentWeek = ?, lastUpdated = datetime('now') "
                  "WHERE profileId = ?");
    query.addBindValue(week);
    query.addBindValue(profileId);

    if (!query.exec()) {
        qWarning() << "Failed to update week:" << query.lastError()
        << "Executed SQL:" << query.lastQuery();
        return false;
    }

    qDebug() << "Successfully updated week to" << week << "for profile" << profileId;
    return true;
}

bool DatabaseHandler::populateInitialWeekData()
{
    QSqlQuery checkQuery("SELECT COUNT(*) FROM PregnancyWeeks");
    if (checkQuery.next() && checkQuery.value(0).toInt() == 0) {
        QFile sqlFile(":/database/initial_backup.sql");
        if (!sqlFile.open(QIODevice::ReadOnly)) {
            qWarning() << "Failed to open SQL file";
            return false;
        }

        QStringList sqlCommands = QString(sqlFile.readAll()).split(';');
        QSqlQuery query;

        foreach (const QString &sqlCommand, sqlCommands) {
            QString trimmedCmd = sqlCommand.trimmed();
            if (!trimmedCmd.isEmpty()) {
                if (!query.exec(trimmedCmd)) {
                    qWarning() << "Failed to execute SQL:" << query.lastError();
                    return false;
                }
            }
        }

        qDebug() << "Initial week data populated successfully";
    }
    return true;
}
bool DatabaseHandler::isInitialized() const
{
    if (!m_db.isValid() || !m_db.isOpen()) {
        return false;
    }
    return validateDatabase();
}

bool DatabaseHandler::savePregnancyData(int profileId, int currentWeek, const QDate &startDate)
{
    if (!m_db.isOpen()) {
        qWarning() << "Database is not open";
        return false;
    }

    // Проверяем существует ли уже запись для этого профиля
    QSqlQuery checkQuery;
    checkQuery.prepare("SELECT 1 FROM PregnancyProgress WHERE profileId = ?");
    checkQuery.addBindValue(profileId);

    if (!checkQuery.exec()) {
        qWarning() << "Failed to check pregnancy progress:" << checkQuery.lastError();
        return false;
    }

    QSqlQuery query;
    if (checkQuery.next()) {
        // Обновляем существующую запись
        query.prepare("UPDATE PregnancyProgress SET currentWeek = ?, lastUpdated = DATE('now') "
                      "WHERE profileId = ?");
        query.addBindValue(currentWeek);
        query.addBindValue(profileId);
    } else {
        // Создаем новую запись
        query.prepare("INSERT INTO PregnancyProgress (profileId, startDate, currentWeek, lastUpdated) "
                      "VALUES (?, ?, ?, DATE('now'))");
        query.addBindValue(profileId);
        query.addBindValue(startDate.toString(Qt::ISODate));
        query.addBindValue(currentWeek);
    }

    if (!query.exec()) {
        qWarning() << "Failed to save pregnancy data:" << query.lastError();
        return false;
    }

    return true;
}

int DatabaseHandler::getCurrentWeek(int profileId)
{
    QSqlQuery query;
    query.prepare("SELECT currentWeek FROM PregnancyProgress WHERE profileId = ?");
    query.addBindValue(profileId);

    if (!query.exec() || !query.next()) {
        qWarning() << "Failed to get current week:" << query.lastError();
        return 1; // Возвращаем неделю по умолчанию
    }

    return query.value(0).toInt();
}

QDate DatabaseHandler::getPregnancyStartDate(int profileId)
{
    QSqlQuery query;
    query.prepare("SELECT startDate FROM PregnancyProgress WHERE profileId = ?");
    query.addBindValue(profileId);

    if (!query.exec() || !query.next()) {
        qWarning() << "Failed to get start date:" << query.lastError();
        return QDate::currentDate(); // Возвращаем текущую дату по умолчанию
    }

    return QDate::fromString(query.value(0).toString(), Qt::ISODate);
}

bool DatabaseHandler::savePersonalData(int profileId,
                                       const QString &firstName,
                                       const QString &lastName,
                                       const QString &middleName,
                                       const QDate &dateBirth,
                                       int gestationalAge,
                                       int height,
                                       double weight,
                                       const QString &bloodType,
                                       double initialWeight,
                                       double prePregnancyWeight,
                                       double weightGainGoal)
{
    if (!m_db.isOpen() && !openDatabase()) {
        qWarning() << "Database is not open";
        return false;
    }


    m_db.transaction();

    try {
        // Рассчитываем estimatedDate (дата родов)
        QDate estimatedDate = dateBirth.addDays(280); // 40 недель

        QSqlQuery query;
        query.prepare(
            "INSERT OR REPLACE INTO Profile ("
            "id, firstName, lastName, middleName, dateBirth, gestationalAge, "
            "estimatedDate, height, weight, bloodType, initialWeight, "
            "prePregnancyWeight, weightGainGoal"
            ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
            );

        query.addBindValue(profileId);
        query.addBindValue(firstName);
        query.addBindValue(lastName);
        query.addBindValue(middleName);
        query.addBindValue(dateBirth.toString(Qt::ISODate));
        query.addBindValue(gestationalAge);
        query.addBindValue(estimatedDate.toString(Qt::ISODate));
        query.addBindValue(height);
        query.addBindValue(weight);
        query.addBindValue(bloodType);
        query.addBindValue(initialWeight);
        query.addBindValue(prePregnancyWeight);
        query.addBindValue(weightGainGoal);

        if (!query.exec()) {
            throw std::runtime_error(
                QString("Failed to execute query: %1").arg(query.lastError().text()).toStdString()
                );
        }

        m_db.commit();
        qDebug() << "Profile data saved successfully";
        return true;

    } catch (const std::exception &e) {
        m_db.rollback();
        qCritical() << "Error saving profile data:" << e.what();
        return false;
    }
}
