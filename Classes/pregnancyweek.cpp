// pregnancyweek.cpp
#include "pregnancyweek.h"
#include "databasemanager.h"
#include <QSqlQuery>
#include <QDebug>

PregnancyWeek::PregnancyWeek(int weekNumber, const QString &babySize, const QString &babySizeImage,
                             double babyLength, double babyWeight, const QString &developmentDescription,
                             const QString &baby3dModel, QObject *parent)
    : QObject(parent), m_weekNumber(weekNumber), m_babySize(babySize),
    m_babySizeImage(babySizeImage), m_babyLength(babyLength),
    m_babyWeight(babyWeight), m_developmentDescription(developmentDescription),
    m_baby3dModel(baby3dModel)
{
}

PregnancyWeek::PregnancyWeek(QObject *parent)
    : QObject(parent),
    m_weekNumber(1),
    m_babyLength(0),
    m_babyWeight(0)
{
}

// Getters implementation
int PregnancyWeek::weekNumber() const { return m_weekNumber; }
QString PregnancyWeek::babySize() const { return m_babySize; }
QString PregnancyWeek::babySizeImage() const { return m_babySizeImage; }
double PregnancyWeek::babyLength() const { return m_babyLength; }
double PregnancyWeek::babyWeight() const { return m_babyWeight; }
QString PregnancyWeek::developmentDescription() const { return m_developmentDescription; }
QString PregnancyWeek::baby3dModel() const { return m_baby3dModel; }

void PregnancyWeek::setWeekNumber(int week) {
    if (m_weekNumber != week) {
        m_weekNumber = week;
        loadWeekData();
        emit weekNumberChanged();
        emit weekInfoChanged();
    }
}

void PregnancyWeek::setBabySize(const QString &size) {
    if (m_babySize != size) {
        m_babySize = size;
        emit weekInfoChanged();
    }
}

void PregnancyWeek::setBabySizeImage(const QString &image) {
    if (m_babySizeImage != image) {
        m_babySizeImage = image;
        emit weekInfoChanged();
    }
}

void PregnancyWeek::setBabyLength(double length) {
    if (!qFuzzyCompare(m_babyLength, length)) {
        m_babyLength = length;
        emit weekInfoChanged();
    }
}

void PregnancyWeek::setBabyWeight(double weight) {
    if (!qFuzzyCompare(m_babyWeight, weight)) {
        m_babyWeight = weight;
        emit weekInfoChanged();
    }
}

void PregnancyWeek::setDevelopmentDescription(const QString &desc) {
    if (m_developmentDescription != desc) {
        m_developmentDescription = desc;
        emit weekInfoChanged();
    }
}

void PregnancyWeek::setBaby3dModel(const QString &model) {
    if (m_baby3dModel != model) {
        m_baby3dModel = model;
        emit weekInfoChanged();
    }
}

void PregnancyWeek::loadWeekData()
{
    PregnancyWeek* weekData = PregnancyWeek::getWeek(m_weekNumber);
    if (weekData) {
        m_babySize = weekData->babySize();
        m_babySizeImage = weekData->babySizeImage();
        m_babyLength = weekData->babyLength();
        m_babyWeight = weekData->babyWeight();
        m_developmentDescription = weekData->developmentDescription();
        m_baby3dModel = weekData->baby3dModel();
        qDebug() << m_babySize;
        weekData->deleteLater();
        emit weekInfoChanged(); // Уведомляем об изменении данных
    }
}

// Database operations
PregnancyWeek* PregnancyWeek::getWeek(int weekNumber)
{
    QSqlQuery query;
    query.prepare("SELECT * FROM PregnancyWeeks WHERE weekNumber = :weekNumber");
    query.bindValue(":weekNumber", weekNumber);

    if (!query.exec()) {
        qWarning() << "Failed to get pregnancy week:" << query.lastError().text();
        return nullptr;
    }

    if (query.next()) {
        return new PregnancyWeek(
            query.value("weekNumber").toInt(),
            query.value("babySize").toString(),
            query.value("babySizeImage").toString(),
            query.value("babyLength").toDouble(),
            query.value("babyWeight").toDouble(),
            query.value("developmentDescription").toString(),
            query.value("baby3dModel").toString()
            );
    }

    return nullptr;
}

QList<PregnancyWeek*> PregnancyWeek::getAllWeeks()
{
    QList<PregnancyWeek*> weeks;
    QSqlQuery query("SELECT * FROM PregnancyWeeks ORDER BY weekNumber");

    while (query.next()) {
        weeks.append(new PregnancyWeek(
            query.value("weekNumber").toInt(),
            query.value("babySize").toString(),
            query.value("babySizeImage").toString(),
            query.value("babyLength").toDouble(),
            query.value("babyWeight").toDouble(),
            query.value("developmentDescription").toString(),
            query.value("baby3dModel").toString()
            ));
    }

    return weeks;
}
