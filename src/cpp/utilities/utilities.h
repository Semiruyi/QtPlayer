#ifndef UTILITIES_H
#define UTILITIES_H

#include <QObject>

class Utilities : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static QStringList getVideoFiles(const QString& folderPath);
    Q_INVOKABLE static bool checkFolderPathIsValid(const QString& path);
};

#endif // UTILITIES_H
