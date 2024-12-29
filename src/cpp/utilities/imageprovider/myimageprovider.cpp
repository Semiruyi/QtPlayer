#include "myimageprovider.h"

// MyImageProvider::MyImageProvider()
// {

// }

bool MyImageProvider::isImageExist(QString videoFilePath, long long position)
{
    qDebug() << "start width videoFilePath:" << videoFilePath << "postion:" << position;
    bool ret = false;
    QString id = videoFilePath + QString::number(position);
    if(m_imageMap.contains(id))
    {
        ret = true;
    }
    qDebug() << "end";
    return ret;
}

void MyImageProvider::insert(QString videoFilePath, long long position, QImage image)
{
    qDebug() << "start width videoFilePath:" << videoFilePath << "postion:" << position;
    QString id = makeId(videoFilePath, position);
    m_imageMap.insert(id, image);
    qDebug() << "end";
}

QString MyImageProvider::getImage(QString videoFilePath, long long position)
{
    qDebug() << "start width videoFilePath:" << videoFilePath << "postion:" << position;
    QString ret;
    QString id = makeId(videoFilePath, position);
    if(m_imageMap.contains(id))
    {
        ret = getImagePathById(id);
    }
    else
    {
        qDebug() << "no such image existed";
    }
    qDebug() << "end with ret:" << ret;
    return ret;
}

QString MyImageProvider::getImagePathById(const QString& id)
{
    return m_prefix + id;
}

QString MyImageProvider::makeId(const QString& path, long long position)
{
    QString ret = path + "/" + QString::number(position);
    return ret;
}
