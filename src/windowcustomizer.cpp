#include "windowcustomizer.h"
#include "qdebug.h"

const int margin = 9;

typedef BOOL (WINAPI *PFN_ISWINDOWARRANGED)(HWND);
PFN_ISWINDOWARRANGED isWindowArranged = NULL;

WNDPROC WindowCustomizer::WndProc;

WindowCustomizer::WindowCustomizer(QObject *parent) : QObject(parent), m_window(nullptr) {
    if (!isWindowArranged) {
        HMODULE hUser32 = GetModuleHandle(L"user32.dll");
        if (hUser32) isWindowArranged = (PFN_ISWINDOWARRANGED)GetProcAddress(hUser32, "IsWindowArranged");
    }
}

void WindowCustomizer::setWindow(QWindow *window)
{
    if (m_window != window) {
        m_window = window;
        if (window) {
            HWND hWnd = (HWND)window->winId();
            //DWM
            //DWMNCRENDERINGPOLICY policy = DWMNCRP_DISABLED;
            //DwmSetWindowAttribute(hWnd, DWMWA_NCRENDERING_POLICY, &policy, sizeof(policy));
            /*MARGINS margins;
            margins.cyTopHeight = margin;
            margins.cyBottomHeight = margin;
            margins.cxLeftWidth = margin;
            margins.cxRightWidth = margin;
            DwmExtendFrameIntoClientArea(hWnd, &margins);*/
            //
            WndProc = (WNDPROC)GetWindowLongPtr(hWnd, GWLP_WNDPROC);
            SetWindowLongPtr(hWnd, GWLP_WNDPROC, (LONG_PTR)CustomizerWndProc);
            //MoveWindow(hWnd, window->x(), window->y(), window->width(), window->height(), true);
            //connect(window, &QWindow::widthChanged, this, [](int width){ qDebug() << width; });
            //SetWindowsHookExA(WH_CALLWNDPROC, CallWndProc, NULL, NULL);
        }
        emit windowChanged();
    }
}

QWindow *WindowCustomizer::window() const { return m_window; }


