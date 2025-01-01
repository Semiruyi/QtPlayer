#ifndef MYIMAGEPROVIDER_H
#define MYIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QSharedPointer>
#include <QImage>
#include <QMap>
#include <QDebug>
#include "../exception/myexception.h"

class MyImageProvider : public QQuickImageProvider {
    Q_OBJECT
public:
    MyImageProvider() : QQuickImageProvider(QQuickImageProvider::Image) {}

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override {
        qDebug() << "start with id:" << id;
        if (m_imageMap.contains(id)) {
            QImage image = m_imageMap[id];
            qDebug() << "end S";
            return image;
        }
        qDebug() << "end E";
        return QImage("qrc:/resources/icons/atrly.png"); // default image
    }

    bool isImageExist(QString videoFilePath, long long position);
    void insert(QString videoFilePath, long long position, QImage image);
    Q_INVOKABLE void removeImage(const QString& imageProviderSource);
    QString getImage(QString videoFilePath, long long position);
    QString name(){
        return m_name;
    }
private:
    QString getImagePathById(const QString& id);
    QString makeId(const QString& path, long long position);
    QMap<QString, QImage> m_imageMap;
    QString m_name = "covers";
    QString m_prefix = "image://" + m_name + "/";
};
#endif // MYIMAGEPROVIDER_H
