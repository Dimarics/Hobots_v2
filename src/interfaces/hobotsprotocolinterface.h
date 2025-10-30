#ifndef HOBOTSPROTOCOLINTERFACE_H
#define HOBOTSPROTOCOLINTERFACE_H

#include "hobotinterface.h"

class HobotsProtocolInterface : public HobotInterface
{
    Q_OBJECT
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
    HobotsProtocolInterface();
    void messageHandler(const QByteArray &data);

    void stay() override;
    void stop() override;
    void goHome() override;
    void setJoint(quint8 id, float value) override;
    virtual void send(quint8 function_code, const QByteArray &data = {});

signals:
    void messageAccepted();
};

#endif // HOBOTSPROTOCOLINTERFACE_H
