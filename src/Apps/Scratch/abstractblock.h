#ifndef ABSTRACTBLOCK_H
#define ABSTRACTBLOCK_H

#include <QQuickItem>
#include <QCursor>
#include <QDrag>
#include <QMimeData>

class AbstractBlock : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Qt::CursorShape cursorShape READ cursorShape WRITE setCursorShape NOTIFY cursorShapeChanged)
public:
    AbstractBlock(QQuickItem *parent = nullptr);
    inline void setCursorShape(Qt::CursorShape shape) { setCursor(QCursor(shape)); emit cursorShapeChanged(); }
    inline Qt::CursorShape cursorShape() const { return cursor().shape(); }

/*protected:
    void mousePressEvent(QMouseEvent *event) override {
        if (event->button() == Qt::LeftButton) {
            QDrag *drag = new QDrag(this);
            drag->setDragCursor(QCursor(Qt::ClosedHandCursor).pixmap(), Qt::MoveAction);
            drag->setPixmap(QPixmap(1, 1));

            QMimeData *mimeData = new QMimeData;
            drag->setMimeData(mimeData);

            Qt::DropAction dropAction = drag->exec(Qt::MoveAction);
        }
    }
    void dragMoveEvent(QDragMoveEvent *event) override {
        qDebug() << "drag move";
    }*/

signals:
    void cursorShapeChanged();
    void dragStart(AbstractBlock*);
    void dragMove(AbstractBlock*);
    void dropped(AbstractBlock*);
    void clicked(AbstractBlock*);
};

#endif // ABSTRACTBLOCK_H
