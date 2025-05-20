#ifndef DAILYTIP_H
#define DAILYTIP_H

#include <QObject>
#include <QDate>

class DailyTip : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(QString tipText READ tipText CONSTANT)
    Q_PROPERTY(int forTrimester READ forTrimester CONSTANT)
    Q_PROPERTY(QString tags READ tags CONSTANT)

public:
    explicit DailyTip(QObject *parent = nullptr);
    DailyTip(int id, const QString &tipText, int forTrimester, const QString &tags, QObject *parent = nullptr);

    // Getters
    int id() const;
    QString tipText() const;
    int forTrimester() const;
    QString tags() const;

    // Database operations
    static DailyTip* getRandomTip();
    Q_INVOKABLE static DailyTip* getTipForTrimester(int trimester);
    static QList<DailyTip*> getAllTips();

private:
    int m_id;
    QString m_tipText;
    int m_forTrimester;
    QString m_tags;
};

#endif // DAILYTIP_H
