#ifndef PLAYCARDMODEL_H
#define PLAYCARDMODEL_H

#include "../configobject/mylistmodel.h"

class PlayCardModel : public MyListModel
{
    Q_OBJECT

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
    Q_PROPERTY(QString animationTitle READ animationTitle WRITE setAnimationTitle NOTIFY animationTitleChanged FINAL)
    Q_PROPERTY(int lastPlayedEpisode READ lastPlayedEpisode WRITE setLastPlayedEpisode NOTIFY lastPlayedEpisodeChanged FINAL)
    Q_PROPERTY(long long coverPosition READ coverPosition WRITE setCoverPosition NOTIFY coverPositionChanged FINAL)

public:
    PlayCardModel();
    QString path() const;
    void setPath(const QString &newPath);

    QString animationTitle() const;
    void setAnimationTitle(const QString &newAnimationTitle);

    int lastPlayedEpisode() const;
    void setLastPlayedEpisode(int newLastPlayedEpisode);

    long long coverPosition() const;
    void setCoverPosition(long long newCoverPosition);

signals:
    void pathChanged();

    void animationTitleChanged();

    void lastPlayedEpisodeChanged();

    void coverPositionChanged();

private:
    QString m_path = "";
    QString m_animationTitle = "";
    int m_lastPlayedEpisode = 0;
    long long m_coverPosition = 10;
};

#endif // PLAYCARDMODEL_H
