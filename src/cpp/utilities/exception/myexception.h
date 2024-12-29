#ifndef MYEXCEPTION_H
#define MYEXCEPTION_H

#include <QException>
#include <QDebug>

class MyException : public QException
{
public:
    MyException(const QString &errMsg) : exMsgBuffer(errMsg.toUtf8())
    {
        qCritical() << "Exception: " << errMsg;
    }

    void raise() const override
    {
        throw *this;
    }
    MyException *clone() const override
    {
        return new MyException(*this);
    }
    char const *what() const noexcept override
    {
        return exMsgBuffer;
    }

private:
    QByteArray exMsgBuffer;
};
#endif // MYEXCEPTION_H
