#ifndef HOBOTINTERFACE_H
#define HOBOTINTERFACE_H

#include <QObject>
#include <QSerialPortInfo>

class HobotInterface : public QObject
{
    Q_OBJECT
public:
    HobotInterface();
    //Q_INVOKABLE virtual void destroy();

signals:
    void connected();
    void disconnected();
    void onlineChanged(bool online);
    /*void connectEstablish();
    void statusChanged(const QString &status = {});
    void dataReceived();
    void goalAchieved();*/
};

#endif // HOBOTINTERFACE_H
