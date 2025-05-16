#include "PregnancyData.h"
#include "databasehandler.h"

PregnancyData::PregnancyData(QObject *parent) : QObject(parent),
    m_currentWeek(1),
    m_babySize(""),
    m_babySizeImage(""),
    m_dailyTip("")
{
}

int PregnancyData::currentWeek() const
{
    return m_currentWeek;
}

QString PregnancyData::babySize() const
{
    return m_babySize;
}

QString PregnancyData::babySizeImage() const
{
    return m_babySizeImage;
}

QString PregnancyData::dailyTip() const
{
    return m_dailyTip;
}

QString PregnancyData::baby3dModel() const
{
    return m_baby3dModel;
}

void PregnancyData::setCurrentWeek(int week)
{
    if (m_currentWeek == week)
        return;

    m_currentWeek = week;
    emit currentWeekChanged(m_currentWeek);
}

void PregnancyData::loadData(int profileId)
{
    DatabaseHandler dbHandler;
    if (!dbHandler.initializeDatabase()) {
        qWarning() << "Failed to initialize database";

        // Устанавливаем значения по умолчанию
        setCurrentWeek(1);
        m_babySize = "Лимон";
        m_babySizeImage = "lemon";
        m_dailyTip = "Сегодня хороший день, чтобы отдохнуть и позаботиться о себе.";
        m_baby3dModel = "logo";

        emit babySizeChanged(m_babySize);
        emit babySizeImageChanged(m_babySizeImage);
        emit dailyTipChanged(m_dailyTip);
        emit baby3dModelChanged(m_baby3dModel);
        return;
    }

    QVariantMap data = dbHandler.getHomeScreenData(profileId);

    if (data.contains("currentWeek")) {
        setCurrentWeek(data["currentWeek"].toInt());
    }

    if (data.contains("babySize")) {
        m_babySize = data["babySize"].toString();
        emit babySizeChanged(m_babySize);
    }

    if (data.contains("babySizeImage")) {
        m_babySizeImage = data["babySizeImage"].toString();
        emit babySizeImageChanged(m_babySizeImage);
    }

    if (data.contains("dailyTip")) {
        m_dailyTip = data["dailyTip"].toString();
        emit dailyTipChanged(m_dailyTip);
    }

    if (data.contains("baby3dModel")) {
        m_baby3dModel = data["baby3dModel"].toString();
        emit baby3dModelChanged(m_baby3dModel);
    }
}
