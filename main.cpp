#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "playhistory.h"
#include <QFile>

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);
    qmlRegisterType<PlayHistory>("PlayControl", 1, 0, "PlayHistory");
    QQmlApplicationEngine engine;
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
