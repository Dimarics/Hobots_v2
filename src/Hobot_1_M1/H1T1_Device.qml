import QtQuick
import Hobots
import Components

HobotDevice {
    id: root
    joints: [
        Joint { min: -180.99; max: 180 },
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
    protocol: HobotProtocolInterface{}
    onProtocolNameChanged: {
        switch(protocolName) {
        case "COM порт":
            protocol.protocol = HobotProtocolInterface.ComPort
            break
        case "Точка доступа":
            protocol.protocol = HobotProtocolInterface.SoftAP
            break
        case "Локальная сеть":
            protocol.protocol = HobotProtocolInterface.LAN
            break
        default: return
        }
    }
}
