INCLUDEPATH += $$PWD

resources.files += \
    $$PWD/HLT3_apps.qml \
    $$PWD/HLT3_device.qml

HEADERS += \
    $$PWD/hlt3_modbusinterface.h \
    $$PWD/hlt3_serialportinterface.h

SOURCES += \
    $$PWD/hlt3_modbusinterface.cpp \
    $$PWD/hlt3_serialportinterface.cpp
