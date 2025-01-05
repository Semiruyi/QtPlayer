#ifndef GLOBALCONFIG_H
#define GLOBALCONFIG_H

#include "../configobject/configobject.h"
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include <QGuiApplication>

class GlobalConfig : public ConfigObject
{
    Q_OBJECT
    Q_PROPERTY(double radius READ radius WRITE setRadius NOTIFY radiusChanged FINAL)
    Q_PROPERTY(int animationDuration READ animationDuration WRITE setAnimationDuration NOTIFY animationDurationChanged FINAL)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged FINAL)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged FINAL)

private:

    QTranslator m_translator;

    QGuiApplication& m_app;
    QQmlApplicationEngine& m_engine;

    double m_radius = 10;          // pixel

    int m_animationDuration = 200; // ms

    QString m_theme = "dark";

    QString m_language = "";

public:
    GlobalConfig(QGuiApplication& app, QQmlApplicationEngine& engine, QString jsonPath, QObject* parent = nullptr) :
        m_app(app),
        m_engine(engine),
        ConfigObject(parent)
    {
        engine.rootContext()->setContextProperty("qGlobalConfig", this);
        setReadWriteJsonFilePath(jsonPath);
        readDataFromJson();
        onLanguageChanged();
        connect(this, &GlobalConfig::languageChanged, this, &GlobalConfig::onLanguageChanged);
    }

    double radius() const;
    void setRadius(double newRadius);

    int animationDuration() const;
    void setAnimationDuration(int newAnimationDuration);

    QString theme() const;
    void setTheme(const QString &newTheme);

    QString language() const;
    void setLanguage(const QString &newLanguage);

signals:

    void radiusChanged();
    void animationDurationChanged();
    void themeChanged();
    void languageChanged();

private slots:
    void onLanguageChanged()
    {
        qDebug() << "start switch language: " << m_language;

        QString qmPath = "";
        m_app.removeTranslator(&m_translator);
        if(m_language == "chinese")
        {
            qmPath = ":/translation/QtPlayer_chinese.qm";
        }

        if(qmPath != "")
        {
            qDebug() << "here" << qmPath;
            if(!m_translator.load(":/translation/QtPlayer_chinese.qm", m_app.applicationDirPath()))
            {
                qCritical() << "translation load failed";
            }
            else
            {
                qDebug() << "install";
                m_app.installTranslator(&m_translator);
                m_engine.retranslate();
            }
        }
        qDebug() << "end";
    }
};

inline QString GlobalConfig::language() const
{
    return m_language;
}

inline void GlobalConfig::setLanguage(const QString &newLanguage)
{
    if (m_language == newLanguage)
        return;
    m_language = newLanguage;
    emit languageChanged();
}

inline QString GlobalConfig::theme() const
{
    return m_theme;
}

inline void GlobalConfig::setTheme(const QString &newTheme)
{
    if (m_theme == newTheme)
        return;
    m_theme = newTheme;
    emit themeChanged();
}

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
