#ifndef MAINPAGECONFIG_H
#define MAINPAGECONFIG_H

#include "../configobject/configobject.h"
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
    QStringList playFolderPaths() const;
    void setPlayFolderPaths(const QStringList &newPlayFolderPaths);
signals:
    void playFolderPathsChanged();
private:
    QStringList m_playFolderPaths;
};

inline QStringList MainPageConfig::playFolderPaths() const
{
    return m_playFolderPaths;
}

inline void MainPageConfig::setPlayFolderPaths(const QStringList &newPlayFolderPaths)
{
    if (m_playFolderPaths == newPlayFolderPaths)
        return;
    m_playFolderPaths = newPlayFolderPaths;
    writeDataToJson();
    emit playFolderPathsChanged();
}


#endif // MAINPAGECONFIG_H