LRESULT CALLBACK WindowCustomizer::CustomizerWndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
//LRESULT WINAPI CustomizerWndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch (msg) {
    case WM_EXITSIZEMOVE:
    {
        if (isWindowArranged && isWindowArranged(hWnd)) {
            RECT rc;
            GetWindowRect(hWnd, &rc);
            int x = rc.left - margin;
            int y = rc.top - margin;
            int width = rc.right - rc.left + margin * 2;
            int height = rc.bottom - rc.top + margin * 2;
            MoveWindow(hWnd, x, y, width, height, true);
        }
    }
        break;
        /*case WM_WINDOWPOSCHANGING:
    {
        WINDOWPOS* windowpos = (WINDOWPOS*)lParam;
        int halfScreenWidth = (GetSystemMetrics(SM_CXMAXIMIZED) - margin) / 2;
        int halfScreenHeight = (GetSystemMetrics(SM_CYMAXIMIZED)) / 2;
        //qDebug() << windowpos->cy + windowpos->y;//<< halfScreenHeight;
        if (windowpos->x == 0) {
            windowpos->x = -margin;
            windowpos->cx += margin * 2;
        }
        if (windowpos->y == 0) {
            windowpos->y = -margin;
            windowpos->cy += margin * 2;
        }
        break;
    }*/
        /*case WM_GETMINMAXINFO:
    {
        MINMAXINFO* minMaxInfo = (MINMAXINFO*)lParam;
        minMaxInfo->ptMinTrackSize.x = 300;
        minMaxInfo->ptMinTrackSize.y = 200;
        break;
    }*/
    case WM_NCCALCSIZE:
    {
        if (wParam) {
            NCCALCSIZE_PARAMS* pParams = (NCCALCSIZE_PARAMS*)lParam;
            pParams->rgrc[0].top += margin;
            pParams->rgrc[0].bottom -= margin;
            pParams->rgrc[0].left += margin;
            pParams->rgrc[0].right -= margin;
        }
        return 0;
    }
    case WM_NCACTIVATE:
        return wParam ? 0 : 1;
    case WM_NCPAINT:
    {
        // Получаем контекст устройства для неклиентской области
        HDC hdc = GetWindowDC(hWnd);

        // Получаем размеры неклиентской области
        RECT rc;
        GetWindowRect(hWnd, &rc);
        OffsetRect(&rc, -rc.left, -rc.top);

        // Рисуем кастомный заголовок
        //HBRUSH hBrush = CreateSolidBrush(RGB(255, 0, 0));
        //FillRect(hdc, &rc, hBrush);
        //DeleteObject(hBrush);
        QImage shadow(rc.right, rc.bottom, QImage::Format_ARGB32);
        int clWidth = rc.right - margin * 2;
        int clHeight = rc.bottom - margin * 2;
        shadow.fill(Qt::transparent);

        QLinearGradient leftShadow(0, 0, 1, 0);
        leftShadow.setCoordinateMode(QGradient::ObjectMode);
        leftShadow.setColorAt(0, Qt::transparent);
        leftShadow.setColorAt(0.5, QColor(0, 0, 0, 25));
        leftShadow.setColorAt(1, QColor(0, 0, 0, 70));

        QRadialGradient leftTopShadow(1, 1, 1);
        leftTopShadow.setCoordinateMode(QGradient::ObjectMode);
        leftTopShadow.setColorAt(0, QColor(0, 0, 0, 60));
        leftTopShadow.setColorAt(0.5, QColor(0, 0, 0, 20));
        leftTopShadow.setColorAt(1, Qt::transparent);

        QLinearGradient topShadow(0, 0, 0, 1);
        topShadow.setCoordinateMode(QGradient::ObjectMode);
        topShadow.setColorAt(0, Qt::transparent);
        topShadow.setColorAt(0.5, QColor(0, 0, 0, 25));
        topShadow.setColorAt(1, QColor(0, 0, 0, 70));

        QRadialGradient rightTopShadow(0, 1, 1);
        rightTopShadow.setCoordinateMode(QGradient::ObjectMode);
        rightTopShadow.setColorAt(0, QColor(0, 0, 0, 60));
        rightTopShadow.setColorAt(0.5, QColor(0, 0, 0, 20));
        rightTopShadow.setColorAt(1, Qt::transparent);

        QLinearGradient rightShadow(0, 0, 1, 0);
        rightShadow.setCoordinateMode(QGradient::ObjectMode);
        rightShadow.setColorAt(0, QColor(0, 0, 0, 70));
        rightShadow.setColorAt(0.5, QColor(0, 0, 0, 25));
        rightShadow.setColorAt(1, Qt::transparent);

        QRadialGradient rightBottomShadow(0, 0, 1);
        rightBottomShadow.setCoordinateMode(QGradient::ObjectMode);
        rightBottomShadow.setColorAt(0, QColor(0, 0, 0, 60));
        rightBottomShadow.setColorAt(0.5, QColor(0, 0, 0, 20));
        rightBottomShadow.setColorAt(1, Qt::transparent);

        QLinearGradient bottomShadow(0, 0, 0, 1);
        bottomShadow.setCoordinateMode(QGradient::ObjectMode);
        bottomShadow.setColorAt(0, QColor(0, 0, 0, 70));
        bottomShadow.setColorAt(0.5, QColor(0, 0, 0, 25));
        bottomShadow.setColorAt(1, Qt::transparent);

        QRadialGradient leftBottomShadow(1, 0, 1);
        leftBottomShadow.setCoordinateMode(QGradient::ObjectMode);
        leftBottomShadow.setColorAt(0, QColor(0, 0, 0, 60));
        leftBottomShadow.setColorAt(0.5, QColor(0, 0, 0, 20));
        leftBottomShadow.setColorAt(1, Qt::transparent);

        QPainter painter(&shadow);
        painter.fillRect(0, margin, margin, clHeight, leftShadow);
        painter.fillRect(0, 0, margin, margin, leftTopShadow);
        painter.fillRect(margin, 0, clWidth, margin, topShadow);
        painter.fillRect(rc.right - margin, 0, margin, margin, rightTopShadow);
        painter.fillRect(rc.right - margin, margin, margin, clHeight, rightShadow);
        painter.fillRect(rc.right - margin, rc.bottom - margin, margin, margin, rightBottomShadow);
        painter.fillRect(margin, rc.bottom - margin, clWidth, margin, bottomShadow);
        painter.fillRect(0, rc.bottom - margin, margin, margin, leftBottomShadow);
        painter.end();

        BITMAPINFO bmi;
        bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
        bmi.bmiHeader.biWidth = rc.right;
        bmi.bmiHeader.biHeight = -rc.bottom;  // Отрицательная высота для top-down изображения
        bmi.bmiHeader.biPlanes = 1;
        bmi.bmiHeader.biBitCount = 32;     // 32 бита на пиксель (RGBA)
        bmi.bmiHeader.biCompression = BI_RGB;

        void* pixelData;
        HBITMAP hBitmap = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS, &pixelData, NULL, 0);
        for (int x = 0; x < shadow.width(); ++x) {
            for (int y = 0; y < shadow.height(); ++y) {
                QRgb color = shadow.pixel(x, y);
                float a = qAlpha(color);
                float r = qRed(color) * a / 255.f;
                float g = qGreen(color) * a / 255.f;
                float b = qBlue(color) * a / 255.f;
                //unsigned long color = qRgba(255.f * alpha / 255.f, 0, 0, alpha);
                ((COLORREF*)pixelData)[y * rc.right + x] = qRgba(r, g, b, a);
            }
        }
        HDC hdcMem = CreateCompatibleDC(hdc);
        SelectObject(hdcMem, hBitmap);
        BitBlt(hdc, 0, 0, rc.right, rc.bottom, hdcMem, 0, 0, SRCCOPY);
        DeleteObject(hBitmap);
        DeleteObject(hdcMem);

        // Освобождаем контекст устройства
        ReleaseDC(hWnd, hdc);
        return 0;
    }
        /*case WM_NCHITTEST:
    {
        // Обеспечиваем стандартное поведение рамки
        POINT pt = { GET_X_LPARAM(lParam), GET_Y_LPARAM(lParam) };
        RECT rc;
        GetWindowRect(hWnd, &rc);

        // Определяем границы для ресайза (8 пикселей)
        const int borderSize = 10;
        const int topBorder = 10; // Верхняя граница тоньше

        // Проверяем углы и границы
        if (pt.y <= rc.top + topBorder)
        {
            if (pt.x <= rc.left + borderSize) return HTTOPLEFT;
            if (pt.x >= rc.right - borderSize) return HTTOPRIGHT;
            return HTTOP;
        }
        else if (pt.y >= rc.bottom - borderSize)
        {
            if (pt.x <= rc.left + borderSize) return HTBOTTOMLEFT;
            if (pt.x >= rc.right - borderSize) return HTBOTTOMRIGHT;
            return HTBOTTOM;
        }
        else if (pt.x <= rc.left + borderSize)
        {
            return HTLEFT;
        }
        else if (pt.x >= rc.right - borderSize)
        {
            return HTRIGHT;
        }

        // Верхние 30px для перемещения (как заголовок)
        if (pt.y <= rc.top + 30) return HTCAPTION;

        break;
    }*/
    default:
        break;
    }
    return WndProc(hWnd, msg, wParam, lParam);
    //return DefWindowProc(hWnd, msg, wParam, lParam);
}

