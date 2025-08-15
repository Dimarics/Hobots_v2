#include(QtExtras.pri)
include(src/src.pri)

QT += quick \
    serialport  serialbus


CONFIG += c++17

TARGET = Hobots
CONFIG += qmltypes

QML_IMPORT_NAME = Hobots
QML_IMPORT_MAJOR_VERSION = 1

#resources.prefix = /$$TARGET
RESOURCES += resources \
    resources.qrc

#QML_IMPORT_PATH += qrc:/../QtExtras/qml

#QML_DESIGNER_IMPORT_PATH = ../QtExtras

qnx: target.path = /tmp/$$TARGET/bin
else: unix:!android: target.path = /opt/$$TARGET/bin
!isEmpty(target.path): INSTALLS += target

win32: {
    RC_FILE = resources.rc
    #LIBS += -lopengl32
    LIBS += -lgdi32 -ldwmapi #-luxtheme -lgdiplus -lMsimg32
    #LIBS += -lopencv_core470 -lopencv_highgui470 -lopencv_imgcodecs470 -lopencv_imgproc470
}
unix: {
    #INCLUDEPATH += /usr/local/opencv/include/opencv4
    #LIBS += -lopencv_core -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc
}
