#ifndef MAINPAGECONFIG_H
#define MAINPAGECONFIG_H

#include "../configobject/configobject.h"
#include "../PlayHistory/playhistory.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>

class MainPageConfig : public ConfigObject
{
    Q_OBJECT
public:
    MainPageConfig(QQmlApplicationEngine& engine, QString jsonPath, QObject* parent = nullptr) : ConfigObject(parent)
    {
        engine.rootContext()->setContextProperty("qMainPageConfig", this);
        setReadWriteJsonFilePath(jsonPath);
        readDataFromJson();
    }

    Q_PROPERTY(QStringList playFolderPaths READ playFolderPaths WRITE setPlayFolderPaths NOTIFY playFolderPathsChanged FINAL)
    Q_PROPERTY(QStringList titles READ titles WRITE setTitles NOTIFY titlesChanged FINAL)

    QStringList playFolderPaths() const;
    void setPlayFolderPaths(const QStringList &newPlayFolderPaths);
    QStringList titles() const;
    void setTitles(const QStringList &newTitles);

    Q_INVOKABLE void appendData(QString path, QString title)
    {
        m_playFolderPaths.append(path);
        m_titles.append(title);
    }

    Q_INVOKABLE void removeData(int index)
    {
        if(index < 0 || index >= m_playFolderPaths.length())
        {
            qCritical() << QString("index: %1 out of range. length: %2").arg(index).arg(m_playFolderPaths.length());
            return ;
        }
        m_playFolderPaths.remove(index);
        m_titles.remove(index);
    }

    Q_INVOKABLE int getWatchedCount(QString path)
    {
        int ret = 0;

        PlayHistory playHistory(this);
        playHistory.init(path);

        return playHistory.getWatchedCount();
    }

signals:
    void playFolderPathsChanged();
    void titlesChanged();

private:
    QStringList m_playFolderPaths;
    QStringList m_titles;
};

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
