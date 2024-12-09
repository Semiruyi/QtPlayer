#ifndef PLAYPAGECONFIG_H
#define PLAYPAGECONFIG_H

#include "../configobject/configobject.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>

class PlayPageConfig : public ConfigObject
{
    Q_OBJECT
    Q_PROPERTY(int autoHideInterval READ autoHideInterval WRITE setAutoHideInterval NOTIFY autoHideIntervalChanged FINAL)

private:
    int m_autoHideInterval = 1500; // ms

public:
    PlayPageConfig(QQmlApplicationEngine& engine, QString jsonPath, QObject* parent = nullptr) : ConfigObject(parent)
    {
        engine.rootContext()->setContextProperty("qPagePageConfig", this);
        setReadWriteJsonFilePath(jsonPath);
        readDataFromJson();

        connect(this, &PlayPageConfig::autoHideIntervalChanged, this, &PlayPageConfig::writeDataToJson);
    }

    int autoHideInterval() const;
    void setAutoHideInterval(int newAutoHideInterval);

signals:
    void autoHideIntervalChanged();

};

inline int PlayPageConfig::autoHideInterval() const
{
    return m_autoHideInterval;
}

inline void PlayPageConfig::setAutoHideInterval(int newAutoHideInterval)
{
    if (m_autoHideInterval == newAutoHideInterval)
        return;
    m_autoHideInterval = newAutoHideInterval;
    emit autoHideIntervalChanged();
}

#endif
