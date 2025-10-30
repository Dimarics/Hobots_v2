#ifndef HOBOTPROTOCOLINTERFACE_H
#define HOBOTPROTOCOLINTERFACE_H

#include "hobotinterface.h"
#include <QtQmlIntegration>
#include <QSerialPort>

class HobotProtocolInterface : public HobotInterface
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Protocol protocol READ protocol WRITE setProtocol NOTIFY protocolChanged)
public:
    enum FunctionCode: uint8_t {
        MessageAccepted = 0x01,
        GetModelName, ModelName,
        GetJoints, JointsValues,
        SetJoint, SetJoints,
        RotateMotor,
        SetJointSpeed, SetJointsSpeeds,
        SetAccel, SetDecel,
        Stay, Stop, GoHome,
        GoalAchieved,
        SetPompEnabled, SetLaserEnabled
    };
    enum Protocol { InvalidProtocol, ComPort, SoftAP, LAN };
    Q_ENUM(Protocol)
    HobotProtocolInterface();
    inline char getChar() const { char c; m_device->getChar(&c); return c; };
    inline Protocol protocol() { return m_protocol; }
    Q_INVOKABLE void setProtocol(Protocol protocol);
    Q_INVOKABLE void setConnectionParameter(const QString &parameter);
    Q_INVOKABLE void connectDevice();
    Q_INVOKABLE void disconnectDevice();
    void send(const QByteArray &message);
    void sendPacket(char function_code);
    void sendPacket(char function_code, char *data, char size);
    void sendPacket(char function_code, const QByteArray &data);
    void beginPacket();
    void endPacket();

    void setJoint(quint8 id, float value) override;
    void stay() override;
    void stop() override;
    void goHome() override;

protected:
    virtual void readDevice();
    virtual void messageHandler(quint8 function_code, const QByteArray &data);

private:
#pragma pack(push, 1)
    struct Header {
        quint16 startBytes = 0;
        quint8 size = 0;
        quint8 function_code = 0;
    };
#pragma pack(pop)
    // quint8 numberOfRetries = 3;
    char m_crc;
    QByteArray m_buffer;
    QDataStream m_stream;
    Protocol m_protocol;
    QString m_connectionParameter;
    QIODevice *m_device;
    QTimer *timeout;
    QList<QByteArray> m_queue;

signals:
    void protocolChanged();
    void requestToSend();
    void messageAccepted();
};

#endif // HOBOTPROTOCOLINTERFACE_H
