#include "pregnancycalendarmanager.h"
#include <QSqlQuery>
#include <QDebug>

PregnancyCalendarManager::PregnancyCalendarManager(QObject *parent)
    : QObject(parent), m_dbManager(DatabaseManager::instance())
{
}

QVariantList PregnancyCalendarManager::getAvailableSymptoms()
{
    QVariantList symptoms;
    QSqlQuery query(m_dbManager.database());

    if (query.exec("SELECT id, name FROM Symptoms")) {
        while (query.next()) {
            QVariantMap symptom;
            symptom["id"] = query.value("id").toInt();
            symptom["name"] = query.value("name").toString();
            symptoms.append(symptom);
        }
    } else {
        qWarning() << "Failed to load symptoms:" << query.lastError().text();
    }

    return symptoms;
}

void PregnancyCalendarManager::saveSymptoms(const QString &date, const QVariantList &symptoms)
{
    QSqlDatabase db = m_dbManager.database();
    db.transaction();

    try {
        // Сначала удаляем все симптомы для этой даты
        QSqlQuery deleteQuery(db);
        deleteQuery.prepare("DELETE FROM DaySymptoms WHERE date = ?");
        deleteQuery.addBindValue(date);
        deleteQuery.exec();

        // Затем добавляем новые
        QSqlQuery insertQuery(db);
        insertQuery.prepare("INSERT INTO DaySymptoms (date, symptomId, severity) VALUES (?, ?, ?)");

        for (const QVariant &item : symptoms) {
            QVariantMap symptom = item.toMap();
            if (symptom["severity"].toInt() > 0) {
                insertQuery.addBindValue(date);
                insertQuery.addBindValue(symptom["id"].toInt());
                insertQuery.addBindValue(symptom["severity"].toInt());
                insertQuery.exec();
            }
        }

        db.commit();
    } catch (...) {
        db.rollback();
        qWarning() << "Failed to save symptoms, transaction rolled back";
    }
}

QVariantMap PregnancyCalendarManager::loadPregnancyData()
{
    QVariantMap result;
    result["currentDay"] = 0;
    result["currentWeek"] = 0;

    QSqlQuery query(m_dbManager.database());
    if (query.exec("SELECT * FROM PregnancyProgress WHERE profileId = 1")) {
        if (query.next()) {
            QDate today = QDate::currentDate();
            QDate startDate = query.value("startDate").toDate();
            int diffDays = startDate.daysTo(today);
            result["currentDay"] = diffDays;
            result["currentWeek"] = diffDays / 7;
        }
    } else {
        qWarning() << "Failed to load pregnancy data:" << query.lastError().text();
    }

    return result;
}

QVariantMap PregnancyCalendarManager::getDayData(const QString &date)
{
    QVariantMap dayData;
    dayData["weight"] = "Никогда не измерялось";
    dayData["pressure"] = "Никогда не измерялось";
    dayData["waist"] = "Никогда не измерялось";
    dayData["mood"] = "";
    dayData["symptoms"] = QVariantList();

    QSqlQuery query(m_dbManager.database());

    // Получаем данные из PregnancyCalendar
    query.prepare("SELECT * FROM PregnancyCalendar WHERE date = ?");
    query.addBindValue(date);
    if (query.exec() && query.next()) {
        if (!query.value("weight").isNull()) {
            dayData["weight"] = QString::number(query.value("weight").toDouble()) + " кг";
        }
        if (!query.value("systolicPressure").isNull() && !query.value("diastolicPressure").isNull()) {
            dayData["pressure"] = QString::number(query.value("systolicPressure").toInt()) +
                                  "/" + QString::number(query.value("diastolicPressure").toInt()) +
                                  " мм рт.ст.";
        }
        if (!query.value("waistCircumference").isNull()) {
            dayData["waist"] = QString::number(query.value("waistCircumference").toDouble()) + " см";
        }
        if (!query.value("mood").isNull()) {
            dayData["mood"] = query.value("mood").toString();
        }
    }

    // Получаем симптомы за день (используем новую переменную query2)
    QSqlQuery query2(m_dbManager.database());
    query2.prepare("SELECT s.id, s.name, ds.severity FROM DaySymptoms ds "
                   "JOIN Symptoms s ON ds.symptomId = s.id WHERE ds.date = ?");
    query2.addBindValue(date);

    QVariantList symptoms;
    if (query2.exec()) {
        while (query2.next()) {
            QVariantMap symptom;
            symptom["id"] = query2.value("id").toInt();
            symptom["name"] = query2.value("name").toString();
            symptom["severity"] = query2.value("severity").toInt();
            symptoms.append(symptom);
        }
    }

    // Получаем все доступные симптомы
    QVariantList allSymptoms = getAvailableSymptoms();
    for (const QVariant &item : allSymptoms) {
        QVariantMap symptom = item.toMap();
        bool found = false;

        // Проверяем, есть ли этот симптом в выбранных
        for (const QVariant &selectedItem : symptoms) {
            if (selectedItem.toMap()["id"] == symptom["id"]) {
                found = true;
                break;
            }
        }

        if (!found) {
            symptom["severity"] = 0; // симптом не выбран
            symptoms.append(symptom);
        }
    }

    dayData["symptoms"] = symptoms;
    return dayData;
}

