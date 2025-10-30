#include "h1t1_modbusinterface.h"
#include <QTimer>

H1T1_ModbusInterface::H1T1_ModbusInterface()
{
    QTimer *timer = new QTimer(this);
    timer->start(500);
    //connect(this, &ModbusInterface::connected, this, [this]{ emit onlineChanged(true); });
    connect(timer, &QTimer::timeout, this, [this]() {
        static quint16 state = 0;
        state = state ? 0 : 0xFF00;
        writeSingleRegister(2, state);
        //readMultipleInput(1, A_ColorSensor_InputRGB, 30, [this](const QList<quint16> &args){ emit dataChanged(args); });
    });
}

void H1T1_ModbusInterface::initModbus()
{
    ModbusInterface::initModbus();
    switch (protocol()) {
    case RTU:
        modbus()->setConnectionParameter(QModbusDevice::SerialBaudRateParameter, 57600);
        break;
    case SoftAP:
        modbus()->setConnectionParameter(QModbusDevice::NetworkAddressParameter, "192.168.1.202");
    default:
        break;
    }
}

/*void H1T1_ModbusInterface::rotateMotor(uint8_t id, bool dir, float speed)
{
    if (modbus()->state() != QModbusDevice::ConnectedState) return;
    quint16 address = A_Motor_Dir + 6 * id;
    QModbusResponse response = QModbusResponse(QModbusPdu::WriteMultipleRegisters, address, quint16(2), quint8(4), quint16(dir), quint16(speed));
    QModbusReply *reply = modbus()->sendRawRequest(response, 1);
    connect(reply, &QModbusReply::finished, reply, &QObject::deleteLater);
}*/
