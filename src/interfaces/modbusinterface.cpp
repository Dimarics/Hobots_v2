#include "modbusinterface.h"
#include <QSerialPort>
#include "qdebug.h"

ModbusInterface::ModbusInterface() : m_modbus(new QModbusRtuSerialClient(this))
{
    //quint16 num = 567;
    //quint8 data[2] { quint8(num), quint8(num >> 8) };
    //qDebug() << ((data[1] << 8) | data[0]) << *reinterpret_cast<quint16*>(data);
    m_modbus->setConnectionParameter(QModbusDevice::SerialDataBitsParameter, 8);
    m_modbus->setConnectionParameter(QModbusDevice::SerialStopBitsParameter, 1);
    m_modbus->setConnectionParameter(QModbusDevice::SerialParityParameter, QSerialPort::NoParity);
    connect(m_modbus, &QModbusDevice::errorOccurred, this, [this](QModbusDevice::Error error) {
        if (error == QModbusDevice::ReplyAbortedError) {
            if (m_modbus->state() == QModbusDevice::ConnectedState) m_modbus->disconnectDevice();
            emit disconnected();
        }
    });
    connect(m_modbus, &QModbusDevice::stateChanged, this, [this](QModbusDevice::State state) {
        qDebug() << state;
        if (state == QModbusDevice::ConnectedState)
            qobject_cast<QSerialPort*>(m_modbus->device())->setDataTerminalReady(true);
    });
}

void ModbusInterface::setPortName(const QString &newPortName) {
    if (newPortName == portName()) return;
    if (m_modbus->state() == QModbusDevice::ConnectedState) disconnectDevice();
    m_modbus->setConnectionParameter(QModbusDevice::SerialPortNameParameter, newPortName);
    emit portNameChanged();
}

void ModbusInterface::connectDevice()
{
    /*if (m_serialPort->isOpen()) return;
    if (m_serialPort->open(QIODeviceBase::ReadWrite)) {
        m_serialPort->setDataTerminalReady(true);
        emit connected();
    } else {
        emit disconnected();
    }*/
    if (m_modbus->state() == QModbusDevice::ConnectedState) return;
    if (m_modbus->connectDevice()) {
        emit connected();
    } else {
        qDebug() << m_modbus->errorString();
        emit disconnected();
    }
}

void ModbusInterface::disconnectDevice()
{
    m_modbus->disconnectDevice();
}

void ModbusInterface::writeMultipleHoldings(qint8 id, quint16 start_addr, quint16 count, const QList<qint16> &values)
{
    if (m_modbus->state() != QModbusDevice::ConnectedState) return;
    QByteArray data(6 + count * 2, 0);
    data[0] = id;
    data[1] = reinterpret_cast<char*>(&start_addr)[0];
    data[2] = reinterpret_cast<char*>(&start_addr)[1];
    data[3] = reinterpret_cast<char*>(&count)[0];
    data[4] = reinterpret_cast<char*>(&count)[1];
    data[5] = count * 2;
    for (quint8 i = 0; i < count * 2; i += 2) {
        data[6 + i] = values.at(i);
        data[7 + i] = values.at(i) >> 8;
    }
    qDebug() << data;
    /*QModbusResponse response(QModbusPdu::WriteMultipleRegisters, data);
        QModbusReply *reply = m_modbus->sendRawRequest(response, id);
        if (reply->isFinished()) reply->deleteLater();
        connect(reply, &QModbusReply::finished, reply, &QObject::deleteLater);*/
}

void ModbusInterface::readSingleInput(qint8 id, quint16 addr, const std::function<void (quint16)> &func)
{
    if (m_modbus->state() != QModbusDevice::ConnectedState) return;
    QModbusResponse response(QModbusPdu::ReadInputRegisters, addr, quint16(1));
    QModbusReply *reply = m_modbus->sendRawRequest(response, id);
    if (reply->isFinished()) reply->deleteLater();
    connect(reply, &QModbusReply::finished, this, [reply, func]
    {
        if (reply->error() == QModbusDevice::NoError) {
            quint8 count = 0; quint16 value = 0;
            reply->rawResult().decodeData(&count, &value);
            func(value);
        } else {
            qDebug() << reply->error();
        }
        reply->deleteLater();
    });
}

/*QModbusReply *ModbusInterface::sendRawRequest(qint8 id, const QModbusResponse &response)
{
    if (m_modbus->state() != QModbusDevice::ConnectedState) return nullptr;
    QModbusReply *reply = m_modbus->sendRawRequest(response, id);
    if (reply->isFinished()) reply->deleteLater();
    connect(reply, &QModbusReply::finished, reply, &QObject::deleteLater);
    return reply;
}*/

void ModbusInterface::readMultipleInput(qint8 id, quint16 start_addr, quint16 count, const std::function<void (const QList<quint16>&)> &func) {
    if (m_modbus->state() != QModbusDevice::ConnectedState) return;
    QModbusResponse response(QModbusPdu::ReadInputRegisters, start_addr, count);
    QModbusReply *reply = m_modbus->sendRawRequest(response, id);
    if (reply->isFinished()) reply->deleteLater();
    connect(reply, &QModbusReply::finished, this, [reply, count, func]
    {
        if (reply->error() == QModbusDevice::NoError) {
            //quint8 *data = reinterpret_cast<quint8*>(reply->rawResult().data().data());
            //char *data = reply->rawResult().data().data();
            QByteArray data = reply->rawResult().data();
            QList<quint16> values(count);
            for (quint8 i = 0, j = 1; i < count; ++i, j +=2) {
                values[i] = ((quint8)data.at(j) << 8) | (quint8)data.at(j+1);
            }
            func(values);
        } else {
            qDebug() << reply->error();
        }
        reply->deleteLater();
    });
}
