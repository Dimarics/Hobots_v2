import QtQuick
import QtQuick.Layouts
import App
import Hobots
import Components

Item {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: 350
    //width: parent.width
    component CPText: Text {
        horizontalAlignment: Qt.AlignRight
        Layout.preferredWidth: 80; Layout.alignment: Qt.AlignVCenter
    }
    ColumnLayout {
        id: layout
        spacing: 16
        anchors.fill: parent; anchors.margins: 16
        RowLayout {
            id: joints
            //width: parent.width
            //Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            spacing: 40
            Joystick {
                leftText: "🡰"; rightText: "🡲"; topText: "🡱"; bottomText: "🡳"
                onLeftPressed: App.device.setJoint(4, App.device.joints[3].min)
                onRightPressed: App.device.setJoint(4, App.device.joints[3].max)
                onTopPressed: App.device.setJoint(3, App.device.joints[2].max)
                onBottomPressed: App.device.setJoint(3, App.device.joints[2].min)
                onLeftReleased: App.device.stay()
                onRightReleased: App.device.stay()
                onTopReleased: App.device.stay()
                onBottomReleased: App.device.stay()
            }
            Joystick {
                leftText: "J2-"; rightText: "J2+"; topText: "J1+"; bottomText: "J1-"
                onLeftPressed: App.device.setJoint(2, App.device.joints[1].min)
                onRightPressed: App.device.setJoint(2, App.device.joints[1].max)
                onTopPressed: App.device.setJoint(1, App.device.joints[0].max)
                onBottomPressed: App.device.setJoint(1, App.device.joints[0].min)
                onLeftReleased: App.device.stay()
                onRightReleased: App.device.stay()
                onTopReleased: App.device.stay()
                onBottomReleased: App.device.stay()
            }
        }
        Text { text: "Захват:"; Layout.topMargin: 20 }
        Volume {
            min: 0; max: 60; value: 0
            decimals: 0
            spacing: parent.spacing
            Layout.fillWidth: true
        }
        Text { text: "Скорость:"; Layout.topMargin: 20 }
        Volume {
            min: 1; max: 100; value: 50
            decimals: 0
            spacing: parent.spacing
            Layout.fillWidth: true
        }
    }
    Connections {
        target: App.device.protocol
        ignoreUnknownSignals: true
        function onJointChanged(id, value) {
            jointFields.itemAt(id - 1).setValue(value)
        }
        function onStateChanged(state) {
            if (state === HobotInterface.Unconnected) {
                for (let i = 0; i < jointFields.count; ++i) {
                    jointFields.itemAt(i).clear()
                }
            }
        }
    }
}
