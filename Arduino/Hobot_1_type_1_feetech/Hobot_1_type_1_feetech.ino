#include "HobotDevice.h"
#include "HobotServoFeetech.h"

/*
    { 0, 0, 1.0, false },
    { 90, 90, 0.6, true },
    { 180, 180, 0.7, false },
    { 180, 180, 1.0, true },
    { 0, 0, 1.7, false },
    { 0, -30, 2.0, false },
*/

const uint8_t dir_pin = 2;
const uint8_t joints_count = 6;

SMS_STS st;

HobotServo* joints[joints_count] {
  new HobotServoFeetech(1, st,   0,   0, false),
  new HobotServoFeetech(2, st,  90,  90, true),
  new HobotServoFeetech(3, st, 180, 180, false),
  new HobotServoFeetech(4, st, 180, 180, true),
  new HobotServoFeetech(5, st,   0,   0, false),
  new HobotServoFeetech(6, st,   0, -30, false),
};

HobotDevice device("Хобот 1 М1", joints, joints_count);

void setup() {
  Serial2.begin(1000000);
  st.pSerial = &Serial2;
  st.DirPin = dir_pin;
  pinMode(dir_pin, OUTPUT);
  //delay(100);
  device.beginSerial(Serial, 57600);
  device.goHome();
  float speed = 40;
  joints[0]->setSpeed(speed);
  joints[1]->setSpeed(speed * 0.6);
  joints[2]->setSpeed(speed * 0.7);
  joints[3]->setSpeed(speed);
  joints[4]->setSpeed(speed * 1.7);
  joints[5]->setSpeed(speed * 2.0);
}

void loop() {
  device.poll();
}
