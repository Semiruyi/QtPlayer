#include "utilities.h"

#include <algorithm>
#include <QDir>
#include <QCollator>
#include <QDebug>
#include <QUrl>

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

    auto compareMethod = [](const QString& s1, const QString& s2) -> bool
    {
        QCollator collator;
        // 设置数字模式，这样会按数值比较数字部分
        collator.setNumericMode(true);
        // 设置不区分大小写（可选，根据需求）
        collator.setCaseSensitivity(Qt::CaseInsensitive);
        return collator.compare(s1, s2) < 0;
    };

    std::sort(videoFiles.begin(), videoFiles.end(), compareMethod);

    qDebug() << "ret is";
    for(const auto& str : videoFiles)
    {
        qDebug() << str;
    }

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
