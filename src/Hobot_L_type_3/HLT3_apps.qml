import QtQuick
import QtQuick.Layouts
import Components
import Apps.Scratch
import Apps.Scratch.Blocks
import Apps.Script
import "ScratchBlocks"

Item {
    id: root
    property Item currentPage: setPage(appsMenu)
    //implicitWidth: currentPage.implicitWidth
    //implicitHeight: currentPage.implicitHeight
    width: {
        var implicitWidth = currentPage.implicitWidth
        if (currentPage.anchors) implicitWidth += currentPage.anchors.leftMargin + currentPage.anchors.rightMargin
        return Math.max(implicitWidth, apps.width)
    }
    height: {
        var implicitHeight = currentPage.implicitHeight
        if (currentPage.anchors) implicitHeight += currentPage.anchors.topMargin + currentPage.anchors.bottomMargin
        return Math.max(implicitHeight, apps.height)
    }
    //width: Math.max(currentPage.implicitWidth, apps.width)
    //height: Math.max(currentPage.implicitHeight, apps.height)
    Component {
        id: scratch
        Scratch {
            fqbn: "STMicroelectronics:stm32:GenF4"
            boardOptions: "pnum=GENERIC_F413ZGTX,xserial=generic,usb=CDCgen,xusb=FS,opt=osstd,dbg=none,rtlib=nano,upload_method=hidMethod"
            programmingMode: true
            movement: [
                SetJoint { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                RotateMotor { list: ['A', 'B', 'C', 'D', 'E', 'F'] }
            ]
            controls: [
                LedStrip {},
                Delay {}
            ]
            sensors: [
                ButtonState { list: ["левая", "центральная", "правая"] },
                TouchSensor { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                ColorSensor { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                ColorSensorBrightness { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                ColorSensorRGB {},
                Sonar { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                SonarDetectionMode { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                SonarRGB {}
            ]
            //illuminance = (-0.32466F * r) + (1.57837F * g) + (-0.73191F * b)
            function setupCode() {
                return "
#include <Adafruit_NeoPixel.h>

const uint8_t left_btn   = PE6;
const uint8_t center_btn = PE5;
const uint8_t right_btn  = PE4;

uint8_t motors[6][2] {
    { PB11, PB10 },
    {  PB4,  PB3 },
    { PE14, PE13 },
    {  PB6,  PB5 },
    { PE11,  PE9 },
    {  PB1,  PB0 },
};

HardwareSerial ports[6] {
    HardwareSerial(PB12, PB13),
    HardwareSerial( PD0,  PD1),
    HardwareSerial( PG0,  PG1),
    HardwareSerial( PE0,  PE1),
    HardwareSerial( PF6,  PF7),
    HardwareSerial( PE2,  PE3),
};

Adafruit_NeoPixel LedStrip(25, PB14, NEO_GRB + NEO_KHZ800);

void rotateMotor(uint8_t i, bool dir, uint8_t speed) {
    analogWrite(motors[i][0], dir ? 0 : speed);
    analogWrite(motors[i][1], dir ? speed : 0);
}

void setColor(uint8_t i, uint8_t r, uint8_t g, uint8_t b) {
    LedStrip.setPixelColor(i, LedStrip.Color(r, g, b));
    LedStrip.show();
}

bool readButton(uint8_t i) {
    switch(i) {
    case 0: return !digitalRead(left_btn);
    case 1: return !digitalRead(center_btn);
    case 2: return !digitalRead(right_btn);
    }
    return false;
}

void waitForBytesAvailable(HardwareSerial &port, int size) {
    uint32_t timeout = millis();
    while (port.available() < size && millis() - timeout >= 50){}
}

void getColor(uint8_t i, uint8_t *r, uint8_t *g, uint8_t *b, uint16_t *c) {
    uint8_t package[5] = { 2, 0, 0, 0, 0 };
    ports[i].write(package, 5);
    waitForBytesAvailable(ports[i], 8);
    uint16_t red = (ports[i].read() << 8) | ports[i].read();
    uint16_t green = (ports[i].read() << 8) | ports[i].read();
    uint16_t blue = (ports[i].read() << 8) | ports[i].read();
    uint16_t clear = (ports[i].read() << 8) | ports[i].read();
    if (clear == 0) {
        *r = *g = *b = 0;
        return;
    }
    *r = (float)red / (float)clear * 255.f;
    *g = (float)green / (float)clear * 255.f;
    *b = (float)blue / (float)clear * 255.f;
    *c = clear;
}

uint8_t getRed(uint8_t i) {
    uint8_t r, g, b;
    uint16_t c;
    getColor(i, &r, &g, &b, &c);
    return r;
}

uint8_t getGreen(uint8_t i) {
    uint8_t r, g, b;
    uint16_t c;
    getColor(i, &r, &g, &b, &c);
    return g;
}

uint8_t getBlue(uint8_t i) {
    uint8_t r, g, b;
    uint16_t c;
    getColor(i, &r, &g, &b, &c);
    return b;
}

void setColorSensorBrightness(uint8_t i, uint8_t val) {
  uint8_t data[5] = {3, val, 0, 0, 0};
  ports[i].write(data, 5);
}

uint16_t getIlluminance(uint8_t i) {
    uint8_t r, g, b;
    uint16_t c;
    getColor(i, &r, &g, &b, &c);
    return c;
}

uint16_t getReflection(uint8_t i) {
    uint8_t r, g, b;
    uint16_t c;
    setColorSensorBrightness(i, 255);
    getColor(i, &r, &g, &b, &c);
    return c;
}

void setColorSensorRGB(uint8_t i, uint8_t r, uint8_t g, uint8_t b) {
  uint8_t data[5] = {4, 0, r, g, b};
  ports[i].write(data, 5);
}

uint8_t touchSensor(uint8_t i) {
    uint8_t package[5] = { 2, 0, 0, 0, 0 };
    ports[i].write(package, 5);
    waitForBytesAvailable(ports[i], 2);
    uint16_t raw_adc = (ports[i].read() << 8) | ports[i].read();
    return map(raw_adc, 50, 4050, 0, 90);
}

float getDistance(uint8_t i, float scale) {
    uint8_t data[5] = { 2, 0, 0, 0, 0 };
    ports[i].write(data, 5);
    waitForBytesAvailable(ports[i], 2);
    uint16_t distance = (ports[i].read() << 8) | ports[i].read();
    return (float)distance * scale;
}

void setSonarRGB(uint8_t i, uint8_t n, uint8_t r, uint8_t g, uint8_t b) {
  uint8_t data[5] = {3, n, r, g, b};
  ports[i].write(data, 5);
}

void settings() {
    for (uint8_t *motor : motors) {
        pinMode(motor[0], OUTPUT);
        pinMode(motor[1], OUTPUT);
        analogWrite(motor[0], 0);
        analogWrite(motor[1], 0);
    }
    for (HardwareSerial &port : ports) port.begin(115200);

    pinMode(left_btn, INPUT);
    pinMode(center_btn, INPUT);
    pinMode(right_btn, INPUT);

    LedStrip.begin();
    LedStrip.clear();
    LedStrip.setBrightness(255);
    LedStrip.show();
}\n\n"
            }
        }
    }
    Component {
        id: script
        Script {}
    }
    Component {
        id: appsMenu
        RowLayout {
            spacing: 1
            anchors.margins: 16
            //Layout.margins: 16
            //Layout.preferredWidth: apps.width; Layout.preferredHeight: apps.height
            ModeButton {
                //id: scratchButton
                text: "Scratch"
                icon.source: "qrc:/images/scratch.svg"
                icon.width: 160; icon.height: 160
                onClicked: setPage(scratch)
            }
            ModeButton {
                visible: false
                text: "Скрипт"
                icon.source: "qrc:/images/script.svg"
                icon.width: 160; icon.height: 160
                onClicked: setPage(script)
            }
        }
    }
    Component.onCompleted: setPage(scratch)
    function setPage(page) {
        if (currentPage) currentPage.destroy()
        currentPage = page.createObject(this, { 'anchors.fill': this })
        if (currentPage.exit) currentPage.exit.connect(() => setPage(appsMenu))
    }
}

/*StackLayout {
    implicitWidth: children[currentIndex].implicitWidth
    implicitHeight: children[currentIndex].implicitHeight
    //width: Math.max(children[currentIndex].implicitWidth, apps.width)
    //height: Math.max(children[currentIndex].implicitHeight, apps.height)
    currentIndex: 0
    RowLayout {
        id: menu
        spacing: 1
        Layout.margins: 16
        Layout.preferredWidth: apps.width; Layout.preferredHeight: apps.height
        ModeButton {
            id: scratch
            text: "Scratch"
        }
        ModeButton {
            text: "Скрипт"
        }
    }
}*/
