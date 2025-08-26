//#include "windowcustomizer.h"

#include "appbackend.h"
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickView>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QProcess>

int main(int argc, char *argv[])
{
    //qputenv("QT_ENABLE_HIGHDPI_SCALING", "0");
    //qputenv("QT_USE_PHYSICAL_DPI ", "1");
    //qputenv("QT_SCALE_FACTOR", "1.5");
    QGuiApplication app(argc, argv);

    //qmlRegisterType<WindowCustomizer>("WindowCustomizer", 1, 0, "WindowCustomizer");
    qmlRegisterSingletonType(QUrl("qrc:/src/components/Style.qml"), "Style", 1, 0, "Style");
    qmlRegisterSingletonType<AppBackend>("App", 1, 0, "App", AppBackend::instance);
    QQmlApplicationEngine engine;
    //engine.addImportPath("qrc:/../QtExtras/qml");
    /*const QUrl url(QStringLiteral("qrc:/Hobots_qml/src/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl)
    { if (!obj && url == objUrl) QCoreApplication::exit(-1); }, Qt::QueuedConnection);*/
    engine.load("qrc:/src/main.qml");
    //qDebug() << qgetenv("QT_SCALE_FACTOR");
    app.exec();

    //QProcess restart;
    //restart.startDetached(app.arguments()[0], app.arguments());

    return true;
}
