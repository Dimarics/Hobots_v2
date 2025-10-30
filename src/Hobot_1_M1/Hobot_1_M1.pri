INCLUDEPATH += $$PWD

resources.files += \
    $$PWD/H1T1_Apps.qml \
    $$PWD/H1T1_ControlPanel.qml \
    $$PWD/H1T1_Device.qml

HEADERS += \
    $$PWD/h1t1_modbusinterface.h \
    $$PWD/h1t1_serialportinterface.h

SOURCES += \
    $$PWD/h1t1_modbusinterface.cpp \
    $$PWD/h1t1_serialportinterface.cpp
