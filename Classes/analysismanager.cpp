#include "analysismanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDate>
#include <QDebug>

AnalysisManager::AnalysisManager(QObject *parent) : QObject(parent)
{
    // Инициализация названий категорий
    m_categoryNames = {
        {"blood", "Биохимия крови"},
        {"urine", "Анализ мочи"},
        {"ultrasound", "УЗИ показатели"}
    };

    // Инициализация названий параметров
    m_parameterNames = {
        {"hemoglobin", "Гемоглобин"},
        {"glucose", "Глюкоза"},
        {"protein", "Белок"},
        {"bpd", "БПР (бипариетальный размер)"},
        {"fl", "Длина бедра"},
        {"hc", "Окружность головы"},
        {"ac", "Окружность живота"},
        {"wbc", "Лейкоциты"},
        {"rbc", "Эритроциты"}
    };

    loadAnalysisData();
}

QVariantList AnalysisManager::analysisData() const {
    return m_analysisData;
}

int AnalysisManager::profileId() const {
    return m_profileId;
}

void AnalysisManager::setProfileId(int id) {
    if (m_profileId != id) {
        m_profileId = id;
        emit profileIdChanged();
        loadAnalysisData();
    }
}

void AnalysisManager::loadAnalysisData() {
    qDebug() << "Loading analysis data for profileId:" << m_profileId;

    QSqlQuery query;
    query.prepare("SELECT ar.id, at.id as typeId, at.category, at.name, "
                  "at.displayName, ar.value, at.unit, ar.testDate, "
                  "ar.notes, at.minValue, at.maxValue, "
                  "ar.laboratory, ar.isFasting "
                  "FROM AnalysisResults ar "
                  "JOIN AnalysisTypes at ON ar.analysisTypeId = at.id "
                  "WHERE ar.profileId = :profileId "
                  "ORDER BY ar.testDate DESC");
    query.bindValue(":profileId", m_profileId);

    if (!query.exec()) {
        qWarning() << "Failed to execute query:" << query.lastError().text();
        qWarning() << "Executed SQL:" << query.lastQuery();
        qWarning() << "Bound values:" << query.boundValues();
        return;
    }

    m_analysisData.clear();
    while (query.next()) {
        QVariantMap analysis;
        analysis["id"] = query.value("id");
        analysis["typeId"] = query.value("typeId");
        analysis["category"] = query.value("category");
        analysis["name"] = query.value("name");
        analysis["type"] = query.value("displayName");
        analysis["value"] = query.value("value");
        analysis["unit"] = query.value("unit");
        analysis["date"] = query.value("testDate");
        analysis["note"] = query.value("notes");
        analysis["minValue"] = query.value("minValue");
        analysis["maxValue"] = query.value("maxValue");
        analysis["laboratory"] = query.value("laboratory");
        analysis["isFasting"] = query.value("isFasting");

        m_analysisData.append(analysis);
    }

    qDebug() << "Loaded" << m_analysisData.size() << "analysis records";
    emit analysisDataChanged();
}

bool AnalysisManager::addAnalysis(int typeId, double value, const QDate &date,
                                  const QString &note, const QString &laboratory,
                                  bool isFasting) {
    if (value <= 0) {
        qWarning() << "Invalid analysis value:" << value;
        return false;
    }

    if (!date.isValid()) {
        qWarning() << "Invalid analysis date:" << date;
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT INTO AnalysisResults "
                  "(profileId, analysisTypeId, testDate, value, notes, laboratory, isFasting) "
                  "VALUES (:profileId, :typeId, :date, :value, :notes, :laboratory, :isFasting)");

    query.bindValue(":profileId", m_profileId);
    query.bindValue(":typeId", typeId);
    query.bindValue(":date", date.toString("yyyy-MM-dd"));
    query.bindValue(":value", value);
    query.bindValue(":notes", note);
    query.bindValue(":laboratory", laboratory);
    query.bindValue(":isFasting", isFasting);

    if (!query.exec()) {
        qWarning() << "Failed to add analysis:" << query.lastError();
        qWarning() << "Executed SQL:" << query.lastQuery();
        qWarning() << "Bound values:" << query.boundValues();
        return false;
    }

    loadAnalysisData();
    return true;
}

