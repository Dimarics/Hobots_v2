import QtQuick
import QtQuick.Controls.Basic as T
import QtQuick.Layouts
//import QtQuick.VectorImage
import App
import Hobots
import Components as C

C.CustomWindow {
    id: window
    width: 900
    height: 480
    visibility: Qt.platform.os === "android" ? Window.FullScreen : Window.Maximized
    C.JsonSettings {
        id: settings
        path: App.appDataLocation + "settings.json"
        property alias windowX: window.x
        property alias windowY: window.y
        property alias windowWidth: window.width
        property alias windowHeight: window.height
        property alias windowVisibility: window.visibility
        property string currentDevice
        onLoaded: deviceBox.currentIndex = deviceBox.find(currentDevice)
    }
    C.Flickable {
        id: toolBar
        sliderColor: "white"
        //contentWidth: toolBarLayout.width > parent.width ? toolBarLayout.width : parent.width
        height: 90; width: parent.width
        contentWidth: toolBarLayout.width
        RowLayout {
            id: toolBarLayout
            width: Math.max(toolBar.width, implicitWidth)
            anchors.verticalCenter: parent.verticalCenter
            //width: parent.width
            //leftMargin: 20
            //rightMargin: 20
            spacing: 20
            C.Button {
                id: connectionButton
                borderRadius: height / 2
                Layout.leftMargin: toolBarLayout.spacing
                checkable: true
                icon.width: 37; icon.height: 37
                icon.source: checked ? "qrc:/images/plug_connected.svg" : "qrc:/images/plug_unconnected.svg"
            }
            C.ComboBox {
                id: portBox
                model: App.availablePorts
                Layout.preferredWidth: 140
            }
            C.ComboBox {
                id: protocolBox
                model: App.device ? App.device.availableProtocols : null
                Layout.preferredWidth: 140
                //onCurrentTextChanged: setDevice(currentText)
            }
            C.ComboBox {
                id: deviceBox
                currentIndex: -1
                model: App.availableDevices
                displayText: deviceBox.currentIndex === -1 ? "Выберите модель" : currentText
                Layout.preferredWidth: 170
                onCurrentTextChanged: {
                    setDevice(currentText)
                    settings.currentDevice = currentText
                }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                id: status
                radius: 10
                height: 60
                color: C.Style.darkWidgetColor
                Layout.preferredWidth: 270
                //Layout.minimumWidth: 270; Layout.maximumWidth: 300
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
            Rectangle {
                id: onlineStatus
                property bool active: App.device && App.device.protocol && App.device.protocol.state === HobotInterface.Online
                radius: 8; height: 35
                color: C.Style.darkWidgetColor
                Layout.preferredWidth: 80
                border { width: 2; color: active ? C.Style.highlightTextColor : "red" }
                C.Text {
                    text: parent.active ? "online" : "offline"
                    color: parent.active ? C.Style.highlightTextColor : "red"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 14
                    anchors.fill: parent
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
                onClicked: App.device.goHome()
            }
            C.Button {
                id: stopButton
                Layout.rightMargin: toolBarLayout.spacing
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
                onClicked: App.device.stop()
            }
        }
    }
    Rectangle {
        //id: controlPanelBackground
        color: C.Style.headerBackgroundColor
        width: parent.width; height: 28
        anchors.top: toolBar.bottom
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
        // Анимация
        onClicked: {
            controlPanelAnimation.from = checked ? controlPanel.implicitWidth : 0
            controlPanelAnimation.to = checked ? 0 : controlPanel.implicitWidth
            controlPanelAnimation.start()
        }
        NumberAnimation {
            id: controlPanelAnimation
            target: controlPanel
            property: "width"
            duration: 300
        }
        Behavior on icon.color { ColorAnimation { duration: 100 } }
    }
    Item {
        id: controlPanel
        property Item model: null
        visible: model
        implicitWidth: model ? model.implicitWidth : 0
        width: !visible || hideControlPanel.checked ? 0 : implicitWidth
        anchors { top: toolBar.bottom; right: parent.right; bottom: parent.bottom }
        C.Text {
            text: "Панель управления"
            width: parent.width - 28; height: 28
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle { width: 2; height: parent.height; color: C.Style.darkBorderColor }
        C.Flickable {
            id: controlPanelFlickable
            anchors { fill: parent; topMargin: 28; leftMargin: 2}
            contentWidth: width
            contentHeight: Math.max(height, controlPanel.model ? controlPanel.model.implicitHeight : 0)
        }
        //Behavior on width { NumberAnimation { duration: 300 } }
        function setModel(url) {
            if (model) model.destroy()
            if (url) model = Qt.createComponent(url).createObject(controlPanelFlickable.contentItem)
        }
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
        Behavior on anchors.rightMargin { NumberAnimation { duration: 300 } }
    }
    C.Flickable {
        id: apps
        property Item model: null
        clip: true
        contentWidth: model ? model.width : 0; contentHeight: model ? model.height : 0
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        anchors { top: appsHeader.bottom; left: parent.left; right: controlPanel.left; bottom: parent.bottom }
        function setModel(url) {
            if (model) model.destroy()
            if (url) model = Qt.createComponent(url).createObject(apps.contentItem)
        }
    }
    Connections {
        target: connectionButton
        function onToggled() {
            if (connectionButton.checked) {
                if (App.device && App.device.protocol) {
                    if ('portName' in App.device.protocol)
                        App.device.protocol.portName = portBox.currentText
                    App.device.protocol.connectDevice()
                }
            } else {
                connectionButton.checked = false
                if (App.device) App.device.protocol.disconnectDevice()
            }
        }
    }
    Connections {
        target: App.device ? App.device.protocol : null
        function onStateChanged(state) {
            if (state === HobotInterface.Unconnected) connectionButton.checked = false
        }
    }
    Connections {
        target: App.device ? App.device.protocol : null
        function onErrorOccurred(error) {
            if (error === HobotInterface.ConnectionError)
                connectionButton.checked = false
        }
    }
    function setDevice(deviceName) {
        var lib, appsUrl, controlPanelUrl, deviceUrl
        switch(deviceName) {
        case "Хобот 1 М1":
            lib = "Hobot_1_M1"
            appsUrl = "qrc:/H1T1_Apps.qml"
            deviceUrl = "qrc:/H1T1_Device.qml"
            controlPanelUrl = "qrc:/H1T1_ControlPanel.qml"
            break
        case "Хобот 2":
            lib = "Hobot_2"
            appsUrl = "qrc:/H2_Apps.qml"
            deviceUrl = "qrc:/H2_Device.qml"
            controlPanelUrl = "qrc:/H2_ControlPanel.qml"
            break
        case "Хобот Д":
            appsUrl = "Hobot_D/HD_Apps.qml"
            deviceUrl = "Hobot_D/HD_Device.qml"
            controlPanelUrl = "Hobot_D/HD_ControlPanel.qml"
            break
        case "Хобот L2":
            deviceName = "Хобот L3"
            //appsUrl = "Hobot_L_type_2/HLT2_apps.qml"
            //deviceUrl = "Hobot_L_type_2/HLT2_device.qml"
            //break
        case "Хобот L3":
            appsUrl = "Hobot_L_type_3/HLT3_apps.qml"
            deviceUrl = "Hobot_L_type_3/HLT3_device.qml"
            break
        default:
            App.device = null
            apps.setModel(null)
            controlPanel.setModel(null)
            return
        }
        if (App.loadModel(lib)) { console.log("load") }
        apps.setModel(appsUrl)
        controlPanel.setModel(controlPanelUrl)
        App.deviceName = deviceName
        App.device = Qt.createComponent(deviceUrl).createObject(App)
        App.device.protocolName = Qt.binding(()=>protocolBox.currentText)
    }
}
