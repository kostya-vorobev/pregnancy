#ifndef NOTIFICATIONMANAGER_H
#define NOTIFICATIONMANAGER_H

#include <QObject>
#include <QTime>
#include <QDate>
#include <QVariantMap>
#include <QVector>
#include "databasemanager.h"
class QSqlDatabase;

class NotificationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QTime notificationTime READ notificationTime NOTIFY settingsChanged)
    Q_PROPERTY(bool notificationsEnabled READ notificationsEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool soundEnabled READ soundEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool vibrationEnabled READ vibrationEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool vitaminsEnabled READ vitaminsEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool doctorVisitsEnabled READ doctorVisitsEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool weightMeasurementsEnabled READ weightMeasurementsEnabled NOTIFY settingsChanged)

public:
    explicit NotificationManager(QObject *parent = nullptr);

    // Настройки уведомлений
    Q_INVOKABLE void saveSettings(const QTime &time, bool enabled, bool sound, bool vibration,
                                  bool vitamins, bool doctorVisits, bool weightMeasurements);
    QTime notificationTime() const;
    bool notificationsEnabled() const;
    bool soundEnabled() const;
    bool vibrationEnabled() const;
    bool vitaminsEnabled() const;
    bool doctorVisitsEnabled() const;
    bool weightMeasurementsEnabled() const;

    // Работа с задачами
    Q_INVOKABLE QVector<QVariantMap> getPendingTasks() const;
    Q_INVOKABLE bool markTaskAsNotified(int taskId);
    Q_INVOKABLE void scheduleAllNotifications();
    Q_INVOKABLE void schedulePlatformNotification(const QString &type, const QString &title,
                                                           const QString &message, const QDateTime &when);

    Q_INVOKABLE void scheduleDailyNotifications();

    // Проверка задач для уведомлений
    Q_INVOKABLE void checkTasksForNotifications();
    Q_INVOKABLE void initializeNotificationChannels();

signals:
    void settingsChanged();
    void notificationTriggered(const QString &title, const QString &message);

private:
    void ensureTablesExist();
    void scheduleTaskNotification(const QVariantMap &task);
    void scheduleDailyNotification(const QString &type, const QString &title, const QString &message);
    DatabaseManager& m_db;
};

#endif // NOTIFICATIONMANAGER_H
