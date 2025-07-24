import QtQuick
import QtQuick.Layouts
import "../components"
import "../modes/scratch"

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

        }
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
                onClicked: setPage(scratch)
            }
            ModeButton {
                text: "Скрипт"
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
