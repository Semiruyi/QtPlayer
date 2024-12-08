#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "./src/cpp/PlayHistory/playhistory.h"
#include <QFile>
#include "./src/cpp/configobject/configobject.h"

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    //init play history for play page to use it
    PlayHistory* playHistory = new PlayHistory(engine);

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
