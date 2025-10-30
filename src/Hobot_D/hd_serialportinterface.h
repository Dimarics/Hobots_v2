#ifndef HD_INTERFACE_H
#define HD_INTERFACE_H

#include "qtypes.h"
#include "serialportinterface.h"
#include <QtQmlIntegration>

class HD_SerialPortInterface : public SerialPortInterface
{
    Q_OBJECT
    QML_ELEMENT

public:
    HD_SerialPortInterface();

    void sendSpeedValue(int value);
    void sendAccelerationValue(int value);

    void moveToX(qreal value) override;
    void moveToY(qreal value) override;
    void moveToZ(qreal value) override;
    void moveToXY(qreal x, qreal y) override;
    void moveToXYZ(qreal x, qreal y, qreal z) override;
    void rotateJoint(quint8 id, bool inversed = true) override;
    void setJoint(quint8 id, float value) override;
    void stay() override;
    void stop() override;
    void goHome() override;
    void setGrabEnabled(bool enable) override;
    void setPompEnabled(bool enable) override;
    void setLaserEnabled(bool enable) override;
    void setPWM(quint8 pin, quint8 value) override;

    inline void sendCommand(const QString &command) { send(command.toUtf8() + '\n'); }

private:
    bool m_connect;
    bool m_calibrated;
    bool m_railGuide;
    void readPort() override;
    void messageHandler(const QByteArray &data);

signals:
    void completed();
};

#endif // HD_INTERFACE_H
