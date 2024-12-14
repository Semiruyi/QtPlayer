#ifndef GLOBALCONFIG_H
#define GLOBALCONFIG_H

#include "../configobject/configobject.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>

class GlobalConfig : public ConfigObject
{
    Q_OBJECT
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged FINAL)
    Q_PROPERTY(int animationDuration READ animationDuration WRITE setAnimationDuration NOTIFY animationDurationChanged FINAL)

private:

    double m_radius = 10;          // pixel

    int m_animationDuration = 200; // ms

public:
    GlobalConfig(QQmlApplicationEngine& engine, QString jsonPath, QObject* parent = nullptr) : ConfigObject(parent)
    {
        engine.rootContext()->setContextProperty("qGlobalConfig", this);
        setReadWriteJsonFilePath(jsonPath);
        readDataFromJson();
    }

    double radius() const;
    void setRadius(double newRadius);

    int animationDuration() const;
    void setAnimationDuration(int newAnimationDuration);

signals:

    void radiusChanged();
    void animationDurationChanged();
};

inline int GlobalConfig::animationDuration() const
{
    return m_animationDuration;
}

inline void GlobalConfig::setAnimationDuration(int newAnimationDuration)
{
    if (m_animationDuration == newAnimationDuration)
        return;
    m_animationDuration = newAnimationDuration;
    emit animationDurationChanged();
}

inline double GlobalConfig::radius() const
{
    return m_radius;
}

inline void GlobalConfig::setRadius(double newRadius)
{
    if (qFuzzyCompare(m_radius, newRadius))
        return;
    m_radius = newRadius;
    emit radiusChanged();
}



#endif // GLOBALCONFIG_H
