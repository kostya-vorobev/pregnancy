#ifndef PREGNANCYPROGRESS_H
#define PREGNANCYPROGRESS_H

#include <QObject>
#include <QDate>

class PregnancyProgress : public QObject
{
    Q_OBJECT
    // Добавляем Q_PROPERTY для всех свойств
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(int profileId READ profileId WRITE setProfileId NOTIFY profileIdChanged)
    Q_PROPERTY(QDate startDate READ startDate WRITE setStartDate NOTIFY startDateChanged)
    Q_PROPERTY(int currentWeek READ currentWeek WRITE setCurrentWeek NOTIFY currentWeekChanged)
    Q_PROPERTY(QDate lastUpdated READ lastUpdated WRITE setLastUpdated NOTIFY lastUpdatedChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY validityChanged)

public:
    Q_INVOKABLE bool loadData();
    explicit PregnancyProgress(QObject *parent = nullptr);
    PregnancyProgress(int id, int profileId, const QDate &startDate,
                      int currentWeek, const QDate &lastUpdated,
                      QObject *parent = nullptr);

    bool isValid() const { return m_profileId > 0 && m_startDate.isValid(); }

    // Getters
    int id() const;
    int profileId() const;
    QDate startDate() const;
    int currentWeek() const;
    QDate lastUpdated() const;

    // Setters
    void setId(int profileId);
    void setProfileId(int profileId);
    void setStartDate(const QDate &startDate);
    void setCurrentWeek(int currentWeek);
    void setLastUpdated(const QDate &lastUpdated);

    // Database operations
    Q_INVOKABLE bool save();
    bool remove();
    static PregnancyProgress* getProgress(int id);
    static PregnancyProgress* getProgressByProfile(int profileId);
    static QList<PregnancyProgress*> getAllProgress();
    Q_INVOKABLE bool updateCurrentWeek(int newWeek);
    bool updateLastUpdated();

    // Helper methods
    Q_INVOKABLE int calculateCurrentWeek() const;
    Q_INVOKABLE bool isDataValid() const;

signals:
    void idChanged();
    void profileIdChanged();
    void startDateChanged();
    void currentWeekChanged();
    void lastUpdatedChanged();
    void validityChanged();
    void dataLoaded();

private:
    int m_id;
    int m_profileId;
    QDate m_startDate;
    int m_currentWeek;
    QDate m_lastUpdated;
};

#endif // PREGNANCYPROGRESS_H
