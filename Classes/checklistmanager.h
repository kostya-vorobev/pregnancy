// checklistmanager.h
#pragma once

#include <QObject>
#include <QVector>
#include <QVariantMap>

class ChecklistManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList checklists READ checklists NOTIFY checklistsChanged)
    Q_PROPERTY(QVariantList tasks READ tasks NOTIFY tasksChanged)

public:
    explicit ChecklistManager(QObject *parent = nullptr);

    QVariantList checklists() const;
    QVariantList tasks() const;

    Q_INVOKABLE void loadChecklists();
    Q_INVOKABLE void updateTaskStatus(int taskId, bool isCompleted);

signals:
    void checklistsChanged();
    void tasksChanged();

private:
    QVariantList m_checklists;
    QVariantList m_tasks;
};
