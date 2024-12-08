#include "playhistory.h"
#include <QFile>
#include <QUrl>
#include <QFileInfo>
#include <QDebug>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QQmlContext>

PlayHistory::PlayHistory(QQmlApplicationEngine& engine, QObject *parent)
    : QObject{parent}
{
    engine.rootContext()->setContextProperty("qPlayHistoryConfig", this);
}

int PlayHistory::init(QString dataUrl) {

    this->dataUrl = QUrl(dataUrl);

    if(QSqlDatabase::contains("qt_sql_default_connection"))
        db = QSqlDatabase::database("qt_sql_default_connection");
    else
        db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(this->dataUrl.toLocalFile());

    if(db.open()){
        qDebug()<<"history.db open success";
        const QString sql = R"(
                                CREATE TABLE IF NOT EXISTS play_history (
                                    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                                    episode_index INTEGER,
                                    file_name VARCHAR(256) UNIQUE,
                                    is_watched BOOLEAN,
                                    position BIGINT
                                );
                            )";
        QSqlQuery query(db);

        if(query.exec(sql)){
            qDebug() << "init table success";
        }
        else{
            qCritical() << "init table error";
        }
        // 关闭数据库
        // db.close();
    }
    else {
        qCritical() << "history.db open failed";
    }


    return 0;
}

int PlayHistory::isWatched(int index) {
    QSqlQuery query(db);
    // qDebug() << "check is watched index: " << index;
    query.exec(QString(R"(SELECT is_watched FROM play_history WHERE episode_index='%1';)").arg(index));

    if(query.next()) {
        qDebug() << "check is watched index: " << index << "  isWatched: " << query.value(0).toInt();
        return query.value(0).toBool();
    }
    return 0;
}

int PlayHistory::setWatchState(int index, bool state) {
    QSqlQuery query(db);

    query.exec(QString(R"(SELECT * FROM play_history WHERE episode_index='%1';)").arg(index));

    if(query.next()) {
        int iRet = query.exec(QString(R"(UPDATE play_history SET is_watched=%2 WHERE episode_index='%1';)")
                       .arg(index).arg(state));
        if(iRet){
            qDebug() << "update watch state success";
        }else{
            qDebug() << "update watch state error";
        }
    }
    else {
        int iRet = query.exec(QString(R"(INSERT INTO play_history(episode_index, is_watched, position) VALUES(%1, %2, 0))").arg(index).arg(state));
        if(iRet){
            qDebug() << "insert watch state success";
        }
        else{
            qDebug() << "insert watch state error";
            qDebug() << query.lastError();
        }
    }
    return 0;
}

int PlayHistory::setEpPos(int index, int position) {
    QSqlQuery query(db);

    query.exec(QString(R"(SELECT * FROM play_history WHERE episode_index='%1';)").arg(index));

    if(query.next()) {
        int iRet = query.exec(QString(R"(UPDATE play_history SET position=%2 WHERE episode_index='%1';)")
                                  .arg(index).arg(position));
        if(iRet){
            qDebug() << "update video index " << index << " position: " << position << " success";
        }
        else{
            qDebug() << "update video position error: " << query.lastError();
        }
    }
    else {
        int iRet = query.exec(QString(R"(INSERT INTO play_history(episode_index, is_watched, position) VALUES(%1, 0, %2))").arg(index).arg(position));
        if(iRet){
            qDebug() << "insert video position success";
        }
        else{
            qDebug() << "insert video position error" << query.lastError();
            qDebug() << query.lastError();
        }
    }
    return 0;
}

int PlayHistory::getEpPos(int index) {

    QSqlQuery query(db);

    query.exec(QString(R"(SELECT position FROM play_history WHERE episode_index='%1';)").arg(index));

    if(query.next()) {
        qDebug() << "get index: " << index << " EpPos: " << query.value(0).toInt();
        return query.value(0).toInt();
    }
    return 0;
}

void PlayHistory::setTest(int newTest) {
    qDebug() << "qPlayHistory is working";
}
