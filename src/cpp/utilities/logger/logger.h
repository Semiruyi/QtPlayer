#ifndef LOGGER_H
#define LOGGER_H

#pragma region "include" {

#include <QDateTime>
#include <QThread>
#include <QFileInfo>
#include <iostream>
#include <QDir>

#pragma endregion }

#pragma region "define" {

    #define DTF_Normal                       "yyyy-MM-dd hh:mm:ss.zzz"
    #define DTF_Error                        "yyyy-MM-dd_hh:mm:ss.zzz"
    #define DTF_ForFileNameWithMS            "yyyy-MM-dd_hh.mm.ss.zzz"
    #define DTF_ForFileNameWithoutMS         "yyyy-MM-dd_hh.mm.ss"

#pragma endregion }

class Logger
{
private:
    Logger();
public:
    static Logger* getIns();
    static const char* QtMsgTypeToString(QtMsgType type);
    static void outputLogToConsole(const QString &msg);
    static void logMessageHandler(QtMsgType msgType, const QMessageLogContext &context, const QString &msg);
    void init(const QString& saveLogFolderPath);

private:
    void saveLog(const QString& content);

    QString m_folderPath = "./log";
    QtMsgType logLevel = QtDebugMsg;
};

#endif // LOGGER_H
