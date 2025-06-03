// exercisemanager.cpp
#include "exercisemanager.h"
#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

ExerciseManager::ExerciseManager(QObject *parent) : QObject(parent)
{
}

QVariantMap ExerciseManager::getTrainingProgram(int programId) const
{
    QVariantMap program;
    QVariantList days;

    // Получаем информацию о программе
    QSqlQuery programQuery(DatabaseManager::instance().database());
    programQuery.prepare("SELECT name, description FROM TrainingPrograms WHERE id = ?");
    programQuery.addBindValue(programId);

    if (!programQuery.exec() || !programQuery.next()) {
        qWarning() << "Failed to get program info:" << programQuery.lastError();
        return program;
    }

    program["name"] = programQuery.value("name").toString();
    program["description"] = programQuery.value("description").toString();

    // Получаем дни для программы
    QSqlQuery daysQuery(DatabaseManager::instance().database());
    daysQuery.prepare("SELECT id, dayNumber, isCompleted FROM TrainingDays WHERE programId = ? ORDER BY dayNumber");
    daysQuery.addBindValue(programId);

    if (!daysQuery.exec()) {
        qWarning() << "Failed to get days:" << daysQuery.lastError();
        return program;
    }

    while (daysQuery.next()) {
        QVariantMap day;
        day["id"] = daysQuery.value("id").toInt();
        day["dayNumber"] = daysQuery.value("dayNumber").toInt();
        day["isCompleted"] = daysQuery.value("isCompleted").toBool();

        // Получаем упражнения для дня
        QVariantList exercises;
        QSqlQuery exQuery(DatabaseManager::instance().database());
        exQuery.prepare("SELECT id, exerciseNumber, sets, holdTime, restTime, isCompleted "
                        "FROM Exercises WHERE dayId = ? ORDER BY exerciseNumber");
        exQuery.addBindValue(day["id"].toInt());

        if (!exQuery.exec()) {
            qWarning() << "Failed to get exercises:" << exQuery.lastError();
            continue;
        }

        while (exQuery.next()) {
            QVariantMap exercise;
            exercise["id"] = exQuery.value("id").toInt();
            exercise["exerciseNumber"] = exQuery.value("exerciseNumber").toInt();
            exercise["sets"] = exQuery.value("sets").toInt();
            exercise["holdTime"] = exQuery.value("holdTime").toInt();
            exercise["restTime"] = exQuery.value("restTime").toInt();
            exercise["isCompleted"] = exQuery.value("isCompleted").toBool();
            exercises.append(exercise);
        }

        day["exercises"] = exercises;
        days.append(day);
    }

    program["days"] = days;
    return program;
}

int ExerciseManager::getCurrentDayForProgram(int programId) const
{
    QSqlQuery query(DatabaseManager::instance().database());
    query.prepare("SELECT MIN(dayNumber) FROM TrainingDays "
                  "WHERE programId = ? AND isCompleted = FALSE");
    query.addBindValue(programId);

    if (!query.exec() || !query.next()) {
        qWarning() << "Failed to get current day:" << query.lastError().text();
        return 1;
    }

    int day = query.value(0).toInt();
    return day > 0 ? day : 1;
}

bool ExerciseManager::markExerciseCompleted(int exerciseId, bool completed)
{
    QSqlQuery query(DatabaseManager::instance().database());
    query.prepare("UPDATE Exercises SET isCompleted = ? WHERE id = ?");
    query.addBindValue(completed);
    query.addBindValue(exerciseId);

    return query.exec();
}

bool ExerciseManager::markDayCompleted(int dayId, bool completed)
{
    QSqlQuery query(DatabaseManager::instance().database());
    query.prepare("UPDATE TrainingDays SET isCompleted = ? WHERE id = ?");
    query.addBindValue(completed);
    query.addBindValue(dayId);

    return query.exec();
}

int ExerciseManager::getCompletedExercisesCount(int dayId) const
{
    QSqlQuery query(DatabaseManager::instance().database());
    query.prepare("SELECT COUNT(*) FROM Exercises "
                  "WHERE dayId = ? AND isCompleted = TRUE");
    query.addBindValue(dayId);

    if (!query.exec() || !query.next()) {
        qWarning() << "Failed to get completed exercises count:" << query.lastError().text();
        return 0;
    }

    return query.value(0).toInt();
}

QVariantList ExerciseManager::getAllTrainingPrograms() const
{
    QVariantList programs;
    QSqlQuery query(DatabaseManager::instance().database());
    query.prepare("SELECT id, name, description FROM TrainingPrograms");

    if (!query.exec()) {
        qWarning() << "Failed to get programs:" << query.lastError();
        return programs;
    }

    while (query.next()) {
        QVariantMap program;
        program["id"] = query.value("id").toInt();
        program["name"] = query.value("name").toString();
        program["description"] = query.value("description").toString();
        programs.append(program);
    }

    return programs;
}

bool ExerciseManager::setCurrentProgram(int programId)
{
    QSqlQuery query(DatabaseManager::instance().database());
    query.prepare("UPDATE CurrentState SET programId = ?");
    query.addBindValue(programId);
    return query.exec();
}
