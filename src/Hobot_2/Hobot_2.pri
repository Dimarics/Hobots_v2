CONFIG += qmltypes

#INCLUDEPATH

QML_IMPORT_PATH += $$PWD
QML_IMPORT_NAME = Hobots
QML_IMPORT_MAJOR_VERSION = 1
QML_IMPORT_MINOR_VERSION = 0

resources.files += \
    $$PWD/H2_Apps.qml \
    $$PWD/H2_ControlPanel.qml \
    $$PWD/H2_Device.qml
