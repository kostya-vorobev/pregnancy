#include "notificationmanager.h"
#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDateTime>
#include <QJniObject>
#include <QCoreApplication>

NotificationManager::NotificationManager(QObject *parent)
    : QObject(parent), m_db(DatabaseManager::instance())
{
    ensureTablesExist();
    initializeNotificationChannels();
}

void NotificationManager::initializeNotificationChannels()
{
#ifdef Q_OS_ANDROID
    QJniObject::callStaticMethod<void>(
        "com/yourcompany/yourpackage/NotificationHelper",
        "createNotificationChannel",
        "(Landroid/content/Context;)V",
        QNativeInterface::QAndroidApplication::context()
        );
#endif
}

void NotificationManager::saveSettings(const QTime &time, bool enabled, bool sound, bool vibration,
                                       bool vitamins, bool doctorVisits, bool weightMeasurements)
{
    QSqlQuery query;
    if (!query.prepare("UPDATE NotificationSettings SET "
                       "notificationTime = :time, "
                       "notificationsEnabled = :enabled, "
                       "soundEnabled = :sound, "
                       "vibrationEnabled = :vibration, "
                       "vitaminsEnabled = :vitamins, "
                       "doctorVisitsEnabled = :doctorVisits, "
                       "weightMeasurementsEnabled = :weightMeasurements "
                       "WHERE id = 1")) {
        qWarning() << "Prepare error:" << query.lastError();
        return;
    }

    query.bindValue(":time", time.toString("HH:mm"));
    query.bindValue(":enabled", enabled);
    query.bindValue(":sound", sound);
    query.bindValue(":vibration", vibration);
    query.bindValue(":vitamins", vitamins);
    query.bindValue(":doctorVisits", doctorVisits);
    query.bindValue(":weightMeasurements", weightMeasurements);

    if (!query.exec()) {
        qWarning() << "Failed to save notification settings:" << query.lastError();
        return;
    }

    emit settingsChanged();
    scheduleAllNotifications();
}

QTime NotificationManager::notificationTime() const
{
    QSqlQuery query("SELECT notificationTime FROM NotificationSettings WHERE id = 1");
    return query.next() ? QTime::fromString(query.value(0).toString(), "HH:mm") : QTime(9, 0);
}

bool NotificationManager::notificationsEnabled() const
{
    QSqlQuery query("SELECT notificationsEnabled FROM NotificationSettings WHERE id = 1");
    return query.next() ? query.value(0).toBool() : true;
}

bool NotificationManager::soundEnabled() const
{
    QSqlQuery query("SELECT soundEnabled FROM NotificationSettings WHERE id = 1");
    return query.next() ? query.value(0).toBool() : true;
}

bool NotificationManager::vibrationEnabled() const
{
    QSqlQuery query("SELECT vibrationEnabled FROM NotificationSettings WHERE id = 1");
    return query.next() ? query.value(0).toBool() : false;
}

bool NotificationManager::vitaminsEnabled() const
{
    QSqlQuery query("SELECT vitaminsEnabled FROM NotificationSettings WHERE id = 1");
    return query.next() ? query.value(0).toBool() : true;
}

bool NotificationManager::doctorVisitsEnabled() const
{
    QSqlQuery query("SELECT doctorVisitsEnabled FROM NotificationSettings WHERE id = 1");
    return query.next() ? query.value(0).toBool() : true;
}

bool NotificationManager::weightMeasurementsEnabled() const
{
    QSqlQuery query("SELECT weightMeasurementsEnabled FROM NotificationSettings WHERE id = 1");
    return query.next() ? query.value(0).toBool() : false;
}

