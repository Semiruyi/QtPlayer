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

class MyConfig : public ConfigObject
{
    Q_OBJECT
    Q_PROPERTY(double size READ size WRITE setSize NOTIFY sizeChanged FINAL)


    public:
        double size() const;
        void setSize(double newSize);

    signals:
        void sizeChanged();

    private:
        double m_size = 10086;
};
