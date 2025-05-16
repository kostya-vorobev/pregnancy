#ifndef DATABASEHANDLER_H
#define DATABASEHANDLER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QTimer>
#include <QVariantMap>
#include <QDate>

class DatabaseHandler : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseHandler(QObject *parent = nullptr);
    ~DatabaseHandler();
    Q_INVOKABLE QVariantMap getWeekInfo(int week);
    Q_INVOKABLE bool updateCurrentWeek(int profileId, int week);
    Q_PROPERTY(bool initialized READ isInitialized NOTIFY initializedChanged)
    Q_INVOKABLE bool savePregnancyData(int profileId, int currentWeek, const QDate &startDate = QDate::currentDate());
    Q_INVOKABLE int getCurrentWeek(int profileId);
    Q_INVOKABLE QDate getPregnancyStartDate(int profileId);
    Q_INVOKABLE bool initializeDatabase();
    Q_INVOKABLE bool savePersonalData(int profileId,
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
                                                       double weightGainGoal);
    bool isInitialized() const;
    QVariantMap getHomeScreenData(int profileId);
    void scheduleBackups(int intervalHours = 24);
signals:
    void initializedChanged(bool initialized);
private slots:
    void createScheduledBackup();

private:
    // Database operations
    bool createPregnancyProgressIfNotExists(int profileId);
    bool openDatabase();
    bool validateDatabase() const;
    bool repairDatabase();
    bool initializePaths();
    bool initializeTimer();
    bool populateInitialWeekData();
    // Utility methods
    bool executeQuery(QSqlQuery &query, const QString &errorMessage);
    bool tableExists(const QString &tableName);

    QSqlDatabase m_db;
    QString m_dbPath;
    QTimer *m_backupTimer = nullptr;
};

#endif // DATABASEHANDLER_H
