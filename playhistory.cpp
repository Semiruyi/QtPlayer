#include "playhistory.h"
#include <QFile>
#include <iostream>
#include <QUrl>
#include <QDebug>

using namespace std;

PlayHistory::PlayHistory(QObject *parent)
    : QObject{parent}
{}

int PlayHistory::saveData() {
    QFile file(this->dataUrl.toLocalFile());
    if (file.open(QIODevice::WriteOnly)) {
        QDataStream out(&file);
        out.setVersion(QDataStream::Qt_5_15);
        out << data;
        file.close();
    } else {
        cerr << "play history write data failed" << endl;
        return -1;
    }
    return 0;
}

int PlayHistory::init(QString dataUrl) {
    this->dataUrl = QUrl(dataUrl);
    QFile file(this->dataUrl.toLocalFile());

    if (file.open(QIODevice::ReadOnly)) {
        QDataStream in(&file);
        in.setVersion(QDataStream::Qt_5_15);
        in >> data;
        file.close();
        QMap<int, PlayData>::const_iterator iter;
        for (iter = data.constBegin(); iter != data.constEnd(); ++iter) {
            int key = iter.key();
            const PlayData &playData = iter.value();
            qDebug() << "Key:" << key << ", isWatched:" << playData.isWatched << ", position:" << playData.position;
        }
    }
    else {
        cerr << "play history load error" << endl;
        return -1;
    }
    return 0;
}

int PlayHistory::isWatched(int index) {
    if(data.find(index) != data.end()) {
        return data[index].isWatched;
    }
    else {
        return 0;
    }
}

int PlayHistory::setWatchState(int index, bool state) {
    data[index].isWatched = state;
    return 0;
}

int PlayHistory::setEpPos(int index, int position) {
    data[index].position = position;
    cout << "setEpPos " << index << " " << position << endl;
    return 0;
}

int PlayHistory::getEpPos(int index) {
    cout << "get postion index " << index << " " << data[index].position << endl;
    if(data.find(index) != data.end()) {
        return data[index].position;
    }
    return 0;
}

