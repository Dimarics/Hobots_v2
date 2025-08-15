#ifndef NETWORKINTERFACE_H
#define NETWORKINTERFACE_H

#include "hobotinterface.h"
#include <QUdpSocket>
#include <QTcpSocket>

class NetworkInterface : public HobotInterface
{
    Q_OBJECT
public:
    enum WorkingMethod { LAN, SoftAP };
    NetworkInterface();
    void setPort(quint16 port);
    void setWorkingMethod(WorkingMethod workingMethod);
    int workingMethod() const;
    quint16 port() const;

    //bool connectDevice() override;
    void connectDevice(const QString &address, quint16 port = 80);
    //void disconnectDevice() override;

protected:
    virtual void commandsHandler(const QByteArray &data);

private:
    int m_workingMethod;
    quint16 m_port;
    QByteArray m_data;
    QHostAddress m_hostAddress;
    //QUdpSocket *m_udp;
    QTcpSocket *m_tcp;

public slots:
    void sendCommand(const char *command);
    void sendCommand(const QByteArray &command);
    void sendCommand(const QString &command);
    //void sendCommand(const QByteArray &command, const QString &hostAddress, quint16 port = 80);
};

#endif // NETWORKINTERFACE_H
