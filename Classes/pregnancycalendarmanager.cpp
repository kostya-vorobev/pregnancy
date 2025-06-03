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

    if (query.exec("SELECT id, name, category FROM Symptoms")) {
        while (query.next()) {
            QVariantMap symptom;
            symptom["id"] = query.value("id").toInt();
            symptom["name"] = query.value("name").toString();
            symptom["category"] = query.value("category").toString();
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
        // First get or create the daily record to get its ID
        int dayId = -1;
        QSqlQuery checkDayQuery(db);
        checkDayQuery.prepare("SELECT id FROM DailyRecords WHERE date = ?");
        checkDayQuery.addBindValue(date);

        if (checkDayQuery.exec() && checkDayQuery.next()) {
            dayId = checkDayQuery.value("id").toInt();
        } else {
            // Create a new daily record if it doesn't exist
            QSqlQuery insertDayQuery(db);
            insertDayQuery.prepare("INSERT INTO DailyRecords (date) VALUES (?)");
            insertDayQuery.addBindValue(date);
            if (insertDayQuery.exec()) {
                dayId = insertDayQuery.lastInsertId().toInt();
            } else {
                throw std::runtime_error("Failed to create daily record");
            }
        }

        // Delete existing symptoms for this day
        QSqlQuery deleteQuery(db);
        deleteQuery.prepare("DELETE FROM DaySymptoms WHERE dayId = ?");
        deleteQuery.addBindValue(dayId);
        if (!deleteQuery.exec()) {
            throw std::runtime_error("Failed to delete existing symptoms");
        }

        // Insert new symptoms
        QSqlQuery insertQuery(db);
        insertQuery.prepare("INSERT INTO DaySymptoms (dayId, symptomId, severity, notes) "
                            "VALUES (?, ?, ?, ?)");

        for (const QVariant &item : symptoms) {
            QVariantMap symptom = item.toMap();
            int severity = symptom["severity"].toInt();
            if (severity > 0) {  // Only save symptoms with severity > 0
                insertQuery.addBindValue(dayId);
                insertQuery.addBindValue(symptom["id"].toInt());
                insertQuery.addBindValue(severity);
                insertQuery.addBindValue(symptom["notes"].toString());
                if (!insertQuery.exec()) {
                    qWarning() << "Failed to insert symptom:" << insertQuery.lastError().text();
                }
            }
        }

        db.commit();
    } catch (const std::exception &e) {
        db.rollback();
        qWarning() << "Failed to save symptoms:" << e.what();
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
    dayData["notes"] = "";
    dayData["symptoms"] = QVariantList();

    QSqlQuery query(m_dbManager.database());

    // Get basic day data
    query.prepare("SELECT * FROM DailyRecords WHERE date = ?");
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
        if (!query.value("notes").isNull()) {
            dayData["notes"] = query.value("notes").toString();
        }
    }

    // Get symptoms for the day
    QVariantList symptoms;
    QSqlQuery symptomQuery(m_dbManager.database());
    symptomQuery.prepare("SELECT s.id, s.name, ds.severity, ds.notes "
                         "FROM DaySymptoms ds "
                         "JOIN Symptoms s ON ds.symptomId = s.id "
                         "JOIN DailyRecords dr ON ds.dayId = dr.id "
                         "WHERE dr.date = ?");
    symptomQuery.addBindValue(date);

    if (symptomQuery.exec()) {
        while (symptomQuery.next()) {
            QVariantMap symptom;
            symptom["id"] = symptomQuery.value("id").toInt();
            symptom["name"] = symptomQuery.value("name").toString();
            symptom["severity"] = symptomQuery.value("severity").toInt();
            symptom["notes"] = symptomQuery.value("notes").toString();
            symptoms.append(symptom);
        }
    }

    // Get all available symptoms and merge with selected ones
    QVariantList allSymptoms = getAvailableSymptoms();
    for (QVariant &item : allSymptoms) {
        QVariantMap symptom = item.toMap();
        bool found = false;

        for (const QVariant &selectedItem : symptoms) {
            if (selectedItem.toMap()["id"] == symptom["id"]) {
                found = true;
                break;
            }
        }

        if (!found) {
            symptom["severity"] = 0;
            symptom["notes"] = "";
            symptoms.append(symptom);
        }
    }

    dayData["symptoms"] = symptoms;

    // Get daily plans
    QVariantList plans;
    QSqlQuery planQuery(m_dbManager.database());
    planQuery.prepare("SELECT DailyPlans.id, planType, description, time, isCompleted "
                      "FROM DailyPlans "
                      "JOIN DailyRecords ON DailyPlans.dayId = DailyRecords.id "
                      "WHERE DailyRecords.date = ?");
    planQuery.addBindValue(date);

    if (planQuery.exec()) {
        while (planQuery.next()) {
            QVariantMap plan;
            plan["id"] = planQuery.value("id").toInt();
            plan["planType"] = planQuery.value("planType").toString();
            plan["description"] = planQuery.value("description").toString();
            plan["time"] = planQuery.value("time").toString();
            plan["isCompleted"] = planQuery.value("isCompleted").toBool();
            plans.append(plan);
            qDebug() << "Loaded plan:" << plan;
        }
    } else {
        qWarning() << "Failed to load plans:" << planQuery.lastError().text();
    }

    dayData["plans"] = plans;
    return dayData;
}


