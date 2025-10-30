#ifndef SERIALPORTINTERFACE_H
#define SERIALPORTINTERFACE_H

#include "hobotinterface.h"
#include <QSerialPort>
#include <QTimer>

class SerialPortInterface : public HobotInterface
{
    Q_OBJECT
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
public:
    SerialPortInterface();
    inline char getChar() const { char c; m_serialPort->getChar(&c); return c; };
    inline QString portName() const { return m_serialPort->portName(); }
    inline QSerialPort *serialPort() const { return m_serialPort; }
    Q_INVOKABLE void setPortName(const QString &portName);
    Q_INVOKABLE void connectDevice();
    Q_INVOKABLE void disconnectDevice();
    void send(const QByteArray &message);

protected:
    virtual void readPort();

private:
    QByteArray m_buffer;
    QSerialPort *m_serialPort;
    QList<QByteArray> m_queue;
    QTimer *timeout;

signals:
    void portNameChanged();
    void requestToSend();
    void messageAccepted();
};

#endif // SERIALPORTINTERFACE_H
