#include "hobotprotocolinterface.h"
#include "appbackend.h"
#include <QTcpSocket>

HobotProtocolInterface::HobotProtocolInterface() :
    m_stream(QDataStream(&m_buffer, QIODevice::ReadWrite)),
    m_protocol(InvalidProtocol),
    m_device(nullptr), timeout(new QTimer(this))
{
    connect(this, &HobotProtocolInterface::messageAccepted, this, [this] {
        //qDebug() << m_queue;
        if (!m_queue.isEmpty()) {
            m_queue.removeFirst();
            timeout->stop();
        }
        if (!m_queue.isEmpty()) {
            m_device->write(m_queue.first());
            timeout->start();
        }
        //qDebug() << m_queue;
    });
    //
    timeout->setInterval(1000);
    connect(timeout, &QTimer::timeout, this, [this] {
        qDebug() << "timeout error";
        emit errorOccurred(TimeoutError);
        m_queue.clear();
        timeout->stop();
    });
    QTimer *ping = new QTimer(this);
    ping->setInterval(200);
    connect(ping, &QTimer::timeout, this, [this]{
        sendPacket(GetJoints);
    });
    connect(this, &HobotInterface::stateChanged, this, [ping, this](State state) {
        switch (state) {
        case Online:
            ping->start();
            break;
        case Unconnected:
            timeout->stop();
            ping->stop();
            break;
        default:
            ping->stop();
            break;
        }
    });
}

