#ifndef WINDOWCUSTOMIZER_H
#define WINDOWCUSTOMIZER_H

#include <windows.h>
#include <dwmapi.h>
#include <qqml.h>
#include <QPainter>
#include <QObject>
#include <QWindow>

//extern Q_DECL_IMPORT void qt_blurImage(QPainter *painter, QImage &blurImage, qreal radius, bool quality, bool alphaOnly, int transposed = 0);

class WindowCustomizer : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(WindowCustomizer)
    Q_PROPERTY(QWindow* window READ window WRITE setWindow NOTIFY windowChanged)

public:
    WindowCustomizer(QObject *parent = nullptr);
    void setWindow(QWindow *window);
    QWindow *window() const;

private:
    static WNDPROC WndProc;
    static LRESULT CALLBACK CustomizerWndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
    static LRESULT CALLBACK CallWndProc(int nCode, WPARAM wParam, LPARAM lParam);
    QWindow* m_window;

signals:
    void windowChanged();
};

#endif // WINDOWCUSTOMIZER_H
