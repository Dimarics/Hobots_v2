#include "networkinterface.h"
#include <QNetworkInterface>
#include <QTimer>

// Добавить отслеживание состояния

NetworkInterface::NetworkInterface() : HobotInterface(),
    m_workingMethod(WorkingMethod::LAN),
    m_port(80),
    //m_udp(new QUdpSocket(this)),
    m_tcp(new QTcpSocket(this))
{
    //connect(m_tcp, &QTcpSocket::connected, this, [this]{ emit onlineChanged(true); });
    //connect(m_tcp, &QTcpSocket::disconnected, this, [this]{ emit connectionLost(); });
    connect(m_tcp, &QTcpSocket::readyRead, this, [this]
    {
        char c;
        while (m_tcp->getChar(&c))
        {
            if (c == '\n')
            {
                //qDebug() << "input:" << m_data;
                commandsHandler(m_data);
                m_data.clear();
            }
            else if (c != '\r') m_data += c;
        }
    });
}

void NetworkInterface::setPort(quint16 port) { m_port = port; }

void NetworkInterface::setWorkingMethod(WorkingMethod workingMethod) { m_workingMethod = workingMethod; }

int NetworkInterface::workingMethod() const { return m_workingMethod; }

/*bool NetworkInterface::connectDevice()
{
    switch (m_workingMethod)
    {
    case LAN:
        for (const QNetworkInterface &networkInterface : QNetworkInterface::allInterfaces())
        {
            if ((networkInterface.flags() & QNetworkInterface::IsUp) &&
                (networkInterface.flags() & QNetworkInterface::CanBroadcast))
            {
                for (const QNetworkAddressEntry &addressEntry : networkInterface.addressEntries())
                {
                    if (addressEntry.ip().protocol() == QAbstractSocket::IPv4Protocol &&
                            addressEntry.ip() != QHostAddress(QHostAddress::LocalHost))
                    {
                        //m_udp->writeDatagram("bind\n", addressEntry.broadcast(), m_port);

                        quint8 *repeatCount = new quint8(0);
                        QTimer *repeatRequestTimer = new QTimer(this);
                        repeatRequestTimer->start(500);
                        QUdpSocket *udp = new QUdpSocket(this);
                        udp->writeDatagram("bind\n", addressEntry.broadcast(), m_port);
                        connect(udp, &QUdpSocket::readyRead, this, [udp, repeatCount, repeatRequestTimer, this]
                        {
                            QByteArray datagram(udp->pendingDatagramSize(), Qt::Initialization());
                            udp->readDatagram(datagram.data(), datagram.size(), &m_hostAddress);
                            //qDebug() << datagram;
                            if (datagram != acceptCommand())
                            {
                                //qDebug() << "Не соответствующая модель";
                                return;
                            }
                            m_tcp->connectToHost(m_hostAddress, m_port);
                            delete repeatCount;
                            udp->deleteLater();
                            repeatRequestTimer->deleteLater();
                        });
                        connect(repeatRequestTimer, &QTimer::timeout, this, [udp, addressEntry, repeatCount, repeatRequestTimer, this]
                        {
                            //qDebug() << acceptCommand() << "repeat connect";
                            ++*repeatCount;
                            if (*repeatCount == 10) {
                                delete repeatCount;
                                udp->deleteLater();
                                repeatRequestTimer->deleteLater();
                            }
                            udp->writeDatagram("bind\n", addressEntry.broadcast(), m_port);
                        });
                    }
                }
            }
        }
        break;
    case SoftAP:
        m_tcp->connectToHost("192.168.1.202", m_port);
        break;
    }
    return true;
}*/

void NetworkInterface::connectDevice(const QString &address, quint16 port)
{
    m_tcp->connectToHost(address, port);
}

/*void NetworkInterface::disconnectDevice() {
    m_tcp->disconnectFromHost();
}*/

void NetworkInterface::commandsHandler(const QByteArray&) {}

void NetworkInterface::sendCommand(const char *command)
{
    m_tcp->write(command);
    m_tcp->write("\n");
}

void NetworkInterface::sendCommand(const QByteArray &command)
{ m_tcp->write(command + '\n'); }

void NetworkInterface::sendCommand(const QString &command)
{ m_tcp->write(command.toUtf8() + '\n'); }
