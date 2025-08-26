include(components/components.pri)
include(interfaces/interfaces.pri)
include(modes/modes.pri)
include(Hobot_L_type_3/Hobot_L_type_3.pri)

INCLUDEPATH += $$PWD
QML_IMPORT_PATH += $$PWD

HEADERS += \
    $$PWD/appbackend.h \
    $$PWD/windowcustomizer.h

SOURCES += \
    $$PWD/appbackend.cpp \
    $$PWD/main.cpp \
    $$PWD/windowcustomizer.cpp

resources.files += \
    $$PWD/main.qml \
    $$PWD/CustomWindow.qml
