#include "hobotinterface.h"

HobotInterface::HobotInterface() : m_state(Unconnected) {}

void HobotInterface::setState(State state)
{
    if (state == m_state) return;
    m_state = state;
    emit stateChanged(state);
}

void HobotInterface::moveToX(qreal) {}
void HobotInterface::moveToY(qreal) {}
void HobotInterface::moveToZ(qreal) {}
void HobotInterface::moveToXY(qreal, qreal) {}
void HobotInterface::moveToXYZ(qreal, qreal, qreal) {}
void HobotInterface::rotateJoint(quint8, bool) {}
void HobotInterface::setJoint(quint8, float) {}
void HobotInterface::stay() {}
void HobotInterface::stay(quint8) {}
void HobotInterface::stop() {}
void HobotInterface::goHome() {}
void HobotInterface::setSpeed(qreal) {}
void HobotInterface::setAccel(qreal) {}
void HobotInterface::setDecel(qreal) {}
void HobotInterface::setGrabEnabled(bool) {}
void HobotInterface::setPompEnabled(bool) {}
void HobotInterface::setLaserEnabled(bool) {}
void HobotInterface::setPWM(quint8, quint8) {}
void HobotInterface::repeatLastAction() {}
