import QtQuick
import QtQuick.Controls.Basic as T

T.ScrollBar {
    id: scrollBar
    policy: T.ScrollBar.AsNeeded
    rightPadding: orientation == Qt.Vertical ? 4 : 0
    bottomPadding: orientation == Qt.Horizontal ? 4 : 0
    visible: {
        switch(policy) {
        case T.ScrollBar.AlwaysOff:
            return false
        case T.ScrollBar.AlwaysOn:
            return true
        case T.ScrollBar.AsNeeded:
            return size < 1.0
        }
        return false
    }
    contentItem: Rectangle {
        implicitWidth: 8
        implicitHeight: 8
        radius: 4
        color: "white"
        opacity: scrollBar.pressed ? 0.45 : scrollBar.hovered ? 0.3 : 0.2
        Behavior on opacity { OpacityAnimator { duration: 300 } }
    }
}
