#ifndef HTTPINTERFACE_H
#define HTTPINTERFACE_H

#include "hobotsprotocolinterface.h"
#include <QNetworkAccessManager>

class HttpInterface : public HobotsProtocolInterface
{
    Q_OBJECT
    QML_ELEMENT
public:
    HttpInterface();
    void send(quint8 function_code, const QByteArray &data = {}) override;

private:
    QNetworkAccessManager *m_networkManager;
};

#endif // HTTPINTERFACE_H
