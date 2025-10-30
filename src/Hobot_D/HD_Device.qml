import QtQuick
import Hobots
import Components

HobotDevice {
    id: root
    //property list<int> portStates
    property real x
    property real y
    property real z
    property real joint_1
    property real joint_2
    property real joint_3
    property real joint_4
    property real speed
    property real accel
    property real grub
    property bool pomp
    property real extruderTemp
    property real conveyorBelt
    availableFeatures: [
        HobotDevice.Coordinates,
        HobotDevice.Joints,
        HobotDevice.Speed, HobotDevice.Accel,
        HobotDevice.Grub, HobotDevice.Pomp, HobotDevice.Extruder,
        HobotDevice.ConveyorBelt
    ]
    availableProtocols: ["COM порт"]
    onProtocolNameChanged: {
        var qml
        switch(protocolName) {
        case "COM порт": qml = "import Hobots; HD_SerialPortInterface{}"; break
        default: return
        }
        if (protocol) protocol.destroy()
        protocol = Qt.createQmlObject(qml, this)
        //protocol.dataChanged.connect((data)=>{root.data = data})

        //var c = Qt.createComponent("HD_SerialPortInterface", Component.PreferSynchronous, this)
        //console.log(c.errorString())
    }
    property Connections connections: Connections {
        target: protocol
        function onXChanged(value: real) { x = value }
        function onYChanged(value: real) { y = value }
        function onZChanged(value: real) { z = value }
        function onJointChanged(id: int, value: real) {

        }
    }
    function setSpeed(value: real) { speed = value; protocol.setSpeed(value) }
    function setAccel(value: real) { accel = value; protocol.setAccel(value) }
    function setGrubEnabled(value: bool) { grub = value; protocol.setGrubEnabled(value) }
    function setPompEnabled(value: bool) { pomp = value; protocol.setPompEnabled(value) }
    function setExtruderTemp(value: real) { pomp = value; protocol.setExtruderTemp(value) }
}
