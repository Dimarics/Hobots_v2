#include(QtExtras.pri)
include(src/src.pri)

QT += quick \
    serialport serialbus

CONFIG += c++17

TARGET = Hobots
CONFIG += qmltypes

QML_IMPORT_PATH += $$PWD
QML_IMPORT_NAME = Hobots
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

#resources.prefix = /$$TARGET
RESOURCES += resources \
    resources.qrc

#QML_DESIGNER_IMPORT_PATH += $$OUT_PWD/release

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

android {
    DISTFILES += \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/gradle.properties \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew \
        android/gradlew.bat \
        android/res/values/libs.xml \
        android/res/xml/qtprovider_paths.xml

    contains(ANDROID_TARGET_ARCH, arm64-v8a) {
        ANDROID_PACKAGE_SOURCE_DIR = \
            $$PWD/android
    }
}

qnx: target.path = /tmp/$$TARGET/bin
else: unix:!android: target.path = /opt/$$TARGET/bin
!isEmpty(target.path): INSTALLS += target
