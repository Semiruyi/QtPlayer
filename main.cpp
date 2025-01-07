#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "./src/cpp/PlayHistory/playhistory.h"
#include <QFile>
#include "./src/cpp/mainpage/mainpageconfig.h"
#include "./src/cpp/config/playpageconfig.h"
#include "./src/cpp/config/globalconfig.h"
#include "./src/cpp/utilities/logger/logger.h"
#include "./src/cpp/mainpage/videoprocesser.h"
#include "./src/cpp/utilities/utilities.h"
#include <QMetaType>
#include <QTranslator>

void handleAppStartWithFilePath(int argc, char *argv[], const QString& appPath,MainPageConfig* mainPageConfig)
{
    mainPageConfig->setAppStartWithPath("");
    if(argc == 1)
    {

    }
    else if(argc == 2)
    {
        qCritical() << appPath;
        QString videoFilePath = (QString::fromLocal8Bit(argv[1]));
        videoFilePath.replace("\\", "/");
        QString playFolderPath(QString::fromLocal8Bit(argv[1]));
        playFolderPath.replace("\\", "/");

        playFolderPath = playFolderPath.left(playFolderPath.lastIndexOf('/'));

        playFolderPath = "file:///" + playFolderPath;

        QStringList videoFilePaths = Utilities::getVideoFiles(videoFilePath.left(videoFilePath.lastIndexOf("/")));
        int lastPlayedEpisode = 0;
        for(int i = 0; i < videoFilePaths.size(); i++)
        {
            if(videoFilePath == videoFilePaths[i])
            {
                lastPlayedEpisode = i;
                break;
            }
        }

        int cardIndex = mainPageConfig->playCardModel()->isDataExist("path", playFolderPath);

        if(cardIndex == -1)
        {
            QJsonObject jsonObj;
            jsonObj.insert("path", playFolderPath);
            jsonObj.insert("animationTitle", playFolderPath.mid(playFolderPath.lastIndexOf('/') + 1));
            jsonObj.insert("lastPlayedEpisode", lastPlayedEpisode);
            jsonObj.insert("coverPosition", 10);
            mainPageConfig->playCardModel()->append(jsonObj);
        }
        else
        {
            mainPageConfig->playCardModel()->setData(cardIndex, "lastPlayedEpisode", lastPlayedEpisode);
        }
        mainPageConfig->setAppStartWithPath(playFolderPath);
    }
    else
    {
        qCritical() << "do not accept three or more than three args";
    }
}


int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QString appPath = ".";

    if(argc >= 1)
    {
        appPath = QString::fromLocal8Bit(argv[0]);
        appPath.replace("\\", "/");
        appPath = appPath.left(appPath.lastIndexOf('/'));
    }

    Logger::getIns()->init(appPath + "/log");

    //init play history for play page to use it
    PlayHistory* playHistory = new PlayHistory();
    engine.rootContext()->setContextProperty("qPlayHistoryConfig", playHistory); // playPage share one

    VideoProcesser* videoProcesser = new VideoProcesser();
    MyImageProvider* myImageProvider = new MyImageProvider();
    engine.rootContext()->setContextProperty("qCoverImageProvider", myImageProvider);
    videoProcesser->setMyImageProvider(myImageProvider);
    engine.rootContext()->setContextProperty("qVideoProcesser", videoProcesser);
    engine.addImageProvider(myImageProvider->name(), myImageProvider);

    MainPageConfig* mainPageConfig = new MainPageConfig(engine, QString(appPath + "/config/MainPageConfig.json"));
    PlayPageConfig* playPageConfig = new PlayPageConfig(engine, QString(appPath + "/config/PlayPageConfig.json"));
    GlobalConfig* globalConfig = new GlobalConfig(app, engine, QString(appPath + "/config/GlobalConfig.json"));
    Utilities* utilities = new Utilities();
    engine.rootContext()->setContextProperty("qUtilities", utilities);

    // handle start
    handleAppStartWithFilePath(argc, argv, appPath, mainPageConfig);

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
