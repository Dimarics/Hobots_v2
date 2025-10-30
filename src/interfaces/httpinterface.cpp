#include "httpinterface.h"
#include <QHostAddress>

HttpInterface::HttpInterface() : m_networkManager(new QNetworkAccessManager(this))
{
    m_networkManager->connectToHost(QHostAddress(QHostAddress::Any).toString(), 80);
}

void HttpInterface::send(quint8 function_code, const QByteArray &data)
{
    QNetworkRequest request(QUrl("device"));
    m_networkManager->post(request, function_code + data);
}
