#include "serialportinterface.h"
#include "qdebug.h"
#include "qthread.h"
SerialPortInterface::SerialPortInterface() : m_serialPort(new QSerialPort(this)), timeout(new QTimer(this))
{
    connect(m_serialPort, &QSerialPort::readyRead, this, &SerialPortInterface::readPort);
    connect(m_serialPort, &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError error) {
        if (error == QSerialPort::ResourceError) {
            if (m_serialPort->isOpen()) m_serialPort->close();
            emit disconnected();
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

void SerialPortInterface::send(const QByteArray &message)
{
    if (m_queue.isEmpty()) {
        m_serialPort->write(message);
        timeout->start();
    }
    m_queue.append(message);
    qDebug() << "out:" << message;
}

void SerialPortInterface::connectDevice()
{
    if (m_serialPort->isOpen()) return;
    if (m_serialPort->open(QIODeviceBase::ReadWrite)) {
        m_serialPort->setDataTerminalReady(true);
        emit connected();
    } else {
        emit disconnected();
    }
}

void SerialPortInterface::disconnectDevice()
{
    m_serialPort->close();
}

void SerialPortInterface::readPort()
{
    char byte;
    while (m_serialPort->getChar(&byte)) {
        if (byte == '\n') {
            //qDebug() << "input:" << m_buffer;
            messageHandler(m_buffer);
            m_buffer.clear();
        } else if (byte != '\r') {
            m_buffer += byte;
        }
    }
}

void SerialPortInterface::messageHandler(const QByteArray&) {}
