// articlemanager.cpp
#include "articlemanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QRandomGenerator>

ArticleManager::ArticleManager(QObject *parent) : QObject(parent)
{
    loadArticles();
}

QVariantList ArticleManager::articles() const {
    return m_articles;
}

QVariantList ArticleManager::categories() const {
    return m_categories;
}

QVariantMap ArticleManager::dailyArticle() const {
    return m_dailyArticle;
}

void ArticleManager::loadArticles() {
    // Загрузка категорий
    QSqlQuery categoryQuery("SELECT id, name, icon FROM ArticleCategories");
    m_categories.clear();
    while (categoryQuery.next()) {
        QVariantMap category;
        category["id"] = categoryQuery.value(0);
        category["name"] = categoryQuery.value(1);
        category["icon"] = categoryQuery.value(2);
        m_categories.append(category);
    }
    emit categoriesChanged();

    // Загрузка статей
    QSqlQuery articleQuery("SELECT id, title, content, icon, source, isFavorite, readTimeMinutes FROM Articles");
    m_articles.clear();
    while (articleQuery.next()) {
        QVariantMap article;
        article["id"] = articleQuery.value(0);
        article["title"] = articleQuery.value(1);
        article["content"] = articleQuery.value(2);
        article["icon"] = articleQuery.value(3);
        article["source"] = articleQuery.value(4);
        article["isFavorite"] = articleQuery.value(5).toBool();
        article["readTimeMinutes"] = articleQuery.value(6);

        // Загрузка категорий для статьи
        QSqlQuery categoryQuery;
        categoryQuery.prepare("SELECT c.name FROM ArticleCategoryRelations acr "
                              "JOIN ArticleCategories c ON acr.categoryId = c.id "
                              "WHERE acr.articleId = :articleId");
        categoryQuery.bindValue(":articleId", article["id"]);
        categoryQuery.exec();

        QVariantList categories;
        while (categoryQuery.next()) {
            categories.append(categoryQuery.value(0));
        }
        article["categories"] = categories;

        // Загрузка тегов для статьи
        QSqlQuery tagQuery;
        tagQuery.prepare("SELECT t.name FROM ArticleTags at "
                         "JOIN Tags t ON at.tagId = t.id "
                         "WHERE at.articleId = :articleId");
        tagQuery.bindValue(":articleId", article["id"]);
        tagQuery.exec();

        QVariantList tags;
        while (tagQuery.next()) {
            tags.append(tagQuery.value(0));
        }
        article["tags"] = tags;

        m_articles.append(article);
    }
    emit articlesChanged();

    updateDailyArticle();
}

void ArticleManager::searchArticles(const QString &query) {
    if (query.isEmpty()) {
        loadArticles();
        return;
    }

    QString searchQuery = query.toLower();
    QVariantList filteredArticles;

    for (const auto &article : m_articles) {
        QVariantMap articleMap = article.toMap();
        bool matches = articleMap["title"].toString().toLower().contains(searchQuery) ||
                       articleMap["content"].toString().toLower().contains(searchQuery);

        if (!matches) {
            // Проверяем категории
            QVariantList categories = articleMap["categories"].toList();
            for (const auto &category : categories) {
                if (category.toString().toLower().contains(searchQuery)) {
                    matches = true;
                    break;
                }
            }
        }

        if (!matches) {
            // Проверяем теги
            QVariantList tags = articleMap["tags"].toList();
            for (const auto &tag : tags) {
                if (tag.toString().toLower().contains(searchQuery)) {
                    matches = true;
                    break;
                }
            }
        }

        if (matches) {
            filteredArticles.append(article);
        }
    }

    m_articles = filteredArticles;
    emit articlesChanged();
}

void ArticleManager::updateDailyArticle() {
    if (m_articles.isEmpty()) return;

    // Выбираем случайную статью
    int randomIndex = QRandomGenerator::global()->bounded(m_articles.size());
    m_dailyArticle = m_articles.at(randomIndex).toMap();

    // Обновляем статистику показа
    QSqlQuery query;
    query.prepare("UPDATE Articles SET lastShownDate = CURRENT_DATE, "
                  "showCount = COALESCE(showCount, 0) + 1 WHERE id = :id");
    query.bindValue(":id", m_dailyArticle["id"]);
    query.exec();

    emit dailyArticleChanged();
}

void ArticleManager::toggleFavorite(int articleId) {
    QSqlQuery query;
    query.prepare("UPDATE Articles SET isFavorite = NOT isFavorite WHERE id = :id");
    query.bindValue(":id", articleId);
    if (query.exec()) {
        // Обновляем локальную копию
        for (auto &article : m_articles) {
            QVariantMap articleMap = article.toMap();
            if (articleMap["id"].toInt() == articleId) {
                articleMap["isFavorite"] = !articleMap["isFavorite"].toBool();
                article = articleMap;
                break;
            }
        }
        emit articlesChanged();
    }
}
