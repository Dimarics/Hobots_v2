#include "hd_serialportinterface.h"
#include "qdebug.h"
#include <QThread>

HD_SerialPortInterface::HD_SerialPortInterface()
{
    serialPort()->setBaudRate(9600);
}

// Скорость и ускорение
void HD_SerialPortInterface::sendSpeedValue(int value)
{
    sendCommand(QString("G00 F %1").arg(value));
}

void HD_SerialPortInterface::sendAccelerationValue(int value)
{
    sendCommand(QString("G00 H %1").arg(value));
}

// Движение
void HD_SerialPortInterface::moveToX(qreal value)
{
    sendCommand(QString("G00 X %1").arg(value));
}

void HD_SerialPortInterface::moveToY(qreal value)
{
    sendCommand(QString("G00 Y %1").arg(value));
}

void HD_SerialPortInterface::moveToZ(qreal value)
{
    sendCommand(QString("G00 Z %1").arg(value));
}

void HD_SerialPortInterface::moveToXY(qreal x, qreal y)
{
    sendCommand(QString("G00 X %1 Y %2").arg(x).arg(y));
}

void HD_SerialPortInterface::moveToXYZ(qreal x, qreal y, qreal z)
{
    sendCommand(QString("G00 X %1 Y %2 Z %3").arg(x).arg(y).arg(z));
}

void HD_SerialPortInterface::rotateJoint(quint8 id, bool inversed)
{
    quint8 num = 0;
    quint8 dir = inversed ? 2 : 1;
    switch (id)
    {
    case 1: num = 5; break;
    case 2: num = 6; break;
    case 3: num = 7; break;
    case 4: num = 4; break;
    // координаты
    case 5: num = 1; break; // x
    case 6: num = 2; break; // y
    case 7: num = 3; break; // z
    }
    sendCommand(QString("D%1%2").arg(num).arg(dir));
}

void HD_SerialPortInterface::setJoint(quint8 id, float value)
{
    char joint = 0;
    switch (id)
    {
    case 1: joint = 'A'; break;
    case 2: joint = 'B'; break;
    case 3: joint = 'C'; break;
    case 4: joint = 'D'; break;
    }
    //sendCommand(joint + ' ' + QByteArray::number(qDegreesToRadians(value)));
    sendCommand(QString("G00 %1 %2").arg(joint).arg(qDegreesToRadians(value)));
}

void HD_SerialPortInterface::stay() { sendCommand("D80"); } // G04 - пауза

void HD_SerialPortInterface::stop() { sendCommand("M00"); } // D80 - остановка моторов

void HD_SerialPortInterface::goHome() { sendCommand("G28"); }

void HD_SerialPortInterface::setGrabEnabled(bool enable) { sendCommand(enable ? "M09" : "M08"); }
void HD_SerialPortInterface::setPompEnabled(bool enable) { sendCommand(enable ? "M10" : "M11"); }
void HD_SerialPortInterface::setLaserEnabled(bool enable) { sendCommand(enable ? "M03" : "M05"); }

void HD_SerialPortInterface::setPWM(quint8 pin, quint8 value) {
    //qDebug() << QString("P %1 %2").arg(pin).arg(value);
    sendCommand(QString("P %1 %2").arg(pin).arg(value));
}

void HD_SerialPortInterface::messageHandler(const QByteArray &data)
{
    QStringList commands = QString(data).split(' ');
    //qDebug() << data;
    if (data.at(0) == 'H')
    {
        switch(data.at(2) - '0')
        {
        case 0:
            if (!m_connect)
            {
                m_connect = true;
                //setOnline(true);
            }
            else if (m_connect && m_calibrated)
            {
                m_calibrated = false;
                setState(Online);
            }
            emit statusChanged("");
            break;
        case 1:
            emit statusChanged("Буфер переполнен!");
            break;
        case 2:
            m_calibrated = true;
            emit statusChanged("Идёт калибровка");
            break;
        case 3:
            emit statusChanged("Идёт разогрев");
            break;
        case 4:
            emit statusChanged("На паузе");
            break;
        case 5:
            emit statusChanged("Требуется калибровка!");
            break;
        default:
            return;
            break;
        }
        if (commands.at(0) == "H10") return;

        if (!m_railGuide && data.at(1) == '2')
            m_railGuide = true;
        else if (m_railGuide && data.at(1) != '2')
            m_railGuide = false;

        emit xChanged(commands.at(2).toDouble());
        emit yChanged(commands.at(4).toDouble());
        emit zChanged(commands.at(6).toDouble());
        emit jointChanged(1, commands.at(8).toDouble());
        emit jointChanged(2, commands.at(10).toDouble());
        emit jointChanged(3, commands.at(12).toDouble());
        emit jointChanged(4, commands.at(14).toDouble());
        emit extruderTempChanged(commands.at(16).toDouble());
    }
    else
    {
        emit completed();
        if ((commands.at(0) == "G00" || commands.at(0) == "G01") && commands.at(1) == "ok") {
            QThread::msleep(100);
            sendCommand("M01");
        }
        else if (commands.at(0) == "M01" && commands.at(1) == "ok") {
            emit goalAchieved();
        }
        //if (!m_input.isEmpty() && m_input != "0.00" && m_input != "0" && m_input != "1" && m_input != "2")
        //    qDebug() << "in: " + m_input;
    }
}

void HD_SerialPortInterface::readPort()
{
    int index = serialPort()->peek(serialPort()->bytesAvailable()).indexOf('\n');
    if (index == -1) return;
    QByteArray data = serialPort()->read(index + 1).trimmed();
    //qDebug() << "in:" << data;
    messageHandler(data);
    emit messageAccepted();
}
