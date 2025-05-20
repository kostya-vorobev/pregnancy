// pregnancyweek.h
#ifndef PREGNANCYWEEK_H
#define PREGNANCYWEEK_H

#include <QObject>

class PregnancyWeek : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int weekNumber READ weekNumber WRITE setWeekNumber NOTIFY weekNumberChanged)
    Q_PROPERTY(QString babySize READ babySize NOTIFY weekInfoChanged)
    Q_PROPERTY(QString babySizeImage READ babySizeImage NOTIFY weekInfoChanged)
    Q_PROPERTY(double babyLength READ babyLength NOTIFY weekInfoChanged)
    Q_PROPERTY(double babyWeight READ babyWeight NOTIFY weekInfoChanged)
    Q_PROPERTY(QString developmentDescription READ developmentDescription NOTIFY weekInfoChanged)
    Q_PROPERTY(QString baby3dModel READ baby3dModel NOTIFY weekInfoChanged)

public:
    explicit PregnancyWeek(QObject *parent = nullptr);
    PregnancyWeek(int weekNumber, const QString &babySize, const QString &babySizeImage,
                  double babyLength, double babyWeight, const QString &developmentDescription,
                  const QString &baby3dModel, QObject *parent = nullptr);

    // Getters
    int weekNumber() const;
    QString babySize() const;
    QString babySizeImage() const;
    double babyLength() const;
    double babyWeight() const;
    QString developmentDescription() const;
    QString baby3dModel() const;

    void setWeekNumber(int weekNumber);
    void setBabySize(const QString &size);
    void setBabySizeImage(const QString &image);
    void setBabyLength(double length);
    void setBabyWeight(double weight);
    void setDevelopmentDescription(const QString &desc);
    void setBaby3dModel(const QString &model);
    // Метод загрузки данных
    Q_INVOKABLE void loadWeekData();

    // Database operations
    static PregnancyWeek* getWeek(int weekNumber);
    static QList<PregnancyWeek*> getAllWeeks();

signals:
    void weekNumberChanged();
    void weekInfoChanged();

private:

    int m_weekNumber;
    QString m_babySize;
    QString m_babySizeImage;
    double m_babyLength;
    double m_babyWeight;
    QString m_developmentDescription;
    QString m_baby3dModel;
};

#endif // PREGNANCYWEEK_H
