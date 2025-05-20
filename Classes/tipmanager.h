// tipmanager.h
#pragma once

#include <QObject>
#include <QVector>
#include <QVariantMap>

class TipManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList tips READ tips NOTIFY tipsChanged)
    Q_PROPERTY(QVariantList tags READ tags NOTIFY tagsChanged)
    Q_PROPERTY(QVariantMap dailyTip READ dailyTip NOTIFY dailyTipChanged)

public:
    explicit TipManager(QObject *parent = nullptr);

    QVariantList tips() const;
    QVariantList tags() const;
    QVariantMap dailyTip() const;

    Q_INVOKABLE void loadTips();
    Q_INVOKABLE void searchTips(const QString &query);
    Q_INVOKABLE void updateDailyTip();
    Q_INVOKABLE void toggleFavorite(int tipId);

signals:
    void tipsChanged();
    void tagsChanged();
    void dailyTipChanged();

private:
    QVariantList m_tips;
    QVariantList m_tags;
    QVariantMap m_dailyTip;
};