LRESULT CALLBACK WindowCustomizer::CallWndProc(int nCode, WPARAM wParam, LPARAM lParam)
{
    qDebug() << nCode;
    switch (nCode) {
    case WM_NCCALCSIZE:
    {
        // Корректируем клиентскую область
        if (wParam)
        {
            NCCALCSIZE_PARAMS* pParams = (NCCALCSIZE_PARAMS*)lParam;
            pParams->rgrc[0].top += margin;
            pParams->rgrc[0].bottom -= margin;
            pParams->rgrc[0].left += margin;
            pParams->rgrc[0].right -= margin;
            return 0;
        }
        break;
    }
    default:
        break;
    }
    return 0;
    //return CallNextHookEx(NULL, nCode, wParam, lParam);
}

/*// Получаем контекст устройства для неклиентской области
HDC hdc = GetWindowDC(hWnd);

// Получаем размеры неклиентской области
RECT rc;
GetWindowRect(hWnd, &rc);
OffsetRect(&rc, -rc.left, -rc.top);

// Рисуем кастомный заголовок
int _margin = margin + 1;
QImage srcImage(rc.right, rc.bottom, QImage::Format_ARGB32);
srcImage.fill(Qt::transparent);
QPainter srcPainter(&srcImage);
srcPainter.fillRect(_margin, _margin, srcImage.width() - _margin * 2, srcImage.height() - _margin * 2,
                    QColor(0, 0, 0, 180));
srcPainter.end();

//
QImage destImage(srcImage.size(), QImage::Format_ARGB32);
destImage.fill(Qt::transparent);
QPainter Painter(&destImage);
qt_blurImage(&blurPainter, srcImage, _margin, true, false);
blurPainter.end();

BITMAPINFO bmi;
bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
bmi.bmiHeader.biWidth = rc.right;
bmi.bmiHeader.biHeight = rc.bottom;  // Отрицательная высота для top-down изображения
bmi.bmiHeader.biPlanes = 1;
bmi.bmiHeader.biBitCount = 32;     // 32 бита на пиксель (RGBA)
bmi.bmiHeader.biCompression = BI_RGB;

// Создаем DIB-секцию
HDC hdcMem = CreateCompatibleDC(hdc);
void* pixelData;
HBITMAP hBitmap = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS, &pixelData, NULL, 0);
for (int x = 0; x < destImage.width(); ++x) {
    for (int y = 0; y < destImage.height(); ++y) {
        QRgb color = destImage.pixel(x, y);
        float a = qAlpha(color) / 255.f;
        a = (pow(1.f - a, 1) * (a - 1.f) + 1.f) * 255.f;
        float r = qRed(color) * a / 255.0;
        float g = qGreen(color) * a / 255.0;
        float b = qBlue(color) * a / 255.0;
        //unsigned long color = qRgba(255.0 * alpha / 255.0, 0, 0, alpha);
        ((COLORREF*)pixelData)[y * rc.right + x] = qRgba(r, g, b, a);
    }
}
SelectObject(hdcMem, hBitmap);
BitBlt(hdc, 0, 0, rc.right, rc.bottom, hdcMem, 0, 0, SRCCOPY);
DeleteObject(hBitmap);

// Освобождаем контекст устройства
ReleaseDC(hWnd, hdc);
return 0;*/
