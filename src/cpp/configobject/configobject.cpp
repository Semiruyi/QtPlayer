#include "configobject.h"

ConfigObject::ConfigObject(QObject* parent) : QObject(parent)
{
    // auto save
    {
        m_timer = new QTimer(this);
        connect(m_timer, &QTimer::timeout, this, &ConfigObject::writeDataToJson);
        m_timer->setInterval(1000);
        m_timer->start();
    }
}

QJsonObject ConfigObject::toJson() const {
    QJsonObject json;
    const QMetaObject *metaObject = this->metaObject();
    for (int i = 0; i < metaObject->propertyCount(); ++i) {
        QMetaProperty metaProperty = metaObject->property(i);
        QString name = QString(metaProperty.name());
        if(name == QString("objectName") || m_hideProperties.contains(name))
        {
            continue;
        }

        QVariant value = metaProperty.read(this);

        if (value.typeId() == QMetaType::QStringList)
        {
            QJsonArray jsonArray;
            QStringList stringList = value.toStringList();
            for (const QString &str : stringList) {
                jsonArray.append(str);
            }
            json.insert(name, jsonArray);
        }
        else if(value.canConvert<MyListModel*>())
        {
            json.insert(name, value.value<MyListModel*>()->toJson());
        }
        else
        {
            json.insert(name, QJsonValue::fromVariant(value));
        }
    }
    return json;
}

void ConfigObject::fromJson(const QJsonObject &json) {
    const QMetaObject *metaObject = this->metaObject();
    for (int i = 0; i < metaObject->propertyCount(); ++i) {
        QMetaProperty metaProperty = metaObject->property(i);
        const QVariant & propertyValue = metaProperty.read(this);
        const char *name = metaProperty.name();
        if(m_hideProperties.contains(QString(name)))
        {
            continue;
        }
        if (json.contains(name)) {
            QJsonValue jsonValue = json[name];
            if (!jsonValue.isNull()) {
                QVariant value;
                if(metaProperty.typeId() == QMetaType::QStringList)
                {
                    QJsonArray jsonArray = jsonValue.toArray();
                    QStringList stringList;
                    for (const QJsonValue &jsonVal : jsonArray) {
                        stringList.append(jsonVal.toString());
                    }
                    value = stringList;
                    metaProperty.write(this, value);
                    return ;
                }
                else if(propertyValue.canConvert<MyListModel*>())
                {
                    // qDebug() << "enter value.canConvert<MyListModel*>()";
                    propertyValue.value<MyListModel*>()->fromJson(jsonValue.toArray());
                    metaProperty.write(this, propertyValue);
                }
                else
                {
                    value = jsonValue.toVariant();
                    metaProperty.write(this, value);
                }


            }
        }
    }
}

void ConfigObject::readDataFromJson()
{
    // 检查并创建文件路径中的所有文件夹
    QFileInfo fileInfo(m_readWriteJsonFilePath);
    QDir dir = fileInfo.dir();
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "Failed to create directory:" << dir.path();
            return;
        }
        qDebug() << "Created directory:" << dir.path();
    }

    QFile file(m_readWriteJsonFilePath);

    // 尝试打开文件进行读取
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QByteArray data = file.readAll();
        file.close();

        QJsonDocument jsonDoc = QJsonDocument::fromJson(data);
        if (!jsonDoc.isNull() && jsonDoc.isObject()) {
            this->fromJson(jsonDoc.object());
        } else {
            qWarning() << "Invalid JSON file:" << m_readWriteJsonFilePath;
        }
    } else {
        // 如果文件不存在，创建一个空的JSON文件
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            QJsonObject emptyJson;
            QJsonDocument jsonDoc(emptyJson);
            file.write(jsonDoc.toJson());
            file.close();
            qDebug() << "Created empty JSON file:" << m_readWriteJsonFilePath;
        } else {
            qWarning() << "Failed to create JSON file:" << m_readWriteJsonFilePath;
        }
    }
}

void ConfigObject::writeDataToJson() {
    // 检查并创建文件路径中的所有文件夹
    QFileInfo fileInfo(m_readWriteJsonFilePath);
    QDir dir = fileInfo.dir();
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "Failed to create directory:" << dir.path();
            return;
        }
        qDebug() << "Created directory:" << dir.path();
    }

    // 将对象序列化为JSON
    QJsonObject jsonObj = this->toJson();
    QJsonDocument jsonDoc(jsonObj);

    // 打开文件并写入JSON数据
    QFile file(m_readWriteJsonFilePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        file.write(jsonDoc.toJson());
        file.close();
        // qDebug() << "Data written to JSON file:" << m_readWriteJsonFilePath;
    } else {
        qWarning() << "Failed to open file for writing:" << m_readWriteJsonFilePath;
    }
}

void ConfigObject::hide(const QString& property)
{
    m_hideProperties.insert(property);
}
