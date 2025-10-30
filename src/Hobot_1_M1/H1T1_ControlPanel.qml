import QtQuick
import QtQuick.Layouts
import App
import Hobots
import Components

Item {
    id: root
    implicitHeight: layout.implicitHeight
    width: parent.width
    component CPText: Text { Layout.alignment: Qt.AlignVCenter | Qt.AlignRight }
    ColumnLayout {
        id: layout
        spacing: 36
        width: parent.width
        height: implicitHeight
        GridLayout {
            id: joints
            rows: 6
            flow: GridLayout.TopToBottom
            rowSpacing: 16; columnSpacing: 16
            //Layout.preferredWidth: root.width
            Layout.topMargin: 16
            Layout.alignment: Qt.AlignCenter
            Repeater {
                model: 6
                CPText { required property int index; text: "Угол %1, °".arg(index + 1) }
            }
            Repeater {
                id: jointFields
                model: 6
                NumberField {
                    required property int index;
                    min: App.device.joints[index].min; max: App.device.joints[index].max
                    onValueModified: App.device.setJoint(index + 1, value)
                }
            }
            Joystick {
                leftText: "J2-"; rightText: "J2+"; topText: "J1+"; bottomText: "J1-"
                Layout.rowSpan: 3
                onLeftPressed: App.device.setJoint(2, App.device.joints[1].min)
                onRightPressed: App.device.setJoint(2, App.device.joints[1].max)
                onTopPressed: App.device.setJoint(1, App.device.joints[0].max)
                onBottomPressed: App.device.setJoint(1, App.device.joints[0].min)
                onLeftReleased: App.device.stay()
                onRightReleased: App.device.stay()
                onTopReleased: App.device.stay()
                onBottomReleased: App.device.stay()
            }
            Joystick {
                leftText: "J6-"; rightText: "J6+"; topText: "J5+"; bottomText: "J5-"
                Layout.rowSpan: 3; Layout.columnSpan: 2; Layout.alignment: Qt.AlignCenter
                onLeftPressed: App.device.setJoint(6, App.device.joints[5].min)
                onRightPressed: App.device.setJoint(6, App.device.joints[5].max)
                onTopPressed: App.device.setJoint(5, App.device.joints[4].max)
                onBottomPressed: App.device.setJoint(5, App.device.joints[4].min)
                onLeftReleased: App.device.stay()
                onRightReleased: App.device.stay()
                onTopReleased: App.device.stay()
                onBottomReleased: App.device.stay()
            }
            Joystick {
                leftText: "J4-"; rightText: "J4+"; topText: "J3+"; bottomText: "J3-"
                Layout.rowSpan: 3
                onLeftPressed: App.device.setJoint(4, App.device.joints[3].min)
                onRightPressed: App.device.setJoint(4, App.device.joints[3].max)
                onTopPressed: App.device.setJoint(3, App.device.joints[2].max)
                onBottomPressed: App.device.setJoint(3, App.device.joints[2].min)
                onLeftReleased: App.device.stay()
                onRightReleased: App.device.stay()
                onTopReleased: App.device.stay()
                onBottomReleased: App.device.stay()
            }
        }
        RowLayout {
            implicitWidth: joints.width
            spacing: 16
            Layout.alignment: Qt.AlignCenter
            CPText { text: "Скорость" }
            Volume {
                min: 1; max: 100; value: 50
                decimals: 0
                spacing: parent.spacing
                Layout.fillWidth: true
            }
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
