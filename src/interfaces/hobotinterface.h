#ifndef HOBOTINTERFACE_H
#define HOBOTINTERFACE_H

#include <QtQmlIntegration>

class HobotInterface : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
public:
    enum State: uint8_t {
        Unconnected,
        Connecting,
        Connected,
        Online,
        Closing
    };
    enum Error {
        ConnectionError,
        TimeoutError,
        UnknownError
    };
    Q_ENUM(State)
    Q_ENUM(Error)
    HobotInterface();
    inline State state() const { return m_state; }
    Q_INVOKABLE virtual void moveToX(qreal value);
    Q_INVOKABLE virtual void moveToY(qreal value);
    Q_INVOKABLE virtual void moveToZ(qreal value);
    Q_INVOKABLE virtual void moveToXY(qreal x, qreal y);
    Q_INVOKABLE virtual void moveToXYZ(qreal x, qreal y, qreal z);
    Q_INVOKABLE virtual void rotateJoint(quint8 id, bool inversed = true);
    Q_INVOKABLE virtual void setJoint(quint8 id, float value);
    Q_INVOKABLE virtual void stay();
    Q_INVOKABLE virtual void stay(quint8 id);
    Q_INVOKABLE virtual void stop();
    Q_INVOKABLE virtual void goHome();
    Q_INVOKABLE virtual void setSpeed(qreal value);
    Q_INVOKABLE virtual void setAccel(qreal value);
    Q_INVOKABLE virtual void setDecel(qreal value);
    Q_INVOKABLE virtual void setGrabEnabled(bool enable);
    Q_INVOKABLE virtual void setPompEnabled(bool enable);
    Q_INVOKABLE virtual void setLaserEnabled(bool enable);
    Q_INVOKABLE virtual void setPWM(quint8 pin, quint8 value);
    Q_INVOKABLE virtual void repeatLastAction();

protected:
    void setState(State state);

private:
    State m_state;

signals:
    void stateChanged(State state);
    void errorOccurred(Error error);
    //void connected();
    //void disconnected();
    //void onlineChanged(bool online);
    void statusChanged(const QString &status);
    /*void connectEstablish();
    void statusChanged(const QString &status = {});
    void dataReceived();
    void goalAchieved();*/
    void xChanged(qreal value);
    void yChanged(qreal value);
    void zChanged(qreal value);
    void jointChanged(quint8 id, qreal value);
    void extruderTempChanged(qreal value);
    void goalAchieved();
};

#endif // HOBOTINTERFACE_H