void NotificationManager::ensureTablesExist()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        qCritical() << "Database is not open!";
        return;
    }

    db.transaction();

    QStringList tables = db.tables();
    if (!tables.contains("NotificationSettings")) {
        QSqlQuery query;
        if (!query.exec("CREATE TABLE NotificationSettings ("
                        "id INTEGER PRIMARY KEY CHECK (id = 1), "
                        "notificationTime TEXT NOT NULL DEFAULT '09:00', "
                        "notificationsEnabled BOOLEAN NOT NULL DEFAULT 1, "
                        "soundEnabled BOOLEAN NOT NULL DEFAULT 1, "
                        "vibrationEnabled BOOLEAN NOT NULL DEFAULT 0, "
                        "vitaminsEnabled BOOLEAN NOT NULL DEFAULT 1, "
                        "doctorVisitsEnabled BOOLEAN NOT NULL DEFAULT 1, "
                        "weightMeasurementsEnabled BOOLEAN NOT NULL DEFAULT 0)")) {
            qCritical() << "Failed to create NotificationSettings:" << query.lastError();
            db.rollback();
            return;
        }

        if (!query.exec("INSERT INTO NotificationSettings (id) VALUES (1)")) {
            qCritical() << "Failed to insert default settings:" << query.lastError();
            db.rollback();
            return;
        }
    }

    // Создаем остальные таблицы, если их нет
    QStringList createQueries = {
        "CREATE TABLE IF NOT EXISTS Tasks ("
        "id INTEGER PRIMARY KEY, "
        "title TEXT NOT NULL, "
        "dueDate TEXT, "
        "isCompleted BOOLEAN NOT NULL DEFAULT 0)",

        "CREATE TABLE IF NOT EXISTS TaskNotifications ("
        "taskId INTEGER PRIMARY KEY, "
        "notificationTime TEXT NOT NULL)"
    };

    QSqlQuery query;
    for (const QString &sql : createQueries) {
        if (!query.exec(sql)) {
            qCritical() << "Failed to execute query:" << query.lastError();
            db.rollback();
            return;
        }
    }

    if (!db.commit()) {
        qCritical() << "Failed to commit transaction:" << db.lastError();
    }
}

void NotificationManager::scheduleAllNotifications()
{
    if (!notificationsEnabled()) {
        qDebug() << "Notifications are disabled";
        return;
    }

    QVector<QVariantMap> tasks = getPendingTasks();
    for (const QVariantMap &task : tasks) {
        scheduleTaskNotification(task);
    }

    scheduleDailyNotifications();
}

void NotificationManager::scheduleDailyNotifications()
{
    struct NotificationConfig {
        bool enabled;
        QString type;
        QString title;
        QString message;
    };

    QVector<NotificationConfig> configs = {
        {vitaminsEnabled(), "vitamins", "Прием витаминов", "Не забудьте принять витамины сегодня"},
        {doctorVisitsEnabled(), "doctor", "Визит к врачу", "Проверьте запланированные визиты к врачу"},
        {weightMeasurementsEnabled(), "weight", "Измерение веса", "Не забудьте измерить вес сегодня"}
    };

    QDateTime now = QDateTime::currentDateTime();
    QDateTime notificationTime(now.date(), this->notificationTime());

    if (notificationTime < now) {
        notificationTime = notificationTime.addDays(1);
    }

    for (const auto &config : configs) {
        if (config.enabled) {
            qDebug() << "Scheduling" << config.type << "notification for" << notificationTime;
            schedulePlatformNotification(config.type, config.title, config.message, notificationTime);
        }
    }
}

void NotificationManager::schedulePlatformNotification(const QString &type, const QString &title,
                                                       const QString &message, const QDateTime &when)
{
#ifdef Q_OS_ANDROID
    try {
        QJniObject javaTitle = QJniObject::fromString(title);
        QJniObject javaMessage = QJniObject::fromString(message);
        QJniObject javaType = QJniObject::fromString(type);
        QJniObject javaTime = QJniObject::fromString(when.toString(Qt::ISODate));

        QJniObject::callStaticMethod<void>(
            "com/yourcompany/yourpackage/NotificationHelper",
            "scheduleNotification",
            "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)V",
            QNativeInterface::QAndroidApplication::context(),
            javaTitle.object<jstring>(),
            javaMessage.object<jstring>(),
            javaType.object<jstring>(),
            when.toMSecsSinceEpoch());
    } catch (...) {
        qWarning() << "Exception while scheduling notification";
    }
#else
    qDebug() << "Notification scheduled:" << title << "-" << message << "at" << when;
#endif
}

