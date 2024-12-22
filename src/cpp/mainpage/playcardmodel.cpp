#include "playcardmodel.h"

PlayCardModel::PlayCardModel(){
    init();
}

QString PlayCardModel::path() const
{
    return m_path;
}

void PlayCardModel::setPath(const QString &newPath)
{
    if (m_path == newPath)
        return;
    m_path = newPath;
    emit pathChanged();
}

QString PlayCardModel::animationTitle() const
{
    return m_animationTitle;
}

void PlayCardModel::setAnimationTitle(const QString &newAnimationTitle)
{
    if (m_animationTitle == newAnimationTitle)
        return;
    m_animationTitle = newAnimationTitle;
    emit animationTitleChanged();
}

int PlayCardModel::lastPlayedEpisode() const
{
    return m_lastPlayedEpisode;
}

void PlayCardModel::setLastPlayedEpisode(int newLastPlayedEpisode)
{
    if (m_lastPlayedEpisode == newLastPlayedEpisode)
        return;
    m_lastPlayedEpisode = newLastPlayedEpisode;
    emit lastPlayedEpisodeChanged();
}
