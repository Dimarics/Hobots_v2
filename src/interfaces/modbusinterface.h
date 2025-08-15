#ifndef MODBUSINTERFACE_H
#define MODBUSINTERFACE_H

#include "hobotinterface.h"
#include <QModbusRtuSerialClient>
#include <QVariant>

class ModbusInterface : public HobotInterface
{
    Q_OBJECT
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
public:
    ModbusInterface();
    inline QString portName() const { return m_modbus->connectionParameter(QModbusDevice::SerialPortNameParameter).toString(); }
    inline QModbusRtuSerialClient *modbus() const { return m_modbus; }
    Q_INVOKABLE void setPortName(const QString &portName);
    Q_INVOKABLE void connectDevice();
    Q_INVOKABLE void disconnectDevice();
    //void send(const QByteArray &message);

protected:
    //template<typename... Args> void aboba(Args... args);
    void writeMultipleHoldings(qint8 id, quint16 start_addr, quint16 count, const QList<qint16> &values);
    void readSingleInput(qint8 id, quint16 addr, const std::function<void(quint16)> &func);
    void readMultipleInput(qint8 id, quint16 start_addr, quint16 count, const std::function<void(const QList<quint16>&)> &func);

private:
    QModbusRtuSerialClient *m_modbus;
    QList<QByteArray> m_queue;

signals:
    void portNameChanged();
};

#endif // MODBUSINTERFACE_H
