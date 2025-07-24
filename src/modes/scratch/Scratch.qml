 import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import "../../components" as C
//import Qt5Compat.GraphicalEffects

Item {
    signal exit
    Item {
        id: toolBar
        height: exitButton.height + 30
        anchors { top: parent.top; left: parent.left; right: parent.right }
        C.Flickable {
            clip: true
            width: parent.width - exitButton.width - 30; height: parent.height
            contentWidth: layout.implicitWidth + 15//; contentHeight: layout.implicitHeight
            RowLayout {
                id: layout
                spacing: 15
                anchors.fill: parent
                anchors.margins: 15
                C.Button {
                    icon.source: "qrc:/images/create.svg"
                    icon.height: 40; icon.width: 0
                }
                C.Button {
                    icon.source: "qrc:/images/open.svg"
                    icon.height: 0; icon.width: 40
                }
                C.Button {
                    icon.source: "qrc:/images/save.svg"
                }
                C.Button {
                    icon.source: "qrc:/images/save_as.svg"
                }
                //Rectangle { width: 2; height: 50; color: "red" }
                C.Button {
                    icon.source: "qrc:/images/trash.svg"
                    icon.height: 0; icon.width: 36
                }
                C.Button {
                    text: "Старт"
                }
                C.Button {
                    text: "Стоп"
                }
                C.Button {
                    text: "Пример"
                }
            }
        }
        C.Button {
            id: exitButton
            text: "Выход"
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; margins: 15}
            onClicked: exit()
        }
    }
    ScratchWorkspace {
        anchors { top: toolBar.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
    }
}
