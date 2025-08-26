import QtQuick
import QtQuick.Layouts
import "../components"
import "../modes/scratch"
import "../modes/scratch/blocks"
import "../modes/script"

Item {
    id: root
    property Item currentPage: setPage(appsMenu)
    //implicitWidth: currentPage.implicitWidth
    //implicitHeight: currentPage.implicitHeight
    width: {
        var implicitWidth = currentPage.implicitWidth
        if (currentPage.anchors) implicitWidth += currentPage.anchors.leftMargin + currentPage.anchors.rightMargin
        return Math.max(implicitWidth, apps.width)
    }
    height: {
        var implicitHeight = currentPage.implicitHeight
        if (currentPage.anchors) implicitHeight += currentPage.anchors.topMargin + currentPage.anchors.bottomMargin
        return Math.max(implicitHeight, apps.height)
    }
    //width: Math.max(currentPage.implicitWidth, apps.width)
    //height: Math.max(currentPage.implicitHeight, apps.height)
    Component {
        id: scratch
        Scratch {
            movement: [
                RotateMotor { list: ['A', 'B', 'C', 'D', 'E', 'F'] }
            ]
            controls: [
                Delay {}
            ]
            sensors: [
                TouchSensor { list: ['A', 'B', 'C', 'D', 'E', 'F'] },
                //ColorSensor { colorSensors: ['A', 'B', 'C', 'D', 'E', 'F'] },
                Sonar { list: ['A', 'B', 'C', 'D', 'E', 'F'] }
            ]
        }
    }
    Component {
        id: script
        Script {}
    }
    Component {
        id: appsMenu
        RowLayout {
            spacing: 1
            anchors.margins: 16
            //Layout.margins: 16
            //Layout.preferredWidth: apps.width; Layout.preferredHeight: apps.height
            ModeButton {
                //id: scratchButton
                text: "Scratch"
                icon.source: "qrc:/images/scratch.svg"
                icon.width: 160; icon.height: 160
                onClicked: setPage(scratch)
            }
            ModeButton {
                //visible: false
                text: "Скрипт"
                icon.source: "qrc:/images/script.svg"
                icon.width: 160; icon.height: 160
                onClicked: setPage(script)
            }
        }
    }
    function setPage(page) {
        if (currentPage) currentPage.destroy()
        currentPage = page.createObject(this, { 'anchors.fill': this })
        if (currentPage.exit) currentPage.exit.connect(() => setPage(appsMenu))
    }
}

/*StackLayout {
    implicitWidth: children[currentIndex].implicitWidth
    implicitHeight: children[currentIndex].implicitHeight
    //width: Math.max(children[currentIndex].implicitWidth, apps.width)
    //height: Math.max(children[currentIndex].implicitHeight, apps.height)
    currentIndex: 0
    RowLayout {
        id: menu
        spacing: 1
        Layout.margins: 16
        Layout.preferredWidth: apps.width; Layout.preferredHeight: apps.height
        ModeButton {
            id: scratch
            text: "Scratch"
        }
        ModeButton {
            text: "Скрипт"
        }
    }
}*/
