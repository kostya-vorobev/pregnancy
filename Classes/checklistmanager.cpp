// checklistmanager.cpp
#include "checklistmanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>

ChecklistManager::ChecklistManager(QObject *parent) : QObject(parent)
{
    loadChecklists();
}

QVariantList ChecklistManager::checklists() const {
    return m_checklists;
}

QVariantList ChecklistManager::tasks() const {
    return m_tasks;
}

void ChecklistManager::loadChecklists() {
    // Загрузка чеклистов
    QSqlQuery checklistQuery("SELECT id, name, category, trimester FROM Checklist WHERE isDefault = TRUE");
    m_checklists.clear();
    while (checklistQuery.next()) {
        QVariantMap checklist;
        checklist["id"] = checklistQuery.value(0);
        checklist["name"] = checklistQuery.value(1);
        checklist["category"] = checklistQuery.value(2);
        checklist["trimester"] = checklistQuery.value(3);
        m_checklists.append(checklist);
    }
    emit checklistsChanged();

    // Загрузка задач
    QSqlQuery taskQuery("SELECT id, checklistId, title, isCompleted FROM Tasks");
    m_tasks.clear();
    while (taskQuery.next()) {
        QVariantMap task;
        task["id"] = taskQuery.value(0);
        task["checklistId"] = taskQuery.value(1);
        task["title"] = taskQuery.value(2);
        task["isCompleted"] = taskQuery.value(3);
        m_tasks.append(task);
    }
    emit tasksChanged();
}

void ChecklistManager::updateTaskStatus(int taskId, bool isCompleted) {
    QSqlQuery query;
    query.prepare("UPDATE Tasks SET isCompleted = :completed WHERE id = :id");
    query.bindValue(":completed", isCompleted ? 1 : 0); // Явное преобразование bool в int
    query.bindValue(":id", taskId);

    if (query.exec()) {
        // Обновляем локальную копию данных
        for (auto &task : m_tasks) {
            QVariantMap taskMap = task.toMap();
            if (taskMap["id"].toInt() == taskId) {
                taskMap["isCompleted"] = isCompleted ? 1 : 0;
                task = taskMap;
                break;
            }
        }
        emit tasksChanged();
    } else {
        qWarning() << "Failed to update task status:" << query.lastError();
    }
}
