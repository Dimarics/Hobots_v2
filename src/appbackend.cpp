#include "appbackend.h"

AppBackend::AppBackend() : m_availableDevices {
                               "Хобот L Т3",
                               "empty"
                               },
    m_device(nullptr)
{
    startTimer(200);
}

/*QObject *AppBackend::instance(QQmlEngine*, QJSEngine*) {
    AppBackend *instance = new AppBackend;
    return instance;
}*/

//QStringList AppBackend::availablePorts() const { return m_serialPorts; }

void AppBackend::setAvailableDevices(const QStringList &availableDevices) {
    m_availableDevices = availableDevices;
    emit availableDevicesChanged();
}

//QStringList AppBackend::availableDevices() const { return m_availableDevices; }

void AppBackend::setDevice(QObject *device)
{
    if (device == m_device) return;
    if (m_device) m_device->deleteLater();//QMetaObject::invokeMethod(m_device, "destroy");
    m_device = device;
    emit deviceChanged();
}

//QObject *AppBackend::device() const { return m_device; }

void AppBackend::saveFile(const QByteArray &data, const QString &path) const
{
    QFileInfo fileInfo(path);
    if (!fileInfo.dir().exists()) QDir().mkpath(fileInfo.path());
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Не удалось сохранить файл";
        return;
    }
    //file.write(data.toUtf8());
    file.write(data);
}

/*void AppBackend::saveSettings(const QString &data) const {
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!QDir(appDataPath).exists()) QDir().mkpath(appDataPath);
    saveFile(data, appDataPath + "/settings.json");
}

void AppBackend::saveDeviceSettings(const QString &data) const {
    QString deviceDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + '/' + m_device->objectName();
    if (!QDir(deviceDataPath).exists()) QDir().mkpath(deviceDataPath);
    saveFile(data, deviceDataPath + '/' + m_device->objectName() + ".json");
}*/

QByteArray AppBackend::readFile(const QString &path) const
{
    //if (!QDir(path).exists()) QDir().mkpath(path);
    //QDir temp(QStandardPaths::writableLocation(QStandardPaths::TempLocation) + "/Hobots/");
    //if (temp.exists()) temp.removeRecursively();
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Невозможно открыть файл";
        return {};
    }
    return file.readAll();
}

/*QString AppBackend::readSettings() const {
    return readFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/settings.json");
}

QString AppBackend::readDeviceSettings() const {
    return readFile(QString(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/%1/%1.json").arg(m_device->objectName()));
}*/

QVariant AppBackend::readJSON(const QString &path) const
{
    QJsonParseError error;
    QByteArray rawData = readFile(path);
    if (rawData.isEmpty()) {
        qWarning() << "Файл пуст или не существует"; return {};
    }
    QJsonDocument json = QJsonDocument::fromJson(rawData, &error);
    if (error.error != QJsonParseError::NoError) {
        qWarning() << error.errorString(); return {};
    }
    return json.toVariant();
}

void AppBackend::timerEvent(QTimerEvent*) {
    const QList<QSerialPortInfo> new_list = QSerialPortInfo::availablePorts();

    bool replace = false;
    if (m_serialPorts.size() != new_list.size()) {
        replace = true;
    } else {
        for (qsizetype i = 0; i < m_serialPorts.size(); ++i)
            if (m_serialPorts.at(i) != new_list.at(i).portName())
                replace = true;
    }
    if (replace) {
        m_serialPorts.clear();
        for (const QSerialPortInfo &serialPortInfo : QSerialPortInfo::availablePorts()) {
            m_serialPorts << serialPortInfo.portName();
        }
        emit availablePortsChanged();
    }
}
