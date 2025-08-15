#include "hlt3_serialportinterface.h"
#include "hlt3_modbusinterface.h"
#include "qtimer.h"
#include <QSerialPort>

HLT3_SerialPortInterface::HLT3_SerialPortInterface()
{
    serialPort()->setBaudRate(57600);
    new HLT3_ModbusInterface();
    //serialPort()->setDataBits(QSerialPort::Data8);
    //serialPort()->setParity(QSerialPort::NoParity);
    //serialPort()->setStopBits(QSerialPort::OneStop);
    //serialPort()->setFlowControl(QSerialPort::SoftwareControl);


    QTimer *timer = new QTimer(this);
    timer->setInterval(1000);
    connect(timer, &QTimer::timeout, this, [this] {
        //char c[] {0x3, 0x4, 0x5, 0x6, 0x7};
        sendPacket(GetStatePorts);
    });
    connect(this, &HLT3_SerialPortInterface::connected, timer, [timer]{ timer->start(); });
    connect(this, &HLT3_SerialPortInterface::disconnected, timer, &QTimer::stop);
    connect(serialPort(), &QIODevice::aboutToClose, timer, &QTimer::stop);
    /*connect(serialPort(), &QSerialPort::errorOccurred, this, [](QSerialPort::SerialPortError error){
        qDebug() << error;
    });
    connect(serialPort(), &QIODevice::aboutToClose, this, [] {
        qDebug() << "close";
    });*/
}

void HLT3_SerialPortInterface::sendPacket(char function_code)
{
    QByteArray packet(5, 0);
    packet[0] = 0xFF;
    packet[1] = 0xFF;
    packet[2] = 0;
    packet[3] = function_code;
    packet[4] = function_code;
    send(packet);
    /*serialPort()->putChar(0xFF);
    serialPort()->putChar(0xFF);
    serialPort()->putChar(0);
    serialPort()->putChar(function_code);
    char crc = function_code;
    serialPort()->putChar(crc);*/
}

void HLT3_SerialPortInterface::sendPacket(char function_code, char *data, char size)
{
    QByteArray packet(5 + size, 0);
    packet[0] = 0xFF;
    packet[1] = 0xFF;
    packet[2] = size;
    packet[3] = function_code;
    for (int i = 0; i < size; ++i) packet[i+4] += data[i];
    char crc = function_code;
    for (int i = 0; i < size; ++i) crc += data[i];
    packet[size + 4] = crc;
    send(packet);
    //for (int i = 0; i < size; ++i) crc += data[i];
    //serialPort()->putChar(crc);
    /*serialPort()->putChar(0xFF);
    serialPort()->putChar(0xFF);
    serialPort()->putChar(size);
    serialPort()->putChar(function_code);
    serialPort()->write(data, size);
    char crc = function_code;
    for (int i = 0; i < size; ++i) crc += data[i];
    serialPort()->putChar(crc);*/
}

void HLT3_SerialPortInterface::rotateMotor(quint8 id, bool dir, quint8 speed)
{
    //App.device.interface.setJoint()
    Motor motor { id, dir, speed };
    sendPacket(RotateMotor, reinterpret_cast<char*>(&motor), sizeof(Motor));
}

void HLT3_SerialPortInterface::readPort()
{
    // минимальный размер пакета: 4(header) + 1(crc) = 5
    qDebug() << "in:" << serialPort()->readAll();
    return;
    // поиск заголовка
    Header header;
    serialPort()->peek(reinterpret_cast<char*>(&header), sizeof(Header));
    while (header.startBytes != 0xFFFF && serialPort()->bytesAvailable() >= 5) {
        serialPort()->read(1);
        serialPort()->peek(reinterpret_cast<char*>(&header), sizeof(Header));
    }
    if (header.startBytes != 0xFFFF || serialPort()->bytesAvailable() - 5 < header.size) return;
    serialPort()->read(sizeof(Header));

    QByteArray data;
    char crc = header.function_code;
    if (header.size) {
        data = serialPort()->read(header.size);
        //qDebug() << data;
        for (int i = 0; i < header.size; ++i) crc += data[i]; // подсчёт контрольной суммы
    }

    //qDebug() << int(crc) << int(crc_in);
    if (crc != getChar()) {
        qDebug() << "ошибка контрольной суммы";
        return;
    }

    // обработка данных
    switch(header.function_code) {
    case MessageAccepted:
        emit messageAccepted();
        break;
    case SendStatePorts: {
        //DeviceInfo device_info;
        //std::memcpy(&device_info, data.constData(), header.size);
        //DeviceInfo device_info = *reinterpret_cast<DeviceInfo*>(data.data());
        emit messageAccepted();
        //qDebug() << data;
    }   break;
    default:
        qDebug() << "неизвестный код функции";
        break;
    }
}
