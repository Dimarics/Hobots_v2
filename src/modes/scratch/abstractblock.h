#ifndef ABSTRACTBLOCK_H
#define ABSTRACTBLOCK_H

#include <QQuickItem>
#include <QCursor>

class AbstractBlock : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Qt::CursorShape cursorShape READ cursorShape WRITE setCursorShape NOTIFY cursorShapeChanged)
public:
    AbstractBlock(QQuickItem *parent = nullptr);
    inline void setCursorShape(Qt::CursorShape shape) { setCursor(QCursor(shape)); emit cursorShapeChanged(); }
    inline Qt::CursorShape cursorShape() const { return cursor().shape(); }

protected:


signals:
    void cursorShapeChanged();
    void dragStart(AbstractBlock*);
    void dragMove(AbstractBlock*);
    void dropped(AbstractBlock*);
    void clicked(AbstractBlock*);
};

#endif // ABSTRACTBLOCK_H
