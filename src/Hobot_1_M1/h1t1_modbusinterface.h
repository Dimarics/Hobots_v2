#ifndef H1T1_MODBUSINTERFACE_H
#define H1T1_MODBUSINTERFACE_H

#include <QQmlEngine>
#include "modbusinterface.h"

class H1T1_ModbusInterface : public ModbusInterface
{
    Q_OBJECT
    QML_ELEMENT
    enum Inputs : uint8_t {
    };
    enum Holdings : uint8_t {
    };
public:
    H1T1_ModbusInterface();

protected:
    void initModbus() override;

signals:
    void dataChanged(const QList<quint16> &data);
};

#endif // H1T1_MODBUSINTERFACE_H
