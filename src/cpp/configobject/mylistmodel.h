#ifndef MYLISTMODEL_H
#define MYLISTMODEL_H

#include <QAbstractListModel>
#include <QJsonObject>
#include <QVector>
#include <QHash>
#include <QByteArray>
#include <QMetaObject>
#include <QMetaProperty>
#include <QDebug>
#include <QJsonArray>
#include <QSet>

class MyListModel : public QAbstractListModel
{
    Q_OBJECT

public:

    MyListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void append(const QJsonObject &json); // 修改为接受 QJsonObject
    Q_INVOKABLE void setData(const int index, QString key, QJsonValue josnValue);
    Q_INVOKABLE void remove(int index);
    Q_INVOKABLE void move(int from, int to);
    Q_INVOKABLE QJsonArray toJson();
    Q_INVOKABLE void fromJson(const QJsonArray& jsonArr);

    // this method must be called before use model
    void init();


    MyListModel(const MyListModel &other) : QAbstractListModel(other.parent())
    {
        // 复制内部数据
        m_data = other.m_data;
    }

    // 手动实现赋值操作符
    MyListModel &operator=(const MyListModel &other)
    {
        if (this != &other) {
            m_data = other.m_data;
        }
        return *this;
    }

private:
    QVector<QJsonObject> m_data; // 使用 QJsonObject 存储数据
    QHash<int, QByteArray> m_roles;
    QSet<QString> m_keys;
};

#endif // MYLISTMODEL_H
