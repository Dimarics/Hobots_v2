import QtQuick
import QtQuick.Layouts
import App
import Components

Item {
    id: root
    implicitHeight: layout.implicitHeight
    implicitWidth: 450
    component CPText: Text { Layout.alignment: Qt.AlignVCenter | Qt.AlignRight }
    ColumnLayout {
        id: layout
        spacing: 36
        anchors.fill: parent
        anchors.margins: 12
        GridLayout {
            id: coordinates
            rows: 4
            flow: GridLayout.TopToBottom
            rowSpacing: 16; columnSpacing: 20
            //Layout.preferredWidth: root.width
            Layout.alignment: Qt.AlignCenter
            CPText { text: "X, мм" }
            CPText { text: "Y, мм" }
            CPText { text: "Z, мм" }
            CPText { text: "R, °" }
            NumberField { id: coord_x }
            NumberField { id: coord_y }
            NumberField { id: coord_z }
            NumberField { id: joint_r }
            Joystick {
                leftText: "X-"; rightText: "X+"; topText: "Y+"; bottomText: "Y-"
                Layout.rowSpan: 4
            }
            Joystick {
                leftText: "R-"; rightText: "R+"; topText: "Z+"; bottomText: "Z-"
                Layout.rowSpan: 4
            }
        }
        //Item { Layout.fillHeight: true }
    }
    Connections {
        target: App.device.protocol
        ignoreUnknownSignals: true
        function onXChanged(value) { coord_x.setValue(value) }
        function onYChanged(value) { coord_y.setValue(value) }
        function onZChanged(value) { coord_z.setValue(value) }
        function onJointChanged(id, value) {
            switch(id) {
            case 1: joint_r.setText(value); break;
            }
        }
    }
}
