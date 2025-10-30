#ifndef APPBACKEND_H
#define APPBACKEND_H

#pragma once
//#include <QObject>
#include <QtQmlIntegration>
#include <QQmlEngine>

#ifndef WASM_PLATFORM
#include <QtSerialPort/QSerialPortInfo>
#endif

class AppBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString tempLocation READ tempLocation CONSTANT)
    Q_PROPERTY(QString appDataLocation READ appDataLocation CONSTANT)
    Q_PROPERTY(QString deviceName READ deviceName WRITE setDeviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(QStringList availableDevices READ availableDevices WRITE setAvailableDevices NOTIFY availableDevicesChanged)
    Q_PROPERTY(QObject *device READ device WRITE setDevice NOTIFY deviceChanged)
#ifndef WASM_PLATFORM
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
#endif

public:
    AppBackend();
    static inline QString tempLocation() { return QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/Hobots/"; }
    static inline QString appDataLocation() { return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/"; }
    static inline AppBackend* instance() { static AppBackend *instance = new AppBackend; return instance; };
    static inline AppBackend* qmlInstance(QQmlEngine*, QJSEngine*) { return instance(); }
    inline QString deviceName() { return m_deviceName; }
    inline void setDeviceName(const QString &deviceName) { m_deviceName = deviceName; emit deviceNameChanged(); }
    void setAvailableDevices(const QStringList &availableDevices);
    inline QStringList availableDevices() const { return m_availableDevices; }
    void setDevice(QObject *device);
    inline QObject *device() const { return m_device; }
    Q_INVOKABLE void saveFile(const QByteArray &data, const QString &path) const;
    Q_INVOKABLE void saveFile(const QByteArray &data, const QUrl &url) const;
    Q_INVOKABLE QByteArray readFile(const QString &path) const;
    Q_INVOKABLE QByteArray readFile(const QUrl &url) const;
    Q_INVOKABLE QVariant readJSON(const QString &path) const;
    Q_INVOKABLE QVariant readJSON(const QUrl &url) const;
#ifndef WASM_PLATFORM
    inline QStringList availablePorts() const { return m_serialPorts; }
    Q_INVOKABLE bool loadModel(const QString &path) const;
#endif

private:
    QString m_deviceName;
    QStringList m_availableDevices;
    QObject *m_device;
#ifndef WASM_PLATFORM
    QStringList m_serialPorts;
    QLibrary *m_model;
    void timerEvent(QTimerEvent*) override;
#endif

signals:
    void deviceNameChanged();
    void deviceChanged();
    void availableDevicesChanged();
#ifndef WASM_PLATFORM
    void availablePortsChanged();
#endif
};

#endif // APPBACKEND_H
