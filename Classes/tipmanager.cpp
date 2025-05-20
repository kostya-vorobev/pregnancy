// tipmanager.cpp
#include "tipmanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QRandomGenerator>

TipManager::TipManager(QObject *parent) : QObject(parent)
{
    loadTips();
}

QVariantList TipManager::tips() const {
    return m_tips;
}

QVariantList TipManager::tags() const {
    return m_tags;
}

QVariantMap TipManager::dailyTip() const {
    return m_dailyTip;
}

void TipManager::loadTips() {
    // Загрузка тегов
    QSqlQuery tagQuery("SELECT id, name FROM Tags");
    m_tags.clear();
    while (tagQuery.next()) {
        QVariantMap tag;
        tag["id"] = tagQuery.value(0);
        tag["name"] = tagQuery.value(1);
        m_tags.append(tag);
    }
    emit tagsChanged();

    // Загрузка советов
    QSqlQuery tipQuery("SELECT id, question, answer, icon, isFavorite FROM Tips");
    m_tips.clear();
    while (tipQuery.next()) {
        QVariantMap tip;
        tip["id"] = tipQuery.value(0);
        tip["question"] = tipQuery.value(1);
        tip["answer"] = tipQuery.value(2);
        tip["icon"] = tipQuery.value(3);
        tip["isFavorite"] = tipQuery.value(4).toBool();

        // Загрузка тегов для совета
        QSqlQuery tagQuery;
        tagQuery.prepare("SELECT t.name FROM TipTags tt "
                         "JOIN Tags t ON tt.tagId = t.id "
                         "WHERE tt.tipId = :tipId");
        tagQuery.bindValue(":tipId", tip["id"]);
        tagQuery.exec();

        QVariantList tags;
        while (tagQuery.next()) {
            tags.append(tagQuery.value(0));
        }
        tip["tags"] = tags;

        m_tips.append(tip);
    }
    emit tipsChanged();

    updateDailyTip();
}

void TipManager::searchTips(const QString &query) {
    if (query.isEmpty()) {
        loadTips();
        return;
    }

    QString searchQuery = query.toLower();
    QVariantList filteredTips;

    for (const auto &tip : m_tips) {
        QVariantMap tipMap = tip.toMap();
        bool matches = tipMap["question"].toString().toLower().contains(searchQuery) ||
                       tipMap["answer"].toString().toLower().contains(searchQuery);

        if (!matches) {
            // Проверяем теги
            QVariantList tags = tipMap["tags"].toList();
            for (const auto &tag : tags) {
                if (tag.toString().toLower().contains(searchQuery)) {
                    matches = true;
                    break;
                }
            }
        }

        if (matches) {
            filteredTips.append(tip);
        }
    }

    m_tips = filteredTips;
    emit tipsChanged();
}

void TipManager::updateDailyTip() {
    if (m_tips.isEmpty()) return;

    // Выбираем случайный совет
    int randomIndex = QRandomGenerator::global()->bounded(m_tips.size());
    m_dailyTip = m_tips.at(randomIndex).toMap();

    // Обновляем статистику показа
    QSqlQuery query;
    query.prepare("UPDATE Tips SET lastShownDate = CURRENT_DATE, "
                  "showCount = showCount + 1 WHERE id = :id");
    query.bindValue(":id", m_dailyTip["id"]);
    query.exec();

    emit dailyTipChanged();
}

void TipManager::toggleFavorite(int tipId) {
    QSqlQuery query;
    query.prepare("UPDATE Tips SET isFavorite = NOT isFavorite WHERE id = :id");
    query.bindValue(":id", tipId);
    if (query.exec()) {
        // Обновляем локальную копию
        for (auto &tip : m_tips) {
            QVariantMap tipMap = tip.toMap();
            if (tipMap["id"].toInt() == tipId) {
                tipMap["isFavorite"] = !tipMap["isFavorite"].toBool();
                tip = tipMap;
                break;
            }
        }
        emit tipsChanged();
    }
}
