#QT += quick serialport  serialbus

CONFIG += c++17

TARGET = Hobot_1_M1
TEMPLATE = lib
CONFIG += dynamiclib

#CONFIG += qmltypes
#QML_IMPORT_PATH = $$PWD
#QML_IMPORT_NAME = Hobots
#QML_IMPORT_MAJOR_VERSION = 1

RESOURCES += resources
resources.files += \
    H1T1_Apps.qml \
    H1T1_ControlPanel.qml \
    H1T1_Device.qml

#target.path = $PWD/../../build
#INSTALLS += target

win32 {
    install_path = $$OUT_PWD
    install_path ~= s,/,\\,g
    QMAKE_POST_LINK += $$quote(cmd /c copy /Y "$$install_path\\release\\$${TARGET}.dll" \
                                              "$$install_path\\..\\Desktop_Qt_6_7_2_MinGW_64_bit")
}

#qnx: target.path = /tmp/$$TARGET/bin
#else: unix:!android: target.path = /opt/$$TARGET/bin
#!isEmpty(target.path): INSTALLS += target

