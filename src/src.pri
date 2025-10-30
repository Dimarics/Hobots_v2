include(Components/Components.pri)
include(Apps/Apps.pri)
include(interfaces/interfaces.pri)
#include(Hobot_1_type_1/Hobot_1_type_1.pri)
include(Hobot_D/Hobot_D.pri)
include(Hobot_L_type_2/Hobot_L_type_2.pri)
include(Hobot_L_type_3/Hobot_L_type_3.pri)

INCLUDEPATH += $$PWD
QML_IMPORT_PATH += $$PWD

HEADERS += \
    $$PWD/appbackend.h

SOURCES += \
    $$PWD/appbackend.cpp \
    $$PWD/main.cpp

resources.files += \
    $$PWD/main.qml
