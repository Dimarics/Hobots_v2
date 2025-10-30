#QT += quick serialport serialbus

CONFIG += c++17

TARGET = Hobot_2
TEMPLATE = lib
CONFIG += dynamiclib

#CONFIG += qmltypes
#QML_IMPORT_PATH = $$PWD
#QML_IMPORT_NAME = Hobots
#QML_IMPORT_MAJOR_VERSION = 1

RESOURCES += resources
resources.files += \
    H2_Apps.qml \
    H2_ControlPanel.qml \
    H2_Device.qml

win32 {
    install_path = $$OUT_PWD
    install_path ~= s,/,\\,g
    QMAKE_POST_LINK += $$quote(cmd /c copy /Y "$$install_path\\release\\$${TARGET}.dll" \
                                              "$$install_path\\..\\Desktop_Qt_6_7_2_MinGW_64_bit")
}
