// fetalkickmanager.h
#pragma once

#include <QObject>
#include <QVector>
#include <QVariantMap>

class FetalKickManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList kickHistory READ kickHistory NOTIFY kickHistoryChanged)
    Q_PROPERTY(int profileId READ profileId WRITE setProfileId NOTIFY profileIdChanged)

public:
    explicit FetalKickManager(QObject *parent = nullptr);

    QVariantList kickHistory() const;
    int profileId() const;
    void setProfileId(int id);

    Q_INVOKABLE void loadKickHistory();
    Q_INVOKABLE void saveKickSession(int kickCount, const QString &notes = "");
    Q_INVOKABLE void deleteKickSession(int id);

signals:
    void kickHistoryChanged();
    void profileIdChanged();

private:
    QVariantList m_kickHistory;
    int m_profileId;
};
