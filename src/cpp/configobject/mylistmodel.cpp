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

QHash<int, QByteArray> MyListModel::roleNames() const
{
    qDebug() << "call roleNames";
    return m_roles;
}

void MyListModel::append(const QJsonObject &json)
{
    beginInsertRows(QModelIndex(), m_data.size(), m_data.size());
    m_data.append(json); // 直接添加 JSON 对象
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
    m_data.clear();
    for(const QJsonValue& jsonValue : jsonArr)
    {
        qDebug() << jsonValue;
        m_data.append(jsonValue.toObject());
    }
}
