// weightmanager.h
#pragma once

#include <QObject>
#include <QVector>
#include <QVariantMap>

class WeightManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList weightData READ weightData NOTIFY weightDataChanged)
    Q_PROPERTY(int profileId READ profileId WRITE setProfileId NOTIFY profileIdChanged)

public:
    explicit WeightManager(QObject *parent = nullptr);

    QVariantList weightData() const;
    int profileId() const;
    void setProfileId(int id);

    Q_INVOKABLE void loadWeightData();
    Q_INVOKABLE bool addWeightMeasurement(double weight, const QDate &date, const QString &note = "");
    Q_INVOKABLE bool removeWeightMeasurement(int id);

signals:
    void weightDataChanged();
    void profileIdChanged();

private:
    QVariantList m_weightData;
    int m_profileId;
};
