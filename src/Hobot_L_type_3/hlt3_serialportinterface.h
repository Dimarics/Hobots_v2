#ifndef HLT3_SERIALPORTINTERFACE_H
#define HLT3_SERIALPORTINTERFACE_H

#include "serialportinterface.h"
#include <QQmlEngine>

class HLT3_SerialPortInterface : public SerialPortInterface
{
    enum FunctionCode {
        MessageAccepted = 0x01,
        GetStatePorts,
        SendStatePorts,
        RotateMotor,
        Stop
    };
#pragma pack(push, 1)
    struct Header {
        quint16 startBytes = 0;
        quint8 size = 0;
        quint8 function_code = 0;
    };
    struct DeviceInfo {
        bool button_1;
        bool button_2;
        uint32_t joint_1;
        uint32_t joint_2;
    };
    struct Motor {
        quint8 id;
        bool dir;
        quint8 speed;
    };
#pragma pack(pop)
    Q_OBJECT
    QML_ELEMENT
public:
    HLT3_SerialPortInterface();
    void sendPacket(char function_code);
    void sendPacket(char function_code, char *data, char size);
    Q_INVOKABLE void rotateMotor(quint8 id, bool dir, quint8 speed = 100); // const QJSValue &callback

private:
    void readPort() override;
};

#endif // HLT3_SERIALPORTINTERFACE_H
