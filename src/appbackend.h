#ifndef APPBACKEND_H
#define APPBACKEND_H

#pragma once
//#include <QObject>
#include <QtQmlIntegration>
#include <QQmlEngine>
#include <QtSerialPort/QSerialPortInfo>

class AppBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString tempLocation READ tempLocation CONSTANT)
    Q_PROPERTY(QString appDataLocation READ appDataLocation CONSTANT)
    Q_PROPERTY(QString deviceName READ deviceName WRITE setDeviceName NOTIFY deviceNameChanged)
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QStringList availableDevices READ availableDevices WRITE setAvailableDevices NOTIFY availableDevicesChanged)
    Q_PROPERTY(QObject *device READ device WRITE setDevice NOTIFY deviceChanged)

public:
    AppBackend();
    static inline QString tempLocation() { return QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/Hobots/"; }
    static inline QString appDataLocation() { return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/"; }
    static inline QObject* instance(QQmlEngine*, QJSEngine*) { return new AppBackend; }
    inline QString deviceName() { return m_deviceName; }
    inline void setDeviceName(const QString &deviceName) { m_deviceName = deviceName; emit deviceNameChanged(); }
    inline QStringList availablePorts() const { return m_serialPorts; }
    void setAvailableDevices(const QStringList &availableDevices);
    inline QStringList availableDevices() const { return m_availableDevices; }
    void setDevice(QObject *device);
    inline QObject *device() const { return m_device; }
    Q_INVOKABLE void saveFile(const QByteArray &data, const QString &path) const;
    Q_INVOKABLE void saveFile(const QByteArray &data, const QUrl &url) const;
    //Q_INVOKABLE void saveSettings(const QString &data) const;
    //Q_INVOKABLE void saveDeviceSettings(const QString &data) const;
    Q_INVOKABLE QByteArray readFile(const QString &path) const;
    Q_INVOKABLE QByteArray readFile(const QUrl &url) const;
    //Q_INVOKABLE QString readSettings() const;
    //Q_INVOKABLE QString readDeviceSettings() const;
    Q_INVOKABLE QVariant readJSON(const QString &path) const;
    Q_INVOKABLE QVariant readJSON(const QUrl &url) const;

private:
    QString m_deviceName;
    QStringList m_serialPorts;
    QStringList m_availableDevices;
    QObject *m_device;
    void timerEvent(QTimerEvent*) override;

signals:
    void deviceNameChanged();
    void availablePortsChanged();
    void availableDevicesChanged();
    void deviceChanged();
};

#endif // APPBACKEND_H
