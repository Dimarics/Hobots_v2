include(components/components.pri)
include(modes/modes.pri)
include(Hobot_L_type_3/Hobot_L_type_3.pri)

INCLUDEPATH += $$PWD

HEADERS += \
    $$PWD/windowcustomizer.h

SOURCES += \
    $$PWD/main.cpp \
    $$PWD/windowcustomizer.cpp

resources.files += \
    $$PWD/main.qml \
    $$PWD/CustomWindow.qml
