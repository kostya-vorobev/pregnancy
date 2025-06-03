#include "databasemanager.h"


DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent)
{

}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

DatabaseManager& DatabaseManager::instance()
{
    static DatabaseManager instance;
   /* if (!instance.recreateDatabase()) {
        qCritical() << "Failed to recreate database";
    }*/
    return instance;
}

bool DatabaseManager::initialize(const QString &databaseName)
{

    #if defined(Q_OS_ANDROID)
        m_databasePath =QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/" + databaseName;
    qDebug() << m_databasePath;
        QFile dbFile(m_databasePath);
        if (!dbFile.exists()) {
            qDebug() << "Database file does not exist, will be created";
        } else {
            qDebug() << "Database file exists, size:" << dbFile.size() << "bytes";
        }

    #else
        // Для desktop-версий используем отдельную папку рядом с исполняемым файлом
        m_databasePath = QCoreApplication::applicationDirPath() + "/data/" + databaseName;
        QDir().mkpath(QCoreApplication::applicationDirPath() + "/data");
    #endif




    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_databasePath);



    if (!m_db.open()) {
        qCritical() << "Cannot open database:" << m_db.lastError().text();
        return false;
    }

    // Проверяем, нужно ли создавать таблицы
    bool tablesExist = m_db.tables().contains("Profile");
    if (!tablesExist) {
        if (!createTables()) {
            qCritical() << "Failed to create tables";
            return false;
        }
        if (!insertInitialData()) {
            qCritical() << "Failed to insert initial data";
            return false;
        }
    }

    return true;
}

bool DatabaseManager::deleteDatabase()
{
    // Закрываем соединение перед удалением
    if (m_db.isOpen()) {
        m_db.close();
    }

    // Удаляем файл базы данных
    QFile dbFile(m_databasePath);
    if (dbFile.exists()) {
        if (!dbFile.remove()) {
            qCritical() << "Failed to delete database file:" << dbFile.errorString();
            return false;
        }
        qDebug() << "Database file deleted successfully";
    } else {
        qDebug() << "Database file does not exist, nothing to delete";
    }

    // Удаляем соединение
    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);

    return true;
}

bool DatabaseManager::recreateDatabase()
{
    // 1. Удаляем существующую базу
    if (!deleteDatabase()) {
        qCritical() << "Failed to delete old database";
        return false;
    }

    // 2. Создаем новое соединение
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(m_databasePath);

    // 3. Открываем новую базу
    if (!m_db.open()) {
        qCritical() << "Cannot open new database:" << m_db.lastError().text();
        return false;
    }

    // 4. Создаем таблицы
    if (!createTables()) {
        qCritical() << "Failed to create tables in new database";
        return false;
    }

    // 5. Вставляем начальные данные
    if (!insertInitialData()) {
        qCritical() << "Failed to insert initial data in new database";
        return false;
    }

    qDebug() << "Database recreated successfully";
    return true;
}


bool DatabaseManager::createTables()
{
    QFile sqlFile(":/database/initial_backup.sql");
    if (!sqlFile.open(QIODevice::ReadOnly)) {
        qCritical() << "Cannot open SQL file:" << sqlFile.errorString();
        return false;
    }

    QStringList sqlQueries = QString(sqlFile.readAll()).split(';', Qt::SkipEmptyParts);

    QSqlQuery query;
    for (const QString &sqlQuery : sqlQueries) {
        if (sqlQuery.trimmed().isEmpty()) continue;

        if (!query.exec(sqlQuery)) {
            qCritical() << "Failed to execute query:" << query.lastError().text();
            qCritical() << "Query:" << sqlQuery;
            return false;
        }
    }

    return true;
}

bool DatabaseManager::insertInitialData()
{
    QFile file(":/database/initial_backup.sql");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Не удалось открыть файл:" << "qrc:/database/initial_backup.sql";
        return false;
    }

    QTextStream in(&file);
    QString sqlScript = in.readAll();

    QSqlQuery query;
    // Разделение скрипта на отдельные команды, если нужно
    QStringList statements = sqlScript.split(';', Qt::SkipEmptyParts);
    m_db.transaction();

    for (const QString &statement : statements) {
        QString trimmedStmt = statement.trimmed();
        if (!trimmedStmt.isEmpty()) {
            if (!query.exec(trimmedStmt)) {
                qWarning() << "Ошибка выполнения SQL:" << query.lastError().text();
                qCritical() << "Failed statement:" << trimmedStmt;
                m_db.rollback();
                return false;
            }
        }
    }
    m_db.commit();
    return true;
}

bool DatabaseManager::executeSqlFile(const QString &filePath)
{
    QFile sqlFile(filePath);
    if (!sqlFile.open(QIODevice::ReadOnly)) {
        qCritical() << "Cannot open SQL file:" << sqlFile.errorString();
        return false;
    }

    QStringList sqlQueries = QString(sqlFile.readAll()).split(';', Qt::SkipEmptyParts);

    QSqlQuery query;
    for (const QString &sqlQuery : sqlQueries) {
        if (sqlQuery.trimmed().isEmpty()) continue;

        if (!query.exec(sqlQuery)) {
            qCritical() << "Failed to execute query:" << query.lastError().text();
            qCritical() << "Query:" << sqlQuery;
            return false;
        }
    }

    return true;
}

QSqlDatabase DatabaseManager::database() const
{
    return m_db;
}