bool AnalysisManager::removeAnalysis(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM AnalysisResults WHERE id = :id AND profileId = :profileId");
    query.bindValue(":id", id);
    query.bindValue(":profileId", m_profileId);

    if (!query.exec()) {
        qWarning() << "Failed to remove analysis:" << query.lastError();
        return false;
    }

    loadAnalysisData();
    return true;
}

QVariantList AnalysisManager::getAnalysisTypes() const {
    QVariantList types;
    QSqlQuery query("SELECT id, category, name, displayName, unit, minValue, maxValue, "
                    "genderSpecific, pregnancySpecific FROM AnalysisTypes ORDER BY displayName");

    while (query.next()) {
        QVariantMap type;
        type["id"] = query.value("id");
        type["category"] = query.value("category");
        type["name"] = query.value("name");
        type["displayName"] = query.value("displayName");
        type["unit"] = query.value("unit");
        type["minValue"] = query.value("minValue");
        type["maxValue"] = query.value("maxValue");
        type["genderSpecific"] = query.value("genderSpecific");
        type["pregnancySpecific"] = query.value("pregnancySpecific");
        types.append(type);
    }

    return types;
}

QVariantMap AnalysisManager::getFormattedAnalysisData() const
{
    QVariantMap result;

    QMap<QString, QString> categoryMapping = {
        {"Кровь", "blood"},
        {"Моча", "urine"},
        {"УЗИ", "ultrasound"},
        {"УЗИ", "ultrasound"}
    };

    QMap<QString, QString> paramMapping = {
        {"HGB", "hemoglobin"},
        {"WBC", "wbc"},
        {"GLU", "glucose"},
        {"PRO", "protein"},
        {"BPD", "bpd"},
        {"FL", "fl"}
    };

    for (const QVariant &item : m_analysisData) {
        QVariantMap analysis = item.toMap();
        QString russianCategory = analysis["category"].toString();
        QString category = categoryMapping.value(russianCategory, russianCategory);
        QString name = paramMapping.value(analysis["name"].toString(),
                                          analysis["name"].toString().toLower());

        QVariantMap paramData;
        paramData["value"] = analysis["value"];
        paramData["min"] = analysis["minValue"];
        paramData["max"] = analysis["maxValue"];
        paramData["unit"] = analysis["unit"];
        paramData["date"] = analysis["date"];
        paramData["note"] = analysis["note"];
        paramData["laboratory"] = analysis["laboratory"];
        paramData["isFasting"] = analysis["isFasting"];
        paramData["typeId"] = analysis["typeId"];
        paramData["id"] = analysis["id"]; // Добавляем ID для уникальности

        // Создаем уникальный ключ: имя параметра + дата + ID
        QString uniqueKey = QString("%1_%2_%3")
                                .arg(name)
                                .arg(analysis["date"].toString())
                                .arg(analysis["id"].toString());

        if (!result.contains(category)) {
            result.insert(category, QVariantMap());
        }

        QVariantMap categoryMap = result[category].toMap();
        categoryMap.insert(uniqueKey, paramData);
        result[category] = categoryMap;
    }

    return result;
}

QVariantList AnalysisManager::getAnalysisHistory(int typeId) const {
    QVariantList history;

    QSqlQuery query;
    query.prepare("SELECT ar.value, ar.testDate as date, ar.notes as note, "
                  "at.minValue as min, at.maxValue as max, at.unit "
                  "FROM AnalysisResults ar "
                  "JOIN AnalysisTypes at ON ar.analysisTypeId = at.id "
                  "WHERE ar.analysisTypeId = :typeId AND ar.profileId = :profileId "
                  "ORDER BY ar.testDate DESC");
    query.bindValue(":typeId", typeId);
    query.bindValue(":profileId", m_profileId);

    if (query.exec()) {
        while (query.next()) {
            QVariantMap item;
            item["value"] = query.value("value");
            item["date"] = query.value("date");
            item["note"] = query.value("note");
            item["min"] = query.value("min");
            item["max"] = query.value("max");
            item["unit"] = query.value("unit");
            history.append(item);
        }
    }

    return history;
}

QString AnalysisManager::getParameterName(const QString &key) const {
    return m_parameterNames.value(key, key).toString();
}
