#include "dailyTip.h"
#include "databaseManager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QRandomGenerator>

DailyTip::DailyTip(QObject *parent) : QObject(parent), m_id(-1), m_forTrimester(0)
{
}

DailyTip::DailyTip(int id, const QString &tipText, int forTrimester, const QString &tags, QObject *parent)
    : QObject(parent), m_id(id), m_tipText(tipText), m_forTrimester(forTrimester), m_tags(tags)
{
}

// Getters implementation
int DailyTip::id() const { return m_id; }
QString DailyTip::tipText() const { return m_tipText; }
int DailyTip::forTrimester() const { return m_forTrimester; }
QString DailyTip::tags() const { return m_tags; }

// Database operations
DailyTip* DailyTip::getRandomTip()
{
    QSqlQuery query("SELECT * FROM DailyTips ORDER BY RANDOM() LIMIT 1");

    if (query.next()) {
        return new DailyTip(
            query.value("id").toInt(),
            query.value("tipText").toString(),
            query.value("forTrimester").toInt(),
            query.value("tags").toString()
            );
    }

    return nullptr;
}

DailyTip* DailyTip::getTipForTrimester(int trimester)
{
    QSqlQuery query;
    query.prepare("SELECT * FROM DailyTips WHERE forTrimester = :trimester ORDER BY RANDOM() LIMIT 1");
    query.bindValue(":trimester", trimester);

    if (query.exec() && query.next()) {
        return new DailyTip(
            query.value("id").toInt(),
            query.value("tipText").toString(),
            query.value("forTrimester").toInt(),
            query.value("tags").toString()
            );
    }

    return nullptr;
}

QList<DailyTip*> DailyTip::getAllTips()
{
    QList<DailyTip*> tips;
    QSqlQuery query("SELECT * FROM DailyTips");

    while (query.next()) {
        tips.append(new DailyTip(
            query.value("id").toInt(),
            query.value("tipText").toString(),
            query.value("forTrimester").toInt(),
            query.value("tags").toString()
            ));
    }

    return tips;
}
