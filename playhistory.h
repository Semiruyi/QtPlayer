#ifndef PLAYHISTORY_H
#define PLAYHISTORY_H

#include <QObject>
#include <QMap>
#include <QUrl>

struct PlayData {
    bool isWatched;
    int position;
    friend QDataStream &operator<<(QDataStream &out, const PlayData &data) {
        out << data.isWatched;
        out << data.position;
        return out;
    }

    friend QDataStream &operator>>(QDataStream &in, PlayData &data) {
        in >> data.isWatched;
        in >> data.position;
        return in;
    }
};

class PlayHistory : public QObject
{
    // Q_PROPERTY(int year READ getYear WRITE setYear NOTIFY yearChanged)
    Q_OBJECT
public:
    explicit PlayHistory(QObject *parent = nullptr);
    Q_INVOKABLE int init(QString dataUrl);
    Q_INVOKABLE int isWatched(int index);
    Q_INVOKABLE int setWatchState(int index, bool state);
    Q_INVOKABLE int setEpPos(int index, int postion);
    Q_INVOKABLE int getEpPos(int index);
    Q_INVOKABLE int saveData();
    int getTest() const;
    void setTest(int newTest);

signals:

private:
    QMap<int, PlayData> data;
    QUrl dataUrl;
    int test;
};

#endif // PLAYHISTORY_H
