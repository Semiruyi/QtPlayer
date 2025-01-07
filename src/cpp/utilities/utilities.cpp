#include "utilities.h"

#include <QDebug>
#include <QUrl>
#include <QDir>

QStringList Utilities::getVideoFiles(const QString& folderPath)
{
    qDebug() << "start with folderPath:" << folderPath;
    QStringList videoFiles;

    QString localPath = folderPath;
    if (folderPath.startsWith("file:///")) {
        QUrl url(folderPath);
        localPath = url.toLocalFile();
    }

    QDir dir(localPath);

    dir.setFilter(QDir::Files);

    QStringList videoFilters;
    videoFilters << "*.mp4" << "*.avi" << "*.mkv" << "*.mov" << "*.flv" << "*.wmv";

    QFileInfoList fileList = dir.entryInfoList(videoFilters);

    for (const QFileInfo &fileInfo : fileList) {
        videoFiles.append(fileInfo.absoluteFilePath());
    }

    auto compareMethod = [](const QString& str1, const QString& str2) -> bool
    {
        bool ret = false;

        QString v1, v2;

        bool isLeadZero = true;

        for(int i = 0; i < str1.size(); i++)
        {
            if(isLeadZero && str1[i] == '0')
            {
                continue;
            }
            if(str1[i] >= '0' && str1[i] <= '9')
            {
                v1 += str1[i];
                isLeadZero = false;
            }
        }

        isLeadZero = true;

        for(int i = 0; i < str2.size(); i++)
        {
            if(isLeadZero && str2[i] == '0')
            {
                continue;
            }
            if(str2[i] >= '0' && str2[i] <= '9')
            {
                v2 += str2[i];
                isLeadZero = false;
            }
        }

        if(v1.size() != v2.size())
        {
            ret = v1.size() < v2.size();
        }
        else
        {
            ret = v1 < v2;
        }

        return ret;
    };

    std::sort(videoFiles.begin(), videoFiles.end(), compareMethod);

    // qDebug() << "ret is";
    // for(const auto& str : videoFiles)
    // {
    //     qDebug() << str;
    // }

    qDebug() << "end";

    return videoFiles;
}


bool Utilities::checkFolderPathIsValid(const QString& path)
{
    qDebug() << "start with path:" << path;
    bool ret = false;
    QString cleanedPath = path;

    if (cleanedPath.startsWith("file:///")) {
        cleanedPath = QUrl(path).toLocalFile();
    }

    QDir dir(cleanedPath);
    ret = dir.exists();
    qDebug() << "end with ret:" << ret;
    return ret;
}
