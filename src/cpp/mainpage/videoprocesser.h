#ifndef VIDEOPROCESSER_H
#define VIDEOPROCESSER_H

#include <QSharedPointer>
#include <QDebug>
#include <QMap>
#include <QFile>
#include <QDir>
#include "../utilities/exception/myexception.h"
#include "../utilities/imageprovider/myimageprovider.h"

extern "C"
{
#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/imgutils.h>
#include <libswscale/swscale.h>
#include <libavutil/time.h>
}

class VideoProcesser : public QObject
{
    Q_OBJECT
public:
    VideoProcesser();

    QImage getFrame(QString videoFilePath, long long position);

    QStringList getVideoFiles(const QString &folderPath);

    Q_INVOKABLE QString qmlGetFrame(QString videoFilePath, long long position, bool isFolder = false);

    void setMyImageProvider(MyImageProvider* myImageProvider)
    {
        m_myImageProvider = myImageProvider;
    }
private:
    QMap<QString, QSharedPointer<QImage>> m_imageMap;
    MyImageProvider* m_myImageProvider;
};


#endif // VIDEOPROCESSER_H
