#include <ModbusRTU.h>
#include <Adafruit_NeoPixel.h>

/* forse sensor
FORCE_SERIAL_CMD_GET_ID
FORCE_SERIAL_CMD_GET_RAW_ADC
FORCE_SERIAL_CMD_GET_ACTIVE_MODE
FORCE_SERIAL_CMD_SET_TOUCH_MODE
FORCE_SERIAL_CMD_SET_TAP_MODE
FORCE_SERIAL_CMD_SET_FORCE_MODE
FORCE_SERIAL_CMD_GET_TOUCH_VALUE
FORCE_SERIAL_CMD_GET_TAP_VALUE
FORCE_SERIAL_CMD_GET_FORCE_VALUE
*/

#define MOTOR_A1 PB11
#define MOTOR_A2 PB10
#define MOTOR_B1 PB4
#define MOTOR_B2 PB3
#define MOTOR_C1 PE14
#define MOTOR_C2 PE13
#define MOTOR_D1 PB6
#define MOTOR_D2 PB5
#define MOTOR_E1 PE11
#define MOTOR_E2 PE9
#define MOTOR_F1 PB1
#define MOTOR_F2 PB0

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

const uint8_t portInputsNum = A_Motor_EncoderValue + 1;
//const uint8_t portHregsNum = Motor_Speed + 1;

Adafruit_NeoPixel Pixels(25, PB14, NEO_GRB + NEO_KHZ800);

struct Port {
  uint8_t functionCode;
  String name;
  HardwareSerial hs;
};
Port ports[6]{
  Port{ 0, "", HardwareSerial(PB12, PB13) },
  Port{ 0, "", HardwareSerial(PD0, PD1) },
  Port{ 0, "", HardwareSerial(PG0, PG1) },
  Port{ 0, "", HardwareSerial(PE0, PE1) },
  Port{ 0, "", HardwareSerial(PF6, PF7) },
  Port{ 0, "", HardwareSerial(PE2, PE3) },
};

ModbusRTU modbus;
//HardwareSerial Port_A(PB12, PB13);  // RX TX
//uint8_t send_alala[5] = {2, 255, 120, 90, 200};

uint16_t cbLed(TRegister *reg, uint16_t val) {
  if (reg->address.address == 0x01) digitalWrite(PC13, COIL_BOOL(val));
  return val;
}

uint16_t cbHregs(TRegister *reg, uint16_t value) {
  switch (reg->address.address) {
    case Matrix:
      for (uint8_t i = 0; i < 25; ++i) {
        Pixels.setPixelColor(i, Pixels.Color(value, value, value));
      }
      Pixels.show();
      break;
    case A_Motor_Dir:
    case A_Motor_Speed:
      analogWrite(MOTOR_A1, modbus.Hreg(A_Motor_Dir) ? 0 : modbus.Hreg(A_Motor_Speed));
      analogWrite(MOTOR_A2, modbus.Hreg(A_Motor_Dir) ? modbus.Hreg(A_Motor_Speed) : 0);
      break;
    case B_Motor_Dir:
    case B_Motor_Speed:
      analogWrite(MOTOR_B1, modbus.Hreg(B_Motor_Dir) ? 0 : modbus.Hreg(B_Motor_Speed));
      analogWrite(MOTOR_B2, modbus.Hreg(B_Motor_Dir) ? modbus.Hreg(B_Motor_Speed) : 0);
      break;
    case C_Motor_Dir:
    case C_Motor_Speed:
      analogWrite(MOTOR_C1, modbus.Hreg(C_Motor_Dir) ? 0 : modbus.Hreg(C_Motor_Speed));
      analogWrite(MOTOR_C2, modbus.Hreg(C_Motor_Dir) ? modbus.Hreg(C_Motor_Speed) : 0);
    case D_Motor_Dir:
    case D_Motor_Speed:
      analogWrite(MOTOR_D1, modbus.Hreg(D_Motor_Dir) ? 0 : modbus.Hreg(D_Motor_Speed));
      analogWrite(MOTOR_D2, modbus.Hreg(D_Motor_Dir) ? modbus.Hreg(D_Motor_Speed) : 0);
      break;
    case E_Motor_Dir:
    case E_Motor_Speed:
      analogWrite(MOTOR_E1, modbus.Hreg(E_Motor_Dir) ? 0 : modbus.Hreg(E_Motor_Speed));
      analogWrite(MOTOR_E2, modbus.Hreg(E_Motor_Dir) ? modbus.Hreg(E_Motor_Speed) : 0);
      break;
    case F_Motor_Dir:
    case F_Motor_Speed:
      analogWrite(MOTOR_F1, modbus.Hreg(F_Motor_Dir) ? 0 : modbus.Hreg(F_Motor_Speed));
      analogWrite(MOTOR_F2, modbus.Hreg(F_Motor_Dir) ? modbus.Hreg(F_Motor_Speed) : 0);
      break;
  }
  return value;
}

