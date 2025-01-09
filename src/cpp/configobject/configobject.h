#ifndef CONFIGOBJECT_H
#define CONFIGOBJECT_H


#include <QCoreApplication>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QString>
#include <QMetaObject>
#include <QMetaProperty>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QJsonArray>
#include <QTimer>
#include <QSet>

class ConfigObject : public QObject
{
    Q_OBJECT
public:
    ConfigObject(QObject* parent = nullptr);

private:
    QString m_readWriteJsonFilePath;
    QSet<QString> m_hideProperties;
    QSet<QString> m_QObjectSignals = {
        QString("destroyed(QObject*)"),
        QString("destroyed()"),
        QString("objectNameChanged(QString)")
    };

#pragma region "" {

public:
    void setReadWriteJsonFilePath(QString filePath)
    {
        m_readWriteJsonFilePath = filePath;
    }

#pragma endregion}

public:
    QJsonObject toJson() const;
    void init();
    void init(const QString& savePath);
    void fromJson(const QJsonObject &json);
    void readDataFromJson();
    Q_INVOKABLE void writeDataToJson();
    void hide(const QString& property);
private:
    void connectPropertyChangedSignalAndWriteDataToJson();
};

Q_DECLARE_METATYPE(ConfigObject)

#endif
