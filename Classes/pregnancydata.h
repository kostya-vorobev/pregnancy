#ifndef PREGNANCYDATA_H
#define PREGNANCYDATA_H

#include <QObject>
#include <QVariantMap>
#include <QCoreApplication>

class PregnancyData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int currentWeek READ currentWeek WRITE setCurrentWeek NOTIFY currentWeekChanged)
    Q_PROPERTY(QString babySize READ babySize NOTIFY babySizeChanged)
    Q_PROPERTY(QString babySizeImage READ babySizeImage NOTIFY babySizeImageChanged)
    Q_PROPERTY(QString dailyTip READ dailyTip NOTIFY dailyTipChanged)
    Q_PROPERTY(QString baby3dModel READ baby3dModel NOTIFY baby3dModelChanged)

public:
    explicit PregnancyData(QObject *parent = nullptr);

    int currentWeek() const;
    QString babySize() const;
    QString babySizeImage() const;
    QString dailyTip() const;
    QString baby3dModel() const;

public slots:
    void setCurrentWeek(int week);
    void loadData(int profileId);

signals:
    void currentWeekChanged(int currentWeek);
    void babySizeChanged(QString babySize);
    void babySizeImageChanged(QString babySizeImage);
    void dailyTipChanged(QString dailyTip);
    void baby3dModelChanged(QString baby3dModel);

private:
    int m_currentWeek;
    QString m_babySize;
    QString m_babySizeImage;
    QString m_dailyTip;
    QString m_baby3dModel;
};

#endif // PREGNANCYDATA_H
