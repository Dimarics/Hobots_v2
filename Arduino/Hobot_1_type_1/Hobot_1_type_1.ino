#define JOINTS_COUNT 4

enum FunctionCode {
  MessageAccepted = 0x01,
  GetModelName,
  ModelName,
  GetJoints,
  JointsValues,
  SetJoint,
  SetJoints,
  RotateMotor,
  Stop
};
#pragma pack(push, 1)
struct DeviceInfo {
  bool button_1;
  bool button_2;
  uint32_t joint_1;
  uint32_t joint_2;
};
#pragma pack(pop)

//char data[sizeof(DeviceInfo)]{};
DeviceInfo device_info{ true, false, 456, 8760 };
char buffer[32]{};

void setup() {
  Serial.begin(57600);
}

void loop() {
  //sendPacket(WriteData, reinterpret_cast<char*>(&device_info), sizeof(DeviceInfo));
  while (Serial.available() >= 5) {
    if (Serial.read() != 0xFF) continue;
    if (Serial.read() != 0xFF) continue;
    uint8_t size = Serial.read();
    uint8_t function_code = Serial.read();

    // ожидание оставшихся байт
    if (size) {
      bool stop = false;
      static uint32_t timeout;
      timeout = millis();
      while (Serial.available() - 1 < size) {
        if (millis() - timeout >= 500) {
          stop = true;
          break;
        }
      }
      if (stop) break;
      Serial.readBytes(buffer, size);
    }
    //------------------
    // read data
    /*static uint32_t timeout;
    timeout = millis();
    for (int i = 0; i < size;) {
      if (millis() - timeout >= 1000) {
        // read timeout error
        break;
      }
      if (Serial.peek() != -1) { buffer[i] = Serial.read(); ++i; }
    }*/
    //------------------
    uint8_t crc = function_code;
    for (int i = 0; i < size; ++i) crc += buffer[i];
    int crc_in = Serial.read();
    if (crc != crc_in) {
      // ошибка контрольной суммы
      Serial.write(crc);
      Serial.write(' ');
      Serial.write(crc_in);
      continue;
    }
    switch (function_code) {
      case GetModelName:
      {
        static char modelName[] = "Хобот 1 М1";
        sendPacket(ModelName, modelName, sizeof(modelName) - 1);
      }
        break;
      case GetJoints:
        {
          char data[JOINTS_COUNT * 4 + 1]{ JOINTS_COUNT };
          float* joint_values = reinterpret_cast<float*>(&data[1]);
          joint_values[0] = 34.05;
          joint_values[1] = 77.07;
          joint_values[2] = 22.03;
          joint_values[3] = 54.27;
          sendPacket(JointsValues, data, sizeof(data));
          /*char data[9];
          data[0] = 7;
          reinterpret_cast<float*>(&data[1])[0] = 54.27;
          reinterpret_cast<float*>(&data[1])[1] = 86.08;
          sendPacket(JointsValues, data, 9);*/
        }
        break;
      default:

        break;
    }
  }
  //Serial.write('\n');
  //delay(1000);
}

void sendPacket(uint8_t function_code) {
  Serial.write(0xFF);
  Serial.write(0xFF);
  Serial.write(int(0));
  Serial.write(function_code);
  char crc = function_code;
  Serial.write(crc);
}

void sendPacket(uint8_t function_code, char *data, uint8_t size) {
  Serial.write(0xFF);
  Serial.write(0xFF);
  Serial.write(size);
  Serial.write(function_code);
  //memcpy(data, &device_info, sizeof(DeviceInfo));
  Serial.write(data, size);
  char crc = function_code;
  for (int i = 0; i < size; ++i) crc += data[i];
  Serial.write(crc);
}