void setup() {
  // Modbus
  Serial.begin(57600, SERIAL_8N1);
  modbus.begin(&Serial);
  modbus.setBaudrate(57600);
  modbus.server(1);

  modbus.addIreg(0x00, 0, F_Motor_EncoderValue + 1);

  modbus.addHreg(0x00, 0, F_Motor_Speed + 1);
  modbus.onSetHreg(0x00, cbHregs, F_Motor_Speed + 1);

  // Моторы
  pinMode(MOTOR_A1, OUTPUT);
  pinMode(MOTOR_A2, OUTPUT);
  analogWrite(MOTOR_A1, 0);
  analogWrite(MOTOR_A2, 0);
  pinMode(MOTOR_B1, OUTPUT);
  pinMode(MOTOR_B2, OUTPUT);
  analogWrite(MOTOR_B1, 0);
  analogWrite(MOTOR_B2, 0);
  pinMode(MOTOR_C1, OUTPUT);
  pinMode(MOTOR_C2, OUTPUT);
  analogWrite(MOTOR_C1, 0);
  analogWrite(MOTOR_C2, 0);
  pinMode(MOTOR_D1, OUTPUT);
  pinMode(MOTOR_D2, OUTPUT);
  analogWrite(MOTOR_D1, 0);
  analogWrite(MOTOR_D2, 0);
  //pinMode(MOTOR_E1, OUTPUT); pinMode(MOTOR_E2, OUTPUT); analogWrite(MOTOR_E1, 200); analogWrite(MOTOR_E2, 0);
  //pinMode(MOTOR_F1, OUTPUT); pinMode(MOTOR_F2, OUTPUT); analogWrite(MOTOR_F1, 200); analogWrite(MOTOR_F2, 0);

  //Port_A.begin(115200);
  for (Port &port : ports) port.hs.begin(115200);

  // Matrix
  Pixels.begin();
  Pixels.clear();
  Pixels.setBrightness(255);
  Pixels.show();
}

