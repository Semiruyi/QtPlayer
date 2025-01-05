#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "./src/cpp/PlayHistory/playhistory.h"
#include <QFile>
#include "./src/cpp/mainpage/mainpageconfig.h"
#include "./src/cpp/config/playpageconfig.h"
#include "./src/cpp/config/globalconfig.h"
#include "./src/cpp/utilities/logger/logger.h"
#include "./src/cpp/mainpage/videoprocesser.h"
#include <QMetaType>
#include <QTranslator>

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    Logger::getIns()->init();

    //init play history for play page to use it
    PlayHistory* playHistory = new PlayHistory();
    engine.rootContext()->setContextProperty("qPlayHistoryConfig", playHistory); // playPage share one

    VideoProcesser* videoProcesser = new VideoProcesser();
    MyImageProvider* myImageProvider = new MyImageProvider();
    engine.rootContext()->setContextProperty("qCoverImageProvider", myImageProvider);
    videoProcesser->setMyImageProvider(myImageProvider);
    engine.rootContext()->setContextProperty("qVideoProcesser", videoProcesser);
    engine.addImageProvider(myImageProvider->name(), myImageProvider);

    MainPageConfig* mainPageConfig = new MainPageConfig(engine, QString("./config/MainPageConfig.json"));
    PlayPageConfig* playPageConfig = new PlayPageConfig(engine, QString("./config/PlayPageConfig.json"));
    GlobalConfig* globalConfig = new GlobalConfig(app, engine, QString("./config/GlobalConfig.json"));

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
