import QtQuick

QtObject {
    id: root
    property string protocolName
    property QtObject protocol: null
    property list<string> availableProtocols: ["COM порт"]
    //property list<int> portStates
    property real speed
    property var data: []
    onProtocolNameChanged: {
        var qml
        switch(protocolName) {
        case "COM порт": qml = "import Hobots; HLT3_ModbusInterface{}"; break
        default: return
        }
        if (protocol) protocol.destroy()
        protocol = Qt.createQmlObject(qml, this)
        protocol.dataChanged.connect((data)=>{root.data = data})
        //protocol.dataChanged.connect((data)=>console.log(data[7]))
    }
    //onDataChanged: console.log(data[7])
    /*Connections {
        target: protocol ? protocol : null
        function onDataChanged(data) {
            console.log(data)
        }
    }*/
}
