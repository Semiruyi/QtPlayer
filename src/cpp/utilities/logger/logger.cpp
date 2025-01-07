#include "logger.h"

Logger::Logger()
{

}

Logger* Logger::getIns() {
    static Logger logger;
    return &logger;
}

const char* Logger::QtMsgTypeToString(QtMsgType type)
{
    switch (type)
    {
        case QtDebugMsg: return "Debug";
        case QtInfoMsg: return "Info";
        case QtWarningMsg: return "Warning";
        case QtCriticalMsg: return "Critical";
        case QtFatalMsg: return "Fatal";
        default: return "Unknown";
    }
}


// TODO: use a thread to handle this
void Logger::saveLog(const QString &content) {

    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd");

    QDir logDir(m_folderPath);
    if (!logDir.exists()) {
        logDir.mkpath(".");
    }

    QString filePath = logDir.filePath(timestamp + ".log");

    QFile file(filePath);
    if (file.open(QIODevice::Text | QIODevice::Append)) {
        QTextStream out(&file);
        out << content << "\n";
        file.close();
    }
    else {
        QString errMsg = QString("void Logger::saveLog(const QString &content): Failed to open file: %1").arg(filePath);
        outputLogToConsole(errMsg);
    }
}

void Logger::outputLogToConsole(const QString &msg)
{
    std::cout << msg.toLocal8Bit().toStdString() << std::endl;
}

void Logger::logMessageHandler(QtMsgType msgType, const QMessageLogContext &context, const QString &msg)
{
    auto ins = getIns();

    QString levelString = QtMsgTypeToString(msgType);
    auto souceCodeFileName = QFileInfo(context.file).fileName();
    QString location = QString("%1:%2(%3)").arg(souceCodeFileName).arg(context.line).arg(context.function);

    QString formatedMsg = QString("%1 [%2] [%3] [0x%4] %5: %6")
            .arg(QDateTime::currentDateTime().toString(DTF_ForFileNameWithoutMS))
            .arg(context.category)
            .arg(levelString)
            .arg(quintptr(QThread::currentThreadId()), 0, 16)
            .arg(location)
            .arg(msg);

    if(msgType != QtDebugMsg)
    {
        ins->saveLog(formatedMsg);
    }

    outputLogToConsole(formatedMsg);

    // 如果是致命错误，终止程序
    if (msgType == QtFatalMsg)
        abort();
}

void Logger::init(const QString& saveLogFolderPath)
{
    m_folderPath = saveLogFolderPath;
    qInstallMessageHandler(logMessageHandler);
}
