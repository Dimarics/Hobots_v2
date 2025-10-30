#include "serialportinterface.h"
#include "qdebug.h"

SerialPortInterface::SerialPortInterface() : m_serialPort(new QSerialPort(this)), timeout(new QTimer(this))
{
    connect(m_serialPort, &QSerialPort::readyRead, this, &SerialPortInterface::readPort);
    connect(m_serialPort, &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError error) {
        switch (error) {
        case QSerialPort::DeviceNotFoundError:
        case QSerialPort::PermissionError:
        case QSerialPort::ResourceError:
            disconnectDevice();
            emit errorOccurred(HobotInterface::ConnectionError);
            break;
        default: break;
        }
    });
    //
    connect(this, &SerialPortInterface::messageAccepted, this, [this] {
        //qDebug() << m_queue;
        if (!m_queue.isEmpty()) {
            m_queue.removeFirst();
            timeout->stop();
        }
        if (!m_queue.isEmpty()) {
            m_serialPort->write(m_queue.first());
            timeout->start();
        }
        //qDebug() << m_queue;
    });
    //
    timeout->setInterval(500);
    connect(timeout, &QTimer::timeout, this, [this] {
        qDebug() << "timeout error";
        m_queue.clear();
        timeout->stop();
    });
}

void SerialPortInterface::setPortName(const QString &portName) {
    if (portName == m_serialPort->portName()) return;
    /*for (const QSerialPortInfo &serialPortInfo : QSerialPortInfo::availablePorts()) {
        if (serialPortInfo.portName() == portName) {
            m_serialPort->setPort(serialPortInfo);
            m_serialPort->open(QIODeviceBase::ReadWrite);
        }
    }*/
    if (m_serialPort->isOpen()) m_serialPort->close();
    m_serialPort->setPortName(portName);
    emit portNameChanged();
}

void SerialPortInterface::connectDevice()
{
    if (m_serialPort->isOpen()) return;
    if (m_serialPort->open(QIODeviceBase::ReadWrite)) {
        m_serialPort->setDataTerminalReady(true);
        setState(Connected);
    } else {
        setState(Unconnected);
    }
}

void SerialPortInterface::disconnectDevice()
{
    if (m_serialPort->isOpen()) {
        m_serialPort->close();
        setState(Unconnected);
    }
}

void SerialPortInterface::send(const QByteArray &message)
{
    m_serialPort->write(message);
}

void SerialPortInterface::readPort() {
}