void HobotProtocolInterface::setProtocol(Protocol protocol)
{
    if (m_protocol == protocol) return;
    QIODevice *new_device = nullptr;
    switch (protocol) {
    case InvalidProtocol:
        qDebug() << "протокол не установлен";
        return;
    case ComPort:
        new_device = new QSerialPort(this);
        qobject_cast<QSerialPort*>(new_device)->setBaudRate(57600);
        connect(static_cast<QSerialPort*>(new_device), &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError error) {
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
        break;
    case SoftAP: case LAN:
        new_device = new QTcpSocket(this);
        break;
    default:
        qDebug() << "не существующий тип протокола";
        return;
    }
    if (m_device) m_device->deleteLater();
    m_protocol = protocol;
    m_device = new_device;
    connect(m_device, &QSerialPort::readyRead, this, &HobotProtocolInterface::readDevice);
}

void HobotProtocolInterface::setConnectionParameter(const QString &parameter)
{
    if (!m_device || m_connectionParameter == parameter) return;
    if (m_device->isOpen()) m_device->close();
    switch (m_protocol) {
    case ComPort:
        static_cast<QSerialPort*>(m_device)->setPortName(parameter);
        break;
    default:
        qDebug() << "протокол не установлен";
        return;
    }
    m_connectionParameter = parameter;
}

void HobotProtocolInterface::send(const QByteArray &message)
{
    if (!m_device) {
        qWarning() << "устройство не подключено";
        return;
    }
    if (m_queue.isEmpty()) {
        m_device->write(message);
        timeout->start();
    }
    m_queue.append(message);
    //qDebug() << "out:" << message;
}

void HobotProtocolInterface::sendPacket(char function_code)
{
    /*QByteArray packet(5, 0);
    packet[0] = 0xFF;
    packet[1] = 0xFF;
    packet[2] = 0;
    packet[3] = function_code;
    packet[4] = function_code;
    send(packet);*/
    QByteArray data;
    QDataStream stream(&data, QIODevice::WriteOnly);
    stream << quint16(0xFFFF);
    stream << quint8(0);
    stream << function_code;
    stream << function_code;
    send(data);
}

void HobotProtocolInterface::sendPacket(char function_code, char *data, char size)
{
    QByteArray packet(5 + size, 0);
    packet[0] = 0xFF;
    packet[1] = 0xFF;
    packet[2] = size;
    packet[3] = function_code;
    for (int i = 0; i < size; ++i) packet[i+4] += data[i];
    char crc = function_code;
    for (int i = 0; i < size; ++i) crc += data[i];
    packet[size + 4] = crc;
    send(packet);
    //qDebug() << packet;
    /*QDataStream stream(m_device);
    stream << quint16(0xFFFF);
    stream << size;
    stream << function_code;
    for (int i = 0; i < size; ++i) stream << data[i];
    char crc = function_code;
    for (int i = 0; i < size; ++i) crc += data[i];
    stream << crc;*/
}

void HobotProtocolInterface::sendPacket(char function_code, const QByteArray &data)
{
    QByteArray header(4, 0);
    header[0] = 0xFF;
    header[1] = 0xFF;
    header[2] = data.size();
    header[3] = function_code;
    char crc = function_code;
    for (const char &c : data) crc += c;
    send(header + data + crc);
}

void HobotProtocolInterface::beginPacket()
{
    m_buffer.clear();
    m_stream << quint16(0xFFFF);
}

void HobotProtocolInterface::endPacket()
{
    char crc = m_buffer.at(3);
    for (int i = 4; i < m_buffer.size(); ++i) crc += m_buffer.at(i);
    m_buffer.append(crc);
    send(m_buffer);
}

void HobotProtocolInterface::setJoint(quint8 id, float value)
{
    QByteArray data;
    data.append(id);
    data.append(reinterpret_cast<char*>(&value), sizeof(value));
    sendPacket(SetJoint, data);
}

void HobotProtocolInterface::stay() { sendPacket(Stay); }

void HobotProtocolInterface::stop() { sendPacket(Stop); }

void HobotProtocolInterface::goHome() { sendPacket(GoHome); }

void HobotProtocolInterface::connectDevice()
{
    if (!m_device || m_device->isOpen()) return;
    switch (m_protocol) {
    case ComPort:
        if (m_device->open(QIODeviceBase::ReadWrite)) {
            static_cast<QSerialPort*>(m_device)->setDataTerminalReady(true);
            setState(Connected);
            //emit connected();
            QTimer::singleShot(2000, this, [this]{sendPacket(GetModelName);});
            //qDebug() << static_cast<QSerialPort*>(m_device)->bytesToWrite();
            //static_cast<QSerialPort*>(m_device)->waitForBytesWritten();
        } else {
            emit errorOccurred(ConnectionError);
            //emit disconnected();
        }
        break;
    default:
        emit errorOccurred(ConnectionError);
        //emit disconnected();
        qDebug() << "протокол не установлен";
        break;
    }
}

void HobotProtocolInterface::disconnectDevice()
{
    if (m_device->isOpen()) {
        m_device->close();
        setState(Unconnected);
    }
}

void HobotProtocolInterface::readDevice() {
    // минимальный размер пакета: 4(header) + 1(crc) = 5
    //qDebug() << "in:" << QString(m_device->readAll());
    //return;
    // поиск заголовка
    Header header;
    m_device->peek(reinterpret_cast<char*>(&header), sizeof(Header));
    while (header.startBytes != 0xFFFF && m_device->bytesAvailable() >= 5) {
        m_device->read(1);
        m_device->peek(reinterpret_cast<char*>(&header), sizeof(Header));
    }
    if (header.startBytes != 0xFFFF || m_device->bytesAvailable() - 5 < header.size) return;
    m_device->read(sizeof(Header));

    QByteArray data;
    char crc = header.function_code;
    if (header.size) {
        data = m_device->read(header.size);
        //qDebug() << data;
        for (int i = 0; i < header.size; ++i) crc += data[i]; // подсчёт контрольной суммы
    }

    //qDebug() << int(crc) << int(crc_in);
    if (crc != getChar()) {
        qDebug() << "ошибка контрольной суммы";
        return;
    }
    messageHandler(header.function_code, data);

}

void HobotProtocolInterface::messageHandler(quint8 function_code, const QByteArray &data)
{
    // обработка данных
    switch(function_code) {
    case MessageAccepted:
        //emit messageAccepted();
        break;
    case ModelName:
        if (data == AppBackend::instance()->deviceName()) {
            setState(Online);
        } else {
            disconnectDevice();
        }
        break;
    case JointsValues: {
        /*QDataStream stream(data);
        quint8 count; stream >> count;
        for (quint8 i = 1, j = 0; i <= count; ++i, ++j) {
            float joint; stream >> joint;
            emit jointChanged(i, joint);
        }*/
        quint8 count = data.at(0);
        const float* joint_values = reinterpret_cast<const float*>(&data.data()[1]);
        for (quint8 i = 1, j = 0; i <= count; ++i, ++j) {
            emit jointChanged(i, joint_values[j]);
        }
        //qDebug() << int(data.at(0)) << reinterpret_cast<const float*>(&data.data()[1])[0] << reinterpret_cast<const float*>(&data.data()[1])[1];
    }   break;
    default:
        qDebug() << "неизвестный код функции";
        return;
    }
    emit messageAccepted();
}
