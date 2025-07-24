import QtQuick
import QtQuick.Controls.Basic as T
import QtQuick.Layouts
import QtQuick.Shapes
import "components" as C
import "Hobot_L_type_3"

CustomWindow {
    id: window
    C.Flickable {
        id: toolBar
        //contentWidth: toolBarLayout.width > parent.width ? toolBarLayout.width : parent.width
        height: 90; width: parent.width
        contentWidth: toolBarLayout.width
        //ScrollBar.horizontal: ScrollBar { }
        RowLayout {
            id: toolBarLayout
            width: Math.max(toolBar.width, implicitWidth)
            anchors.verticalCenter: parent.verticalCenter
            //width: parent.width
            //leftMargin: 20
            //rightMargin: 20
            spacing: 25
            C.Button {
                id: connectionButton
                borderRadius: height / 2
                Layout.leftMargin: 20
                checkable: true
                icon.width: 37
                icon.height: 37
                icon.source: checked ? "qrc:/images/plug_connected.svg" : "qrc:/images/plug_unconnected.svg"
            }
            C.ComboBox {
                id: port
                Layout.preferredWidth: 150
            }
            C.ComboBox {
                id: modelBox
                Layout.preferredWidth: 170
                onCurrentTextChanged: {
                    switch (currentText) {

                    }
                }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                id: online
                radius: 8
                height: 35
                color: C.Style.darkWidgetColor
                Layout.preferredWidth: 80
                border { width: 2; color: online.active ? C.Style.highlightTextColor : "red" }
                C.Text {
                    text: online.active ? "online" : "offline"
                    color: online.active ? C.Style.highlightTextColor : "red"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 14
                    anchors.fill: parent
                }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                id: status
                radius: 10
                height: 60
                color: C.Style.darkWidgetColor
                Layout.minimumWidth: 300; Layout.maximumWidth: 300
                border { width: 2; color: "#20FFFFFF" }
                Image {
                    id: logo
                    source: "qrc:/images/hobots_logo.svg"
                    sourceSize: Qt.size(width, height)
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    anchors.fill: parent
                    anchors.margins: 10
                }
            }
            Item { Layout.fillWidth: true }
            C.Button {
                id: diagramButton
                icon.source: "qrc:/images/diagram.svg"
            }
            C.Button {
                id: settingsButton
                icon.source: "qrc:/images/settings.svg"
            }
            C.Button {
                id: homeButton
                icon.source: "qrc:/images/home.svg"
            }
            C.Button {
                id: stopButton
                Layout.rightMargin: 20
                backgroundColor: pressed ? "#FF320A" : hovered ? "#E6320A" : "#C8320A"
                borderWidth: 3
                borderRadius: height / 2
                //borderColor: "#96320A"
                borderColor: hovered ? "white" : "#96320A"
                contentItem: C.Text {
                    text: "СТОП"
                    color: stopButton.hovered ? "white" : "#FFFF80"
                    //color: "white"
                    elide: Text.ElideNone
                    font.pointSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    Rectangle {
        //id: controlPanelBackground
        color: C.Style.headerBackgroundColor
        width: parent.width; height: 28
        anchors.top: toolBar.bottom
    }
    /*C.BorderRect {
        id: controlPanel
        property Item model: Item { anchors.fill: parent; anchors.topMargin: 28; parent: controlPanel }
        width: hideControlPanel.checked ? 0 : 450
        Behavior on width { NumberAnimation { duration: 300 } }
        borderLeft: 2
        anchors { top: toolBar.bottom; right: parent.right; bottom: parent.bottom }
        C.Text {
            text: "Панель управления"
            width: parent.width - 28; height: 28
            horizontalAlignment: Text.AlignHCenter
        }
        function setModel(newModel) {
            if (model) model.destroy()
            model = newModel.createObject(root, { 'anchors.fill': controlPanelFrame, 'anchors.topMargin': 28 })
        }
    }*/
    Item {
        id: controlPanel
        property Item model//: Item { anchors.fill: parent; anchors.topMargin: 28; parent: controlPanel }
        visible: model
        width: !visible || hideControlPanel.checked ? 0 : 450
        anchors { top: toolBar.bottom; right: parent.right; bottom: parent.bottom }
        C.Text {
            text: "Панель управления"
            width: parent.width - 28; height: 28
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle { width: 2; height: parent.height; color: C.Style.borderColor }
        Behavior on width { NumberAnimation { duration: 300 } }
        function setModel(newModel) {
            if (model) model.destroy()
            model = newModel.createObject(root, { 'anchors.fill': controlPanelFrame, 'anchors.topMargin': 28 })
        }
    }
    T.Button {
        id: hideControlPanel
        visible: controlPanel.model
        width: 28; height: 28
        anchors.top: toolBar.bottom; anchors.right: parent.right
        checkable: true
        icon.source: checked ? "qrc:/images/left-arrow.svg" : "qrc:/images/right-arrow.svg"
        icon.width: 7; icon.height: 12
        icon.color: hovered ? "#00FFFF" : "white"
        background: Rectangle {
            color: hideControlPanel.pressed ? "#32ffffff" : hideControlPanel.hovered ? "#1effffff" : "transparent"
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        Behavior on icon.color { ColorAnimation { duration: 100 } }
    }
    C.Text {
        id: appsHeader
        text: "Приложения"
        horizontalAlignment: Text.AlignHCenter
        height: 28
        anchors {
            top: toolBar.bottom; left: parent.left; right: controlPanel.left
            rightMargin: hideControlPanel.checked ? hideControlPanel.width : 0
        }
    }
    C.Flickable {
        id: apps
        property Item model: HLT3_apps { parent: apps.contentItem }
        clip: true
        contentWidth: model.width; contentHeight: model.height
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        anchors { top: appsHeader.bottom; left: parent.left; right: controlPanel.left; bottom: parent.bottom }
        function setModel(model) {
            if (model) model.destroy()
            model = newModel.createObject(apps.contentItem)
        }
        /*Component.onCompleted: {
            model.parent = apps.contentItem
            model.width = Qt.binding(() => Math.max(model.implicitWidth, width))
            model.height = Qt.binding(() => Math.max(model.implicitHeight, height))
        }
        onModelAppsChanged: {
            model.parent = apps.contentItem
            model.width = Qt.binding(() => Math.max(model.implicitWidth, width))
            model.height = Qt.binding(() => Math.max(model.implicitHeight, height))
        }*/
    }
}
