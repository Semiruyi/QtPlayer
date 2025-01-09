#ifndef PLAYPAGECONFIG_H
#define PLAYPAGECONFIG_H

#include "../configobject/configobject.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>

class PlayPageConfig : public ConfigObject
{
    Q_OBJECT
    Q_PROPERTY(int autoHideInterval READ autoHideInterval WRITE setAutoHideInterval NOTIFY autoHideIntervalChanged FINAL)
    Q_PROPERTY(bool autoPlay READ autoPlay WRITE setAutoPlay NOTIFY autoPlayChanged FINAL)
    Q_PROPERTY(bool animationFirst READ animationFirst WRITE setAnimationFirst NOTIFY animationFirstChanged FINAL) // unused

private:
    int m_autoHideInterval = 1500; // ms

    bool m_autoPlay = true;

    bool m_animationFirst = true;

public:
    PlayPageConfig(QQmlApplicationEngine& engine, QString jsonPath, QObject* parent = nullptr) : ConfigObject(parent)
    {
        engine.rootContext()->setContextProperty("qPlayPageConfig", this);
        hide("animationFirst");
        init(jsonPath);
    }

    int autoHideInterval() const;
    void setAutoHideInterval(int newAutoHideInterval);

    bool autoPlay() const;
    void setAutoPlay(bool newAutoPlay);

    bool animationFirst() const;
    void setAnimationFirst(bool newAnimationFirst);

signals:
    void autoHideIntervalChanged();

    void autoPlayChanged();
    void animationFirstChanged();
};

inline bool PlayPageConfig::animationFirst() const
{
    return m_animationFirst;
}

inline void PlayPageConfig::setAnimationFirst(bool newAnimationFirst)
{
    if (m_animationFirst == newAnimationFirst)
        return;
    m_animationFirst = newAnimationFirst;
    emit animationFirstChanged();
}

inline bool PlayPageConfig::autoPlay() const
{
    return m_autoPlay;
}

inline void PlayPageConfig::setAutoPlay(bool newAutoPlay)
{
    if (m_autoPlay == newAutoPlay)
        return;
    m_autoPlay = newAutoPlay;
    emit autoPlayChanged();
}

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
