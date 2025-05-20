// articlemanager.h
#pragma once

#include <QObject>
#include <QVariantMap>
#include <QVariantList>

class ArticleManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList articles READ articles NOTIFY articlesChanged)
    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(QVariantMap dailyArticle READ dailyArticle NOTIFY dailyArticleChanged)

public:
    explicit ArticleManager(QObject *parent = nullptr);

    QVariantList articles() const;
    QVariantList categories() const;
    QVariantMap dailyArticle() const;

    Q_INVOKABLE void loadArticles();
    Q_INVOKABLE void searchArticles(const QString &query);
    Q_INVOKABLE void updateDailyArticle();
    Q_INVOKABLE void toggleFavorite(int articleId);

signals:
    void articlesChanged();
    void categoriesChanged();
    void dailyArticleChanged();

private:
    QVariantList m_articles;
    QVariantList m_categories;
    QVariantMap m_dailyArticle;
};
