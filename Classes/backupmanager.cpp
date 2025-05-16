#include "backupmanager.h"

BackupManager::BackupManager(QObject *parent) : QObject(parent)
{
}

bool BackupManager::checkDatabaseExists(const QString &dbPath)
{
    return QFile::exists(dbPath);
}

bool BackupManager::restoreFromBackup(const QString &backupPath, const QString &dbPath)
{
    // Сначала проверяем существование пользовательского бэкапа
    if (QFile::exists(backupPath)) {
        return copyFile(backupPath, dbPath);
    }

    // Если пользовательского бэкапа нет, пробуем восстановить из ресурсов
    QString resourceBackup = ":/database/initial_backup.db";
    if (QFile::exists(resourceBackup)) {
        return copyFile(resourceBackup, dbPath);
    }

    qWarning() << "No backup files found";
    return false;
}

bool BackupManager::createBackup(const QString &dbPath, const QString &backupPath)
{
    if (dbPath.isEmpty() || backupPath.isEmpty()) {
        qWarning() << "Empty path provided for backup";
        return false;
    }

    if (!QFile::exists(dbPath)) {
        qWarning() << "Database file does not exist:" << dbPath;
        return false;
    }

    QFileInfo backupInfo(backupPath);
    QDir backupDir(backupInfo.absolutePath());

    if (!backupDir.exists() && !backupDir.mkpath(".")) {
        qWarning() << "Failed to create backup directory:" << backupDir.path();
        return false;
    }

    // Удаляем старый бэкап, если он существует
    if (QFile::exists(backupPath) && !QFile::remove(backupPath)) {
        qWarning() << "Failed to remove existing backup file:" << backupPath;
        return false;
    }

    // Создаем временную копию для безопасности
    QString tempBackupPath = backupPath + ".tmp";
    if (!QFile::copy(dbPath, tempBackupPath)) {
        qWarning() << "Failed to create temporary backup copy";
        return false;
    }

    // Переименовываем временный файл в окончательный
    if (!QFile::rename(tempBackupPath, backupPath)) {
        qWarning() << "Failed to rename temporary backup file";
        QFile::remove(tempBackupPath); // Очистка
        return false;
    }

    qDebug() << "Backup created successfully:" << backupPath;
    return true;
}

bool BackupManager::copyFile(const QString &source, const QString &destination)
{
    if (QFile::exists(destination)) {
        if (!QFile::remove(destination)) {
            qWarning() << "Failed to remove existing file:" << destination;
            return false;
        }
    }

    return QFile::copy(source, destination);
}

QString BackupManager::getDefaultBackupPath()
{
    QString backupDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/backups";
    QDir().mkpath(backupDir);
    return backupDir + "/pregnancy_app_backup.db";
}

QString BackupManager::getDefaultDatabasePath()
{
    QString dbDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dbDir);
    return dbDir + "/pregnancy_app.db";
}
