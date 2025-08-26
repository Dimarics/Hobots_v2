#include "hlt3_modbusinterface.h"
#include <QTimer>

HLT3_ModbusInterface::HLT3_ModbusInterface()
{
    modbus()->setConnectionParameter(QModbusDevice::SerialBaudRateParameter, 57600);
    QTimer *timer = new QTimer(this);
    timer->start(100);
    connect(this, &ModbusInterface::connected, this, [this]{ emit onlineChanged(true); });
    connect(this, &ModbusInterface::disconnected, this, [this]{ emit onlineChanged(false); });
    connect(timer, &QTimer::timeout, this, [this]() {
        readMultipleInput(1, A_ColorSensor_InputRGB, 30, [this](const QList<quint16> &args){ emit dataChanged(args); });
        //writeMultipleHoldings(1, 5, 2, {34, 56});
    });
}

void HLT3_ModbusInterface::rotateMotor(uint8_t id, bool dir, float speed)
{
    if (modbus()->state() != QModbusDevice::ConnectedState) return;
    quint16 address = A_Motor_Dir + 6 * id; // 6 * id - смещение для порта
    QModbusResponse response = QModbusResponse(QModbusPdu::WriteMultipleRegisters, address, quint16(2), quint8(4), quint16(dir), quint16(speed));
    QModbusReply *reply = modbus()->sendRawRequest(response, 1);
    connect(reply, &QModbusReply::finished, reply, &QObject::deleteLater);
}
