// dbmanager.h
#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QSqlQuery>
#include <QDebug>
#include <QCoreApplication>

class DatabaseManager : public QObject
{
    Q_OBJECT

public:
    static DatabaseManager& instance();
    bool initialize(const QString &databaseName = "pregnancy.db");
    QSqlDatabase database() const;
    bool executeSqlFile(const QString &filePath);

protected:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

private:
    QSqlDatabase m_db;
    QString m_databasePath;
    bool createTables();
    bool insertInitialData();
};

#endif // DBMANAGER_H
