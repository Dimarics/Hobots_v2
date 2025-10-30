#include "abstractblock.h"

AbstractBlock::AbstractBlock(QQuickItem *parent) : QQuickItem(parent)
{
    setCursorShape(Qt::OpenHandCursor);
    //setFlag(QQuickItem::ItemHasContents);
    //setFlag(QQuickItem::ItemAcceptsDrops);
}
