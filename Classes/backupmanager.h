#ifndef BACKUPMANAGER_H
#define BACKUPMANAGER_H

#include <QObject>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

class BackupManager : public QObject
{
    Q_OBJECT
public:
    explicit BackupManager(QObject *parent = nullptr);

    bool checkDatabaseExists(const QString &dbPath);
    bool restoreFromBackup(const QString &backupPath, const QString &dbPath);
    bool createBackup(const QString &dbPath, const QString &backupPath);
    QString getDefaultBackupPath();
    QString getDefaultDatabasePath();

private:
    bool copyFile(const QString &source, const QString &destination);
};

#endif // BACKUPMANAGER_H
