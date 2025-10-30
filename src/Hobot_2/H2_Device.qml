import QtQuick
import Hobots
import Components

HobotDevice {
    id: root
    joints: [
        Joint { min: -180; max: 180 },
        Joint { min:    0; max: 180 },
        Joint { min:    0; max: 360 },
        Joint { min:    0; max: 360 },
        Joint { min: -180; max: 180 },
        Joint { min: -360; max: 180 }
    ]
    availableFeatures: [
        HobotDevice.Joints,
        HobotDevice.Speed,// HobotDevice.Accel,
        HobotDevice.Grub
    ]
    availableProtocols: ["COM порт", "Точка доступа", "Локальная сеть"]
    onProtocolNameChanged: {
        var qml
        switch(protocolName) {
        case "HTTP": qml = "import Hobots; HttpInterface{}"; break
        default: return
        }
        if (protocol) protocol.destroy()
        protocol = Qt.createQmlObject(qml, this)
    }
}
