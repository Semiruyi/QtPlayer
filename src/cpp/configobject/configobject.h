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

class ConfigObject : public QObject
{
    Q_OBJECT
public:
    ConfigObject(QObject* parent = nullptr);

private:
    QString m_readWriteJsonFilePath;

#pragma region "" {

public:
    void setReadWriteJsonFilePath(QString filePath)
    {
        m_readWriteJsonFilePath = filePath;
    }

#pragma endregion}

public:
    QJsonObject toJson() const;
    void fromJson(const QJsonObject &json);
    void readDataFromJson();
    void writeDataToJson();
};

#endif
