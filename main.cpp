#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>
#include "Classes/pregnancydata.h"
#include "Classes/databasehandler.h"
#include "Classes/backupmanager.h"
int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    // Регистрируем наши C++ классы для использования в QML
    qmlRegisterType<PregnancyData>("PregnancyApp", 1, 0, "PregnancyData");
    qmlRegisterType<DatabaseHandler>("PregnancyAppData", 1, 0, "DatabaseHandler");


    // Инициализация базы данных
    DatabaseHandler dbHandler;
    if (!dbHandler.initializeDatabase()) {
        qWarning() << "Failed to initialize database";
    }

    try {
        dbHandler.scheduleBackups(24); // Каждые 24 часа
    } catch (const std::exception &e) {
        qCritical() << "Failed to schedule backups:" << e.what();
    } catch (...) {
        qCritical() << "Unknown error during backup scheduling";
    }

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