QVector<QVariantMap> NotificationManager::getPendingTasks() const
{
    QVector<QVariantMap> tasks;
    QSqlQuery query;

    // Исправленный запрос
    if (!query.prepare("SELECT id, title, dueDate FROM Tasks "
                       "WHERE isCompleted = 0 AND dueDate IS NOT NULL "
                       "AND (id NOT IN (SELECT taskId FROM TaskNotifications) OR "
                       "dueDate > (SELECT notificationTime FROM TaskNotifications WHERE taskId = Tasks.id LIMIT 1))"))
    {
        qWarning() << "Prepare error:" << query.lastError();
        return tasks;
    }

    if (!query.exec()) {
        qWarning() << "Failed to get pending tasks:" << query.lastError();
        return tasks;
    }

    while (query.next()) {
        QVariantMap task;
        task["id"] = query.value("id");
        task["title"] = query.value("title");
        task["dueDate"] = query.value("dueDate");
        tasks.append(task);
    }

    return tasks;
}

bool NotificationManager::markTaskAsNotified(int taskId)
{
    QSqlQuery query;
    if (!query.prepare("INSERT OR REPLACE INTO TaskNotifications (taskId, notificationTime) "
                       "VALUES (:taskId, datetime('now'))"))
    {
        qWarning() << "Prepare error:" << query.lastError();
        return false;
    }

    query.bindValue(":taskId", taskId);

    if (!query.exec()) {
        qWarning() << "Failed to mark task as notified:" << query.lastError();
        return false;
    }
    return true;
}

void NotificationManager::scheduleTaskNotification(const QVariantMap &task)
{
    QDateTime dueDate = QDateTime::fromString(task["dueDate"].toString(), Qt::ISODate);
    QTime notifyTime = notificationTime();

    // Устанавливаем время уведомления на указанное время в день выполнения задачи
    QDateTime notificationTime(dueDate.date(), notifyTime);

    // Если время уже прошло сегодня, переносим на завтра
    if (notificationTime < QDateTime::currentDateTime()) {
        notificationTime = notificationTime.addDays(1);
    }

#ifdef Q_OS_ANDROID
    try {
        QJniObject javaTitle = QJniObject::fromString(task["title"].toString());
        QJniObject javaMessage = QJniObject::fromString("Напоминание о задаче");
        QJniObject javaTime = QJniObject::fromString(notificationTime.toString(Qt::ISODate));

        QJniObject::callStaticMethod<void>(
            "com/yourcompany/yourpackage/NotificationHelper",
            "scheduleNotification",
            "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IJ)V",
            QNativeInterface::QAndroidApplication::context(),
            javaTitle.object<jstring>(),
            javaMessage.object<jstring>(),
            javaTime.object<jstring>(),
            task["id"].toInt(),
            notificationTime.toSecsSinceEpoch() * 1000); // Умножаем на 1000 для миллисекунд
    } catch (...) {
        qWarning() << "Exception while scheduling Android notification";
    }
#elif defined(Q_OS_IOS)
    // Реализация для iOS
    // Здесь должен быть Objective-C код для iOS уведомлений
#else
    // Реализация для десктопов (для тестирования)
    qDebug() << "Scheduling notification for task:" << task["title"].toString()
             << "at" << notificationTime.toString();
#endif

    markTaskAsNotified(task["id"].toInt());
}
void NotificationManager::checkTasksForNotifications()
{
    if (!notificationsEnabled()) return;

    QDateTime now = QDateTime::currentDateTime();
    QTime currentTime = now.time();
    QTime notifyTime = this->notificationTime();

    // Проверяем, наступило ли время уведомлений (±15 минут)
    if (qAbs(currentTime.msecsSinceStartOfDay() - notifyTime.msecsSinceStartOfDay()) > 15 * 60 * 1000) {
        return;
    }

    QVector<QVariantMap> tasks = getPendingTasks();
    for (const QVariantMap &task : tasks) {
        QDate dueDate = QDate::fromString(task["dueDate"].toString(), Qt::ISODate);
        if (dueDate <= now.date()) {
            emit notificationTriggered(
                task["title"].toString(),
                QString("Запланировано на %1").arg(dueDate.toString("dd.MM.yyyy")));

            markTaskAsNotified(task["id"].toInt());
        }
    }
}
