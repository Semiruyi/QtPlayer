#ifndef MAINPAGECONFIG_H
#define MAINPAGECONFIG_H

#include "../configobject/configobject.h"
#include "../PlayHistory/playhistory.h"
#include "playcardmodel.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>

class MainPageConfig : public ConfigObject
{
    Q_OBJECT
public:
    MainPageConfig(QQmlApplicationEngine& engine, QString jsonPath, QObject* parent = nullptr) : ConfigObject(parent)
    {
        m_playCardModel = new PlayCardModel();
        hide("titles");
        hide("playFolderPaths");
        setReadWriteJsonFilePath(jsonPath);
        readDataFromJson();
        engine.rootContext()->setContextProperty("qMainPageConfig", this);
    }

    Q_PROPERTY(QStringList playFolderPaths READ playFolderPaths WRITE setPlayFolderPaths NOTIFY playFolderPathsChanged FINAL)
    Q_PROPERTY(QStringList titles READ titles WRITE setTitles NOTIFY titlesChanged FINAL)
    Q_PROPERTY(PlayCardModel* playCardModel READ playCardModel)
    Q_PROPERTY(QString lastOpenedFolder READ lastOpenedFolder WRITE setLastOpenedFolder NOTIFY lastOpenedFolderChanged FINAL)

    QStringList playFolderPaths() const;
    void setPlayFolderPaths(const QStringList &newPlayFolderPaths);
    QStringList titles() const;
    void setTitles(const QStringList &newTitles);

    Q_INVOKABLE int getWatchedCount(QString path)
    {

        qDebug() << "start" << "with path:" << path;

        int ret = 0;

        PlayHistory playHistory(this);
        playHistory.init(path);

        ret = playHistory.getWatchedCount();

        playHistory.colseDatabase();

        qDebug() << "end";

        return ret;
    }

    Q_INVOKABLE bool checkFolderPathIsValid(const QString& path)
    {
        qDebug() << "start with path:" << path;
        bool ret = false;
        QString cleanedPath = path;

        if (cleanedPath.startsWith("file:///")) {
            cleanedPath = QUrl(path).toLocalFile();
        }

        QDir dir(cleanedPath);
        ret = dir.exists();
        qDebug() << "end with ret:" << ret;
        return ret;
    }

    PlayCardModel *playCardModel() const;

    QString lastOpenedFolder() const;
    void setLastOpenedFolder(const QString &newLastOpenedFolder);

signals:
    void playFolderPathsChanged();
    void titlesChanged();

    void lastOpenedFolderChanged();

private:
    QStringList m_playFolderPaths;
    QStringList m_titles;
    PlayCardModel *m_playCardModel = nullptr;
    QString m_lastOpenedFolder = "";
};

inline QString MainPageConfig::lastOpenedFolder() const
{
    return m_lastOpenedFolder;
}

inline void MainPageConfig::setLastOpenedFolder(const QString &newLastOpenedFolder)
{
    if (m_lastOpenedFolder == newLastOpenedFolder)
        return;
    m_lastOpenedFolder = newLastOpenedFolder;
    emit lastOpenedFolderChanged();
}

inline PlayCardModel *MainPageConfig::playCardModel() const
{
    return m_playCardModel;
}

inline QStringList MainPageConfig::titles() const
{
    return m_titles;
}

inline void MainPageConfig::setTitles(const QStringList &newTitles)
{
    if (m_titles == newTitles)
        return;
    m_titles = newTitles;
    emit titlesChanged();
}

inline QStringList MainPageConfig::playFolderPaths() const
{
    return m_playFolderPaths;
}

inline void MainPageConfig::setPlayFolderPaths(const QStringList &newPlayFolderPaths)
{
    if (m_playFolderPaths == newPlayFolderPaths)
        return;
    m_playFolderPaths = newPlayFolderPaths;
    // writeDataToJson();
    emit playFolderPathsChanged();
}


#endif // MAINPAGECONFIG_H
