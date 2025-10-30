#ifndef HLT3_MODBUSINTERFACE_H
#define HLT3_MODBUSINTERFACE_H

#include <QQmlEngine>
#include "modbusinterface.h"

class HLT3_ModbusInterface : public ModbusInterface
{
    Q_OBJECT
    QML_ELEMENT
    enum Inputs : uint8_t {
      A_ColorSensor_InputRGB,
      A_ColorSensor_InputBrightness,
      A_Sonar_Distance,
      A_ForceSensor_Value,
      A_Motor_EncoderValue,

      B_ColorSensor_InputRGB,
      B_ColorSensor_InputBrightness,
      B_Sonar_Distance,
      B_ForceSensor_Value,
      B_Motor_EncoderValue,

      C_ColorSensor_InputRGB,
      C_ColorSensor_InputBrightness,
      C_Sonar_Distance,
      C_ForceSensor_Value,
      C_Motor_EncoderValue,

      D_ColorSensor_InputRGB,
      D_ColorSensor_InputBrightness,
      D_Sonar_Distance,
      D_ForceSensor_Value,
      D_Motor_EncoderValue,

      E_ColorSensor_InputRGB,
      E_ColorSensor_InputBrightness,
      E_Sonar_Distance,
      E_ForceSensor_Value,
      E_Motor_EncoderValue,

      F_ColorSensor_InputRGB,
      F_ColorSensor_InputBrightness,
      F_Sonar_Distance,
      F_ForceSensor_Value,
      F_Motor_EncoderValue,
    };
    enum Holdings : uint8_t {
      Matrix,
      A_ColorSensor_LedBrightness,
      A_ColorSensor_LedRGB,
      A_Sonar_LedsRGB,
      A_Motor_Dir,
      A_Motor_Speed,

      B_ColorSensor_LedBrightness,
      B_ColorSensor_LedRGB,
      B_Sonar_LedsRGB,
      B_Motor_Dir,
      B_Motor_Speed,

      C_ColorSensor_LedBrightness,
      C_ColorSensor_LedRGB,
      C_Sonar_LedsRGB,
      C_Motor_Dir,
      C_Motor_Speed,

      D_ColorSensor_LedBrightness,
      D_ColorSensor_LedRGB,
      D_Sonar_LedsRGB,
      D_Motor_Dir,
      D_Motor_Speed,

      E_ColorSensor_LedBrightness,
      E_ColorSensor_LedRGB,
      E_Sonar_LedsRGB,
      E_Motor_Dir,
      E_Motor_Speed,

      F_ColorSensor_LedBrightness,
      F_ColorSensor_LedRGB,
      F_Sonar_LedsRGB,
      F_Motor_Dir,
      F_Motor_Speed,
    };
public:
    HLT3_ModbusInterface();
    Q_INVOKABLE void rotateMotor(uint8_t id, bool dir, float speed);

protected:
    void initModbus() override;

signals:
    void dataChanged(const QList<quint16> &data);
};

#endif // HLT3_MODBUSINTERFACE_H
