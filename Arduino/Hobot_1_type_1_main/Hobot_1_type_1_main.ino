#include <ModbusRTU.h>

enum Inputs : uint8_t {
};

enum Holdings : uint8_t {
  JointValue,
  Speed,
};

ModbusRTU modbus;

uint16_t cbLed(TRegister *reg, uint16_t val) {
  if (reg->address.address == 0x01) digitalWrite(13, COIL_BOOL(val));
  return val;
}

uint16_t cbHregs(TRegister *reg, uint16_t value) {
  switch (reg->address.address) {
    case JointValue:
      digitalWrite(13, COIL_BOOL(value));
      break;
  }
  return value;
}

void setup() {
  pinMode(13, OUTPUT);
  // Modbus
  Serial.begin(57600);
  Serial3.begin(57600);
  /*modbus.begin(&Serial);
  modbus.setBaudrate(57600);
  modbus.server(1);

  //modbus.addIreg(0x00, 0, JointValue + 1);

  modbus.addHreg(0x00, 0, Speed + 1);
  modbus.onSetHreg(0x00, cbHregs, Speed + 1);*/
}

void loop() {
  if (Serial3.available()) {
    while (Serial3.available()) {
      Serial.print(Serial3.read(), HEX);
      Serial.print("|");
    }
  }
  /*modbus.task();

  static uint32_t timer = 0;
  if (millis() - timer >= 50) {
    timer = millis();
  }*/
}
