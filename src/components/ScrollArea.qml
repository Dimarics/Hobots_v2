import QtQuick as Q
import QtQuick.Controls.Basic as C
//import Hobots

Q.Item {
    id: root
    default property alias content: contentItem.data
    property real contentX
    property real contentY
    property alias contentWidth: contentItem.width
    property alias contentHeight: contentItem.height
    property Q.color sliderColor: "gray"
    property ScrollBar verticalScrollBar: verticalScrollBar
    property ScrollBar horizontalScrollBar: horizontalScrollBar
    //clip: true
    /*MouseHandler {
        property bool pressed: false
        property point mousePress
        width: root.width; height: root.height
        onPressed: (point, button) => {
            if (button === Qt.LeftButton) {
                pressed = true
                mousePress.x = point.x - contentX
                mousePress.y = point.y - contentY
            }
        }
        onPositionChanged: point => {
            if (pressed) {
                contentX = point.x - mousePress.x; contentY = point.y - mousePress.y
            }
        }
        onReleased: pressed = false
    }*/
    onWidthChanged: {
        if (contentX > contentWidth - root.width) contentX = contentWidth - root.width
        else if (contentX < 0) contentX = 0
    }
    onHeightChanged: {
        if (contentY > contentHeight - root.height) contentY = contentHeight - root.height
        else if (contentY < 0) contentY = 0
    }
    onContentXChanged: horizontalScrollBar.position = contentX / (contentWidth - width) * (1 - horizontalScrollBar.size)
    onContentYChanged: verticalScrollBar.position = contentY / (contentHeight - height) * (1 - verticalScrollBar.size)
    Q.MouseArea {
        property point mousePress
        width: root.width; height: root.height
        acceptedButtons: Qt.LeftButton
        onPressed: {
            mousePress.x = mouseX + contentX
            mousePress.y = mouseY + contentY
        }
        onPositionChanged: {
            if (pressed) {
                var newX = mousePress.x - mouseX
                var newY = mousePress.y - mouseY
                if (newX > contentWidth - root.width) newX = contentWidth - root.width
                else if (newX < 0) newX = 0
                if (newY > contentHeight - root.height) newY = contentHeight - root.height
                else if (newY < 0) newY = 0
                contentX = newX
                contentY = newY
            }
        }
    }
    Q.Item {
        id: contentItem
        x: -contentX; y: -contentY
        width: root.width; height: root.height
        /*Q.Rectangle {
            z: 1
            anchors.fill: parent
            color: "green"
        }
        Q.Rectangle {
            z: 1
            x: 400; y: 20
            width: 200; height: 100
            color: "red"
        }*/
    }
    ScrollBar {
        id: verticalScrollBar
        color: sliderColor

        x: root.width - width
        height: root.height

        orientation: Qt.Vertical
        bottomPadding: horizontalScrollBar.visible ? horizontalScrollBar.height : 2
        size: root.height / contentHeight
        onPositionChanged: contentY = (contentHeight - root.height) * position / (1 - size)
    }
    ScrollBar {
        id: horizontalScrollBar
        color: sliderColor

        y: root.height - height
        width: root.width

        orientation: Qt.Horizontal
        rightPadding: verticalScrollBar.visible ? verticalScrollBar.width : 2
        size: root.width / contentWidth
        onPositionChanged: contentX = (contentWidth - root.width) * position / (1 - size)
    }
}
