#include "hobotsprotocolinterface.h"
#include "appbackend.h"

HobotsProtocolInterface::HobotsProtocolInterface()
{

}

void HobotsProtocolInterface::messageHandler(const QByteArray &data)
{
    switch(data.at(0)) {
    case MessageAccepted:
        //emit messageAccepted();
        break;
    case ModelName:
        if (data == AppBackend::instance()->deviceName()) {
            setState(Online);
        } else {
            setState(Unconnected);
        }
        break;
    case JointsValues: {
        quint8 count = data.at(0);
        const float* joint_values = reinterpret_cast<const float*>(&data.data()[1]);
        for (quint8 i = 1, j = 0; i <= count; ++i, ++j) {
            emit jointChanged(i, joint_values[j]);
        }
    }   break;
    default:
        qDebug() << "неизвестный код функции";
        return;
    }
    emit messageAccepted();
}

void HobotsProtocolInterface::setJoint(quint8 id, float value)
{
    QByteArray data;
    data.append(id);
    data.append(reinterpret_cast<char*>(&value), sizeof(value));
    send(SetJoint, data);
}

void HobotsProtocolInterface::send(quint8, const QByteArray&) {}

void HobotsProtocolInterface::stay() { send(Stay); }

void HobotsProtocolInterface::stop() { send(Stop); }

void HobotsProtocolInterface::goHome() { send(GoHome); }