void loop() {
  modbus.task();

  static uint32_t timer = 0;
  if (millis() - timer >= 50) {
    timer = millis();
    for (Port &port : ports) {
      port.functionCode = 1;
      port.hs.write(1);
    }
  }
  //------------------------------
  for (uint8_t i = 0; i < 6; ++i) {
    if (ports[i].hs.available()) {
      if (ports[i].functionCode == 1) {
        ports[i].name = ports[i].hs.readStringUntil('\n');
        if (ports[i].name == "C") {
          ports[i].functionCode = 2;
          uint8_t data[5] = { 2, 0, 0, 0, 0 };
          ports[i].hs.write(data, 5);
        } else if (ports[i].name == "D") {
          ports[i].functionCode = 2;
          uint8_t data[6] = { 2, 0, 0, 0, 0, 0 };
          ports[i].hs.write(data, 6);
        } else if (ports[i].name == "F") {
          ports[i].functionCode = 9;
          ports[i].hs.write(9);
        }
      } else if (ports[i].name == "C") {
        switch (ports[i].functionCode) {
          case 2: {
            uint8_t data[] = {3, 0, 0, 0, 0};
            ports[i].functionCode = 3;
            modbus.Ireg(A_ColorSensor_InputRGB + portInputsNum * i, ports[i].hs.read() << 16);
            ports[i].hs.write(data, 5);
          } break;
          case 3: {
            uint8_t data[] = {4, 0, 0, 0, 0};
            ports[i].functionCode = 4;
            modbus.Ireg(A_ColorSensor_InputRGB + portInputsNum * i, ports[i].hs.read() << 8);
            ports[i].hs.write(data, 5);
          } break;
          case 4: {
            uint8_t data[] = {5, 0, 0, 0, 0};
            ports[i].functionCode = 5;
            modbus.Ireg(A_ColorSensor_InputRGB + portInputsNum * i, ports[i].hs.read());
            ports[i].hs.write(data, 5);
          } break;
          case 5: {
            ports[i].functionCode = 0;
            modbus.Ireg(A_ColorSensor_InputBrightness + portInputsNum * i, ports[i].hs.read());
          } break;
        }
      } else if (ports[i].name == "D" && ports[i].functionCode == 2) {
        ports[i].functionCode = 0;
        //Serial.println(ports[i].hs.read());
        modbus.Ireg(A_Sonar_Distance + portInputsNum * i, ports[i].hs.read());
      } else if (ports[i].name == "F" && ports[i].functionCode == 9) {
        ports[i].functionCode = 0;
        //Serial.println(ports[i].hs.read());
        modbus.Ireg(A_ForceSensor_Value + portInputsNum * i, ports[i].hs.read());
      }
    }
  }
  //------------------------------
  /*for (Port &port : ports) {
    if (port.hs.available()) {
      if (port.functionCode == 1) {
        port.name = ports[0].hs.readStringUntil('\n');
        if (port.name == "C") {
          port.functionCode = 2;
          uint8_t data[5] = { 2, 0, 0, 0, 0 };
          port.hs.write(data, 5);
        } else if (port.name == "D") {
          port.functionCode = 2;
          uint8_t data[6] = { 2, 0, 0, 0, 0, 0 };
          port.hs.write(data, 6);
        } else if (port.name == "F") {
          port.functionCode = 9;
          port.hs.write(9);
        }
      } else if (port.name == "C") {
        switch (port.functionCode) {
          case 2: {
            uint8_t data[] = {3, 0, 0, 0, 0};
            port.functionCode = 3;
            modbus.Ireg(A_ColorSensor_InputRGB, port.hs.read() << 16);
            port.hs.write(data, 5);
          } break;
          case 3: {
            uint8_t data[] = {4, 0, 0, 0, 0};
            port.functionCode = 4;
            modbus.Ireg(A_ColorSensor_InputRGB, port.hs.read() << 8);
            port.hs.write(data, 5);
          } break;
          case 4: {
            uint8_t data[] = {5, 0, 0, 0, 0};
            port.functionCode = 5;
            modbus.Ireg(A_ColorSensor_InputRGB, port.hs.read());
            port.hs.write(data, 5);
          } break;
          case 5: {
            port.functionCode = 0;
            modbus.Ireg(A_ColorSensor_InputBrightness, port.hs.read());
          } break;
        }
      } else if (port.name == "D" && port.functionCode == 2) {
        port.functionCode = 0;
        //Serial.println(port.hs.read());
        modbus.Ireg(A_Sonar_Distance, port.hs.read());
      } else if (port.name == "F" && port.functionCode == 9) {
        port.functionCode = 0;
        //Serial.println(port.hs.read());
        modbus.Ireg(A_ForceSensor_Value, port.hs.read());
      }
    }
  }*/
  //------------------------------
}
