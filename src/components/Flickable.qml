import QtQuick as Q

Q.Flickable {
    id: root
    height: 90; width: parent.width
    ScrollBar.horizontal: ScrollBar {
        rightPadding: root.ScrollBar.vertical.visible ? root.ScrollBar.vertical.width : 2
    }
    ScrollBar.vertical: ScrollBar {
        bottomPadding: root.ScrollBar.horizontal.visible ? root.ScrollBar.horizontal.height : 2
    }
}