void PregnancyCalendarManager::saveDayData(const QString &date, const QString &weight,
                                           const QString &pressure, const QString &waist,
                                           const QString &mood, const QString &notes)
{
    QSqlDatabase db = m_dbManager.database();
    db.transaction();

    try {
        // Parse pressure
        QStringList pressureParts = pressure.split("/");
        int systolic = pressureParts.size() > 0 ? pressureParts[0].toInt() : 0;
        int diastolic = pressureParts.size() > 1 ? pressureParts[1].toInt() : 0;

        // Check if record exists
        QSqlQuery checkQuery(db);
        checkQuery.prepare("SELECT id FROM DailyRecords WHERE date = ?");
        checkQuery.addBindValue(date);
        checkQuery.exec();

        if (checkQuery.next()) {
            // Update existing record
            QSqlQuery updateQuery(db);
            updateQuery.prepare("UPDATE DailyRecords SET "
                                "weight = ?, "
                                "systolicPressure = ?, "
                                "diastolicPressure = ?, "
                                "waistCircumference = ?, "
                                "mood = ?, "
                                "notes = ? "
                                "WHERE date = ?");
            updateQuery.addBindValue(weight.isEmpty() ? QVariant() : weight.toDouble());
            updateQuery.addBindValue(systolic > 0 ? systolic : QVariant());
            updateQuery.addBindValue(diastolic > 0 ? diastolic : QVariant());
            updateQuery.addBindValue(waist.isEmpty() ? QVariant() : waist.toDouble());
            updateQuery.addBindValue(mood.isEmpty() ? QVariant() : mood);
            updateQuery.addBindValue(notes.isEmpty() ? QVariant() : notes);
            updateQuery.addBindValue(date);
            updateQuery.exec();
        } else {
            // Create new record
            QSqlQuery insertQuery(db);
            insertQuery.prepare("INSERT INTO DailyRecords ("
                                "date, weight, systolicPressure, "
                                "diastolicPressure, waistCircumference, mood, notes) "
                                "VALUES (?, ?, ?, ?, ?, ?, ?)");
            insertQuery.addBindValue(date);
            insertQuery.addBindValue(weight.isEmpty() ? QVariant() : weight.toDouble());
            insertQuery.addBindValue(systolic > 0 ? systolic : QVariant());
            insertQuery.addBindValue(diastolic > 0 ? diastolic : QVariant());
            insertQuery.addBindValue(waist.isEmpty() ? QVariant() : waist.toDouble());
            insertQuery.addBindValue(mood.isEmpty() ? QVariant() : mood);
            insertQuery.addBindValue(notes.isEmpty() ? QVariant() : notes);
            insertQuery.exec();
        }

        db.commit();
    } catch (...) {
        db.rollback();
        qWarning() << "Failed to save day data, transaction rolled back";
    }
}

void PregnancyCalendarManager::addDailyPlan(const QString &date, const QString &planType,
                                            const QString &description, const QString &time)
{
    QSqlDatabase db = m_dbManager.database();
    db.transaction();

    try {
        // First get the dayId for the date
        int dayId = -1;
        QSqlQuery dayQuery(db);
        dayQuery.prepare("SELECT id FROM DailyRecords WHERE date = ?");
        dayQuery.addBindValue(date);

        if (dayQuery.exec() && dayQuery.next()) {
            dayId = dayQuery.value("id").toInt();
        } else {
            // Create new daily record if it doesn't exist
            QSqlQuery insertDayQuery(db);
            insertDayQuery.prepare("INSERT INTO DailyRecords (date) VALUES (?)");
            insertDayQuery.addBindValue(date);
            if (insertDayQuery.exec()) {
                dayId = insertDayQuery.lastInsertId().toInt();
            } else {
                throw std::runtime_error("Failed to create daily record");
            }
        }

        // Insert the new plan
        QSqlQuery query(db);
        query.prepare("INSERT INTO DailyPlans (dayId, planType, description, time, isCompleted) "
                      "VALUES (?, ?, ?, ?, ?)");
        query.addBindValue(dayId);
        query.addBindValue(planType);
        query.addBindValue(description);
        query.addBindValue(time);
        query.addBindValue(false);

        if (!query.exec()) {
            throw std::runtime_error("Failed to insert daily plan");
        }

        db.commit();
    } catch (const std::exception &e) {
        db.rollback();
        qWarning() << "Failed to add daily plan:" << e.what();
        //emit errorOccurred(tr("Failed to save daily plan"));
    }
}

int PregnancyCalendarManager::lastInsertedPlanId() {
    QSqlQuery query(m_dbManager.database());
    query.exec("SELECT last_insert_rowid()");
    if (query.next()) {
        return query.value(0).toInt();
    }
    return -1;
}

void PregnancyCalendarManager::deletePlan(int planId) {
    QSqlQuery query(m_dbManager.database());
    query.prepare("DELETE FROM DailyPlans WHERE id = ?");
    query.addBindValue(planId);
    if (!query.exec()) {
        qWarning() << "Failed to delete plan:" << query.lastError().text();
    }
}


