#include(QtExtras.pri)
include(src/src.pri)

QT += quick
CONFIG += qmltypes

QML_IMPORT_NAME = Hobots
QML_IMPORT_MAJOR_VERSION = 1

resources.prefix = /$${TARGET}
RESOURCES += resources \
    resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
#QML_IMPORT_PATH += qrc:/../QtExtras/qml

# Additional import path used to resolve QML modules just for Qt Quick Designer
#QML_DESIGNER_IMPORT_PATH = ../QtExtras

LIBS += -lgdi32 -ldwmapi #-luxtheme -lgdiplus -lMsimg32

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
