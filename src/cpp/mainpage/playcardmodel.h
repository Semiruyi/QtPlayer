#ifndef PLAYCARDMODEL_H
#define PLAYCARDMODEL_H

#include "../configobject/mylistmodel.h"

class PlayCardModel : public MyListModel
{
    Q_OBJECT

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged FINAL)
    Q_PROPERTY(QString animationTitle READ animationTitle WRITE setAnimationTitle NOTIFY animationTitleChanged FINAL)

public:
    PlayCardModel();
    QString path() const;
    void setPath(const QString &newPath);

    QString animationTitle() const;
    void setAnimationTitle(const QString &newAnimationTitle);

signals:
    void pathChanged();

    void animationTitleChanged();

private:
    QString m_path = "";
    QString m_animationTitle = "";
};

#endif // PLAYCARDMODEL_H
