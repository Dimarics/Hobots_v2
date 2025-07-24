import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root;
    //Behavior on anchors.leftMargin { NumberAnimation { duration: 150 } }
    property alias cursorShape: mouseArea.cursorShape
    property real plugX: 0
    property real plugY: 0
    property color borderColor
    property color fillColor
    property string type
    property ShapePath shapePath
    property Socket previous
    //property Component prototype
    property list<Socket> sockets
    //property list<Item> content
    //-----Тень-----
    property QtObject shadowObject: null
    /*property Component shadow: MultiEffect {
        z: root.z - 1
        source: fill
        anchors.fill: root
        blurEnabled: true
        blur: 1.0
        brightness: -1
    }*/
    //--------------
    signal dragStart(block: AbstractBlock)
    signal dragMove(block: AbstractBlock)
    signal dropped(block: AbstractBlock)
    signal clicked(block: AbstractBlock)
    containmentMask: fill
    /*anchors.left: previous ? previous.block.left : undefined
    anchors.top: previous ? previous.block.top : undefined
    anchors.leftMargin: previous ? previous.touchX - plugX : undefined
    anchors.topMargin: previous ? previous.touchY - plugY : undefined*/
    Shape {
        id: fill
        //visible: false
        containsMode: Shape.FillContains
        ShapePath {
            strokeWidth: -1
            fillColor: root.fillColor
            startX: shapePath.startX; startY: shapePath.startY
            Component.onCompleted: pathElements = shapePath.pathElements
        }
    }
    Shape {
        id: contour
        //visible: false
        //containsMode: Shape.FillContains
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: shapePath.strokeWidth
            strokeColor: root.borderColor//Qt.darker(shapePath.fillColor, 1.2)
            fillColor: "transparent"
            startX: shapePath.startX; startY: shapePath.startY
            Component.onCompleted: pathElements = shapePath.pathElements
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.OpenHandCursor
        onPressed: mouse => { mouse.accepted = false; dragHandler.enabled = true }
        containmentMask: fill
    }
    DragHandler {
        id: dragHandler
        property bool pressed: false
        enabled: false
        grabPermissions: PointerHandler.TakeOverForbidden
        onGrabChanged: function(transition, point) {
            //console.log(transition)
            switch (transition) {
            case PointerDevice.GrabPassive:
                pressed = true
                mouseArea.cursorShape = Qt.ClosedHandCursor
                break
            case PointerDevice.UngrabPassive:
                if (pressed) {
                    pressed = false
                    target.clicked(target)
                }
                mouseArea.cursorShape = Qt.OpenHandCursor
                break
            case PointerDevice.GrabExclusive:
                pressed = false
                target = root
                disconnect()
                dragStart(target)
                target.Drag.hotSpot = point.pressPosition
                target.Drag.start()
                //target.setShadowEnabled(true)
                break
            case PointerDevice.UngrabExclusive:
                //target.dropped(target)
                target.Drag.drop()
                //target.setShadowEnabled(false)
                target.cursorShape = Qt.OpenHandCursor
                target = root
                enabled = false
                break
            default: enabled = false; break
            }
        }
    }
    Component {
        id: destroyAnimation
        NumberAnimation {
            target: root
            property: "scale"
            to: 0; duration: 250
            running: true
            onFinished: root.destroy()
        }
    }
    //Component.onCompleted: console.log(this.toString().split('_')[0])
    //Component.onCompleted: JSON.parse(JSON.stringify({}))
    /*function cp(obj) {
        if (obj === null || typeof obj !== "object") return obj
        var copy = Array.isArray(obj) ? [] : {}
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                copy[key] = cp(obj[key])
            }
        }
        return copy
    }*/
    onPreviousChanged: {
        if (previous) {
            parent = previous.block
            x = Qt.binding(() => previous.bindX - plugX)
            y = Qt.binding(() => previous.bindY - plugY)
        } else {
            var pos = mapToItem(overlay, 0, 0)
            x = pos.x; y = pos.y
        }
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        //onTriggered: if (root.run !== undefined) root.run()
    }
    function clone(parent: Item): AbstractBlock {
        //var component = prototype ?? Qt.createComponent(objectName + ".qml")
        var newBlock = Qt.createComponent("blocks/" + objectName + ".qml").createObject(parent ?? root.parent)
        copyData(newBlock)
        return newBlock
    }
    /*function copy(parent: Item): AbstractBlock {
        var args = []
        var newBlock = Qt.createComponent("%1Block.qml".arg(objectName)).createObject(parent ?? root.parent)
        newBlock.borderColor = borderColor
        newBlock.fillColor = fillColor
        for (let object of content) {
            if (object instanceof ScratchText) {
                newBlock.content.push(object.copy(newBlock))
            } else if (object instanceof BooleanSocket) {
                let bool_socket = object.copy(newBlock)
                args.push(bool_socket)
                newBlock.content.push(bool_socket)
            } else if (object instanceof ValueInput) {
                let value_socket = object.copy(newBlock)
                args.push(value_socket)
                newBlock.content.push(value_socket)
            }
        }
        if (root instanceof ValueBlock || root instanceof BooleanBlock) {
            newBlock.calculate = calculate
            newBlock.value = Qt.binding(function(){ return newBlock.calculate(args) })
        }
        //if (root.run !== undefined) newBlock.run = root.run
        return newBlock
    }*/
    function copyData(target) {
        //target.prototype = prototype
        for (let i = 0; i < content.length; ++i) {
            if (content[i] instanceof ValueInput) {
                target.content[i].text = content[i].text
            } else if (content[i] instanceof ListItem) {
                target.content[i].model = content[i].model
            }
        }
    }
    function dragClone(parent: Item): AbstractBlock {
        var newBlock = clone(parent)
        dragHandler.target = newBlock
        newBlock.dragStart(newBlock)
        newBlock.cursorShape = Qt.ClosedHandCursor
        return newBlock
    }
    function connectTo(socket: Socket) {
        disconnect()
        if (socket.next) console.log("Так не должно быть!")
        socket.next = this
        previous = socket
    }
    function disconnect() {
        if (previous) {
            previous.next = null
            previous = null
        }
    }
    function destruct() {
        /*function removeBlock(block) {
            //for (let socket of block.sockets) if (socket.next) removeBlock(socket.next)
            destroyAnimation.createObject(block, { target: block })
        }
        removeBlock(this)*/
        destroyAnimation.createObject(root)
        //root.destroy()
    }
    function rootBlock() {
        for (var block = this; block.previous; block = block.previous.block);
        return block
    }
}
