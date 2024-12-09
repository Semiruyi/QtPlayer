#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "./src/cpp/PlayHistory/playhistory.h"
#include <QFile>
#include "./src/cpp/mainpage/mainpageconfig.h"
#include "./src/cpp/config/playpageconfig.h"

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    //init play history for play page to use it
    PlayHistory* playHistory = new PlayHistory(engine);

    MainPageConfig* mainPageConfig = new MainPageConfig(engine, QString("./config/MainPageConfig.json"));
    PlayPageConfig* playPageConfig = new PlayPageConfig(engine, QString("./config/PlayPageConfig.json"));

    const QUrl url(QStringLiteral("qrc:/QtPlayer/src/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
