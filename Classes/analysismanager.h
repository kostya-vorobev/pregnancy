// analysismanager.h
#pragma once

#include <QObject>
#include <QVector>
#include <QVariantMap>
#include <QDate>

class AnalysisManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList analysisData READ analysisData NOTIFY analysisDataChanged)
    Q_PROPERTY(int profileId READ profileId WRITE setProfileId NOTIFY profileIdChanged)
    Q_PROPERTY(QVariantMap formattedAnalysisData READ getFormattedAnalysisData NOTIFY analysisDataChanged)

public:
    explicit AnalysisManager(QObject *parent = nullptr);

    QVariantList analysisData() const;
    int profileId() const;
    void setProfileId(int id);

    Q_INVOKABLE void loadAnalysisData();
    Q_INVOKABLE bool addAnalysis(int typeId, double value, const QDate &date,
                                 const QString &note = "", const QString &laboratory = "",
                                 bool isFasting = false);
    Q_INVOKABLE bool removeAnalysis(int id);
    Q_INVOKABLE QVariantList getAnalysisTypes() const;
    Q_INVOKABLE QVariantMap getFormattedAnalysisData() const;
    Q_INVOKABLE QString getParameterName(const QString &key) const;
    Q_INVOKABLE QVariantList getAnalysisHistory(int typeId) const;
signals:
    void analysisDataChanged();
    void profileIdChanged();

private:
    QVariantList m_analysisData;
    int m_profileId = 1;
    QVariantMap m_categoryNames;
    QVariantMap m_parameterNames;
};
