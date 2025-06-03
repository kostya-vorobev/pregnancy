// exercisemanager.h
#ifndef EXERCISEMANAGER_H
#define EXERCISEMANAGER_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>

class ExerciseManager : public QObject
{
    Q_OBJECT
public:
    explicit ExerciseManager(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap getTrainingProgram(int programId) const;
    Q_INVOKABLE int getCurrentDayForProgram(int programId) const;
    Q_INVOKABLE bool markExerciseCompleted(int exerciseId, bool completed);
    Q_INVOKABLE bool markDayCompleted(int dayId, bool completed);
    Q_INVOKABLE int getCompletedExercisesCount(int dayId) const;

    Q_INVOKABLE QVariantList getAllTrainingPrograms() const;

    Q_INVOKABLE bool setCurrentProgram(int programId);
};

#endif // EXERCISEMANAGER_H
