#include "mylistmodel.h"

MyListModel::MyListModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

void MyListModel::init() {
    QJsonObject json;
    const QMetaObject *metaObject = this->metaObject();
    for (int i = 0; i < metaObject->propertyCount(); ++i) {
        QMetaProperty metaProperty = metaObject->property(i);
        QString name = QString(metaProperty.name());
        //qDebug() << "q property name " << name;
        if(name == QString("objectName"))
        {
            continue;
        }
        m_roles[Qt::UserRole + i + 1] = metaProperty.name();
        m_keys.insert(QString(name));
        // qDebug() << "m_roles: " << (Qt::UserRole + i + 1) << "metaProperty.name(): " << metaProperty.name();
    }
}

int MyListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_data.size();
}

QVariant MyListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_data.size())
        return QVariant();

    const QJsonObject &item = m_data.at(index.row());

    return item[m_roles[role]].toVariant();
}

void MyListModel::setData(const int index, QString key, QJsonValue jsonValue)
{
    if(index >= m_data.size() || index < 0)
    {
        qCritical() << "In" << this->metaObject()->className() << "call void MyListModel::setData(const int index, QString key, QVariant value)";
        qCritical() << QString("index out of range! size: %1, index %2").arg(m_data.size()).arg(index);
        return ;
    }
    if(m_data[index].find(key) == m_data[index].end())
    {
        qCritical() << "In void MyListModel::setData(const int index, QString key, QVariant value)";
        qCritical() << "Do not find key: " << key << "in" << this->metaObject()->className();
        return ;
    }
    m_data[index].insert(key, jsonValue);
}

QHash<int, QByteArray> MyListModel::roleNames() const
{
    return m_roles;
}

void MyListModel::append(const QJsonObject &json)
{
    if(json.size() != m_keys.size())
    {
        qCritical() << "append failed!" << this->metaObject()->className() << "you put in keys count is not equal with this model keys!";
        return ;
    }
    for (const QString &key : json.keys())
    {
        if(!m_keys.contains(key))
        {
            qCritical() << "append failed!" << this->metaObject()->className() << "do not have key:" << key;
            return ;
        }
    }
    beginInsertRows(QModelIndex(), m_data.size(), m_data.size());
    m_data.append(json);
    endInsertRows();
}

void MyListModel::remove(int index)
{
    if (index < 0 || index >= m_data.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_data.removeAt(index);
    endRemoveRows();
}

void MyListModel::move(int from, int to)
{
    if (from < 0 || from >= m_data.size() || to < 0 || to >= m_data.size() || from == to)
        return;

    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to > from ? to + 1 : to);
    m_data.move(from, to);
    endMoveRows();
}

QJsonArray MyListModel::toJson()
{
    QJsonArray jsonArr;
    for(const auto& jsonObject : m_data)
    {
        jsonArr.append(jsonObject);
    }
    return jsonArr;
}

void MyListModel::fromJson(const QJsonArray& jsonArr)
{
    qDebug() << "start";
    m_data.clear();
    for(const QJsonValue& jsonValue : jsonArr)
    {
        QJsonObject jsonObject = jsonValue.toObject();
        for(const QString& key : m_keys)
        {
            if(jsonObject.find(key) == jsonObject.end())
            {
                const QMetaObject* metaObject = this->metaObject();
                int propertyIndex = metaObject->indexOfProperty(key.toUtf8().constData());

                if (propertyIndex != -1) {
                    QMetaProperty metaProperty = metaObject->property(propertyIndex);
                    QVariant value = metaProperty.read(this);
                    jsonObject.insert(key, QJsonValue(QJsonValue::fromVariant(value)));
                    qDebug() << "Property" << key << "value:" << value;
                } else {
                    qDebug() << "Property" << key << "not found!";
                }
            }
        }
        m_data.append(jsonObject);
    }
    qDebug() << "end";
}
