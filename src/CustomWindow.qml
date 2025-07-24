import QtQuick
import QtQuick.Templates
//import WindowCustomizer
import Style
import Hobots
import "qrc:/../QtExtras/qml"

Window {
    id: window
    width: 900; height: 480
    visible: true
    visibility: Window.Maximized
    color: "transparent"
    default property alias children: content.children
    WindowCustomizer { window: window }
    MouseArea {
        // 47 x 28
        id: panel
        height: 29
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        onPressed: window.startSystemMove()
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: "#465adc" }
                GradientStop { position: 1; color: "#002d5a" }
            }
        }
        Button {
            id: quitButton
            width: 45; height: panel.height
            anchors.right: panel.right
            hoverEnabled: true
            contentItem: Text {
                text: "✕" //✕🗙
                color: "white"
                font.pointSize: 12
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                color: quitButton.pressed ? "#dcff6464" : quitButton.hovered ? "#b4ff0000" : "transparent"
            }
            onClicked: Qt.quit()
        }
        Button {
            id: screenModeButton
            width: 45; height: panel.height
            anchors.right: quitButton.left
            //checkable: true
            checked: window.visibility === Window.Windowed
            hoverEnabled: true
            contentItem: Text {
                text: screenModeButton.checked ? "🗖" : "🗗"
                color: "white"
                bottomPadding: 4
                font.pointSize: 12
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                color: screenModeButton.pressed ? "#32ffffff" : screenModeButton.hovered ? "#1effffff" : "transparent"
            }
            onClicked: {
                if (checked) {
                    window.showMaximized()
                    update()
                } else {
                    window.showNormal()
                }
            }
        }
        Button {
            id: minimizedButton
            width: 45; height: panel.height
            anchors.right: screenModeButton.left
            hoverEnabled: true
            onClicked: window.showMinimized()
            //onClicked: window.visibility = Window.Hidden
            contentItem: Text {
                text: "━" //–━🗕—ꟷ
                color: "white"
                font.pointSize: 8
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
            background: Rectangle {
                color: minimizedButton.pressed ? "#32ffffff" : minimizedButton.hovered ? "#1effffff" : "transparent"
            }
        }
    }
    Rectangle {
        id: separator
        height: 2
        anchors { top: panel.bottom; left: parent.left; right: parent.right }
        color: Style.borderColor
    }
    Rectangle {
        id: content
        color: Style.lightWidgetColor
        anchors { top: separator.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
    }
    /*Rectangle {
        color: "#00326E"
        border.width: 2
        border.color: "#142142"
        anchors {
            top: panel.bottom; bottom: parent.bottom; left: parent.left; right: parent.right
            leftMargin: -border.width; rightMargin: -border.width - 1; bottomMargin: -border.width - 1
        }
        Item {
            id: content
            anchors.fill: parent
            anchors.margins: parent.border.width
        }
    }
    BorderRect {
        id: content
        backgroundColor: Style.lightWidgetColor
        borderColor: Style.borderColor
        borderTop: 2
        anchors { top: panel.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
    }*/
}