void PregnancyCalendarManager::saveDayData(const QString &date, const QString &weight,
                                           const QString &pressure, const QString &waist,
                                           const QString &mood)
{
    QSqlDatabase db = m_dbManager.database();
    db.transaction();

    try {
        // Разбираем давление
        QStringList pressureParts = pressure.split("/");
        int systolic = pressureParts.size() > 0 ? pressureParts[0].toInt() : 0;
        int diastolic = pressureParts.size() > 1 ? pressureParts[1].toInt() : 0;

        // Проверяем существование записи
        QSqlQuery checkQuery(db);
        checkQuery.prepare("SELECT 1 FROM PregnancyCalendar WHERE date = ?");
        checkQuery.addBindValue(date);
        checkQuery.exec();

        if (checkQuery.next()) {
            // Обновляем существующую запись
            QSqlQuery updateQuery(db);
            updateQuery.prepare("UPDATE PregnancyCalendar SET weight = ?, systolicPressure = ?, "
                                "diastolicPressure = ?, waistCircumference = ?, mood = ? WHERE date = ?");
            updateQuery.addBindValue(weight.toDouble());
            updateQuery.addBindValue(systolic);
            updateQuery.addBindValue(diastolic);
            updateQuery.addBindValue(waist.toDouble());
            updateQuery.addBindValue(mood);
            updateQuery.addBindValue(date);
            updateQuery.exec();
        } else {
            // Создаем новую запись
            QSqlQuery insertQuery(db);
            insertQuery.prepare("INSERT INTO PregnancyCalendar (date, weight, systolicPressure, "
                                "diastolicPressure, waistCircumference, mood) "
                                "VALUES (?, ?, ?, ?, ?, ?)");
            insertQuery.addBindValue(date);
            insertQuery.addBindValue(weight.toDouble());
            insertQuery.addBindValue(systolic);
            insertQuery.addBindValue(diastolic);
            insertQuery.addBindValue(waist.toDouble());
            insertQuery.addBindValue(mood);
            insertQuery.exec();
        }

        // Сохраняем вес в таблицу WeightMeasurements
        if (!weight.isEmpty() && weight != "0") {
            QSqlQuery checkWeightQuery(db);
            checkWeightQuery.prepare("SELECT 1 FROM WeightMeasurements WHERE measurementDate = ? AND profileId = 1");
            checkWeightQuery.addBindValue(date);
            checkWeightQuery.exec();

            if (checkWeightQuery.next()) {
                QSqlQuery updateWeightQuery(db);
                updateWeightQuery.prepare("UPDATE WeightMeasurements SET weight = ? "
                                          "WHERE measurementDate = ? AND profileId = 1");
                updateWeightQuery.addBindValue(weight.toDouble());
                updateWeightQuery.addBindValue(date);
                updateWeightQuery.exec();
            } else {
                QSqlQuery insertWeightQuery(db);
                insertWeightQuery.prepare("INSERT INTO WeightMeasurements (profileId, weight, measurementDate) "
                                          "VALUES (1, ?, ?)");
                insertWeightQuery.addBindValue(weight.toDouble());
                insertWeightQuery.addBindValue(date);
                insertWeightQuery.exec();
            }
        }

        db.commit();
    } catch (...) {
        db.rollback();
        qWarning() << "Failed to save day data, transaction rolled back";
    }
}
