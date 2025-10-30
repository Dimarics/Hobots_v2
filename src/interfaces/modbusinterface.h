#ifndef MODBUSINTERFACE_H
#define MODBUSINTERFACE_H

#include "hobotinterface.h"
#include <QModbusRtuSerialClient>
#include <QModbusTcpClient>
#include <QVariant>

class ModbusInterface : public HobotInterface
{
    Q_OBJECT
    Q_PROPERTY(Protocol protocol READ protocol WRITE setProtocol NOTIFY protocolChanged)
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
public:
    enum Protocol { RTU, SoftAP, LAN };
    Q_ENUM(Protocol)
    ModbusInterface();
    inline Protocol protocol() const { return m_protocol; }
    inline QString portName() const { return m_modbus->connectionParameter(QModbusDevice::SerialPortNameParameter).toString(); }
    inline QModbusClient *modbus() const { return m_modbus; }
    Q_INVOKABLE void setPortName(const QString &portName);
    Q_INVOKABLE void setProtocol(Protocol protocol);
    Q_INVOKABLE void connectDevice();
    Q_INVOKABLE void disconnectDevice();
    //void send(const QByteArray &message);

protected:
    //template<typename... Args> void aboba(Args... args);
    virtual void initModbus();
    void writeSingleRegister(quint16 addr, quint16 value, qint8 id = 1);
    void writeMultipleHoldings(qint8 id, quint16 start_addr, quint16 count, const QList<qint16> &values);
    void readSingleInput(qint8 id, quint16 addr, const std::function<void(quint16)> &func);
    void readMultipleInput(qint8 id, quint16 start_addr, quint16 count, const std::function<void(const QList<quint16>&)> &func);

private:
    Protocol m_protocol;
    QModbusClient *m_modbus;
    QList<QByteArray> m_queue;

signals:
    void protocolChanged();
    void portNameChanged();
};

#endif // MODBUSINTERFACE_H
