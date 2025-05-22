// main.cpp
#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include "Classes/databasemanager.h"
#include "Classes/profile.h"
#include "Classes/pregnancyprogress.h"
#include "Classes/pregnancyweek.h"
#include "Classes/dailytip.h"
#include "Classes/productmanager.h"
#include "Classes/checklistmanager.h"
#include "Classes/tipmanager.h"
#include "Classes/articlemanager.h"
#include "Classes/weightmanager.h"
#include "Classes/fetalkickmanager.h"
#include "Classes/dietmanager.h"
#include "Classes/analysismanager.h"
#include "Classes/pregnancycalendarmanager.h"

int main(int argc, char *argv[])
{
    QFontDatabase::addApplicationFont(":/fonts/Comfortaa-VariableFont_wght.ttf");

    QApplication app(argc, argv);


    // Инициализация базы данных
    if (!DatabaseManager::instance().initialize()) {
        qCritical() << "Failed to initialize database!";
        return -1;
    }



    // Регистрация типов для QML
    qmlRegisterType<Profile>("PregnancyApp", 1, 0, "Profile");
    qmlRegisterType<PregnancyProgress>("PregnancyApp", 1, 0, "PregnancyProgress");
    qmlRegisterType<PregnancyWeek>("PregnancyApp", 1, 0, "PregnancyWeek");
    qmlRegisterType<DailyTip>("PregnancyApp", 1, 0, "DailyTip");
    qmlRegisterType<ProductManager>("PregnancyApp", 1, 0, "ProductManager");
    qmlRegisterType<ChecklistManager>("PregnancyApp", 1, 0, "ChecklistManager");
    qmlRegisterType<TipManager>("PregnancyApp", 1, 0, "TipManager");
    qmlRegisterType<ArticleManager>("PregnancyApp", 1, 0, "ArticleManager");
    qmlRegisterType<WeightManager>("PregnancyApp", 1, 0, "WeightManager");
    qmlRegisterType<FetalKickManager>("PregnancyApp", 1, 0, "FetalKickManager");
    qmlRegisterType<DietManager>("PregnancyApp", 1, 0, "DietManager");
    qmlRegisterType<AnalysisManager>("PregnancyApp", 1, 0, "AnalysisManager");
    qmlRegisterType<PregnancyCalendarManager>("PregnancyApp", 1, 0, "PregnancyCalendarManager");

    QQmlApplicationEngine engine;

    // Получаем текущий профиль (пример)
    Profile* profile = Profile::getProfile(1);
    if (profile) {
        engine.rootContext()->setContextProperty("currentProfile", profile);

    }
    PregnancyCalendarManager pregnancyCalendarManager;
    engine.rootContext()->setContextProperty("pregnancyCalendarManager", &pregnancyCalendarManager);


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
