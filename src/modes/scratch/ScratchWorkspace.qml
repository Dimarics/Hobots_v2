import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import App
import "../../components"
//import Qt5Compat.GraphicalEffects

Item {
    id: workspace
    property alias canvasScale: canvas.scale
    property alias movement: blocksPanel.movement
    property alias controls: blocksPanel.controls
    property alias sensors: blocksPanel.sensors
    property ListModel variables: ListModel { dynamicRoles: true }
    clip: true
    DropArea {
        id: dragHandler
        property Socket socket
        property StackBlock stackBlock
        property StackBlock placeItem
        //property list<AbstractBlock> blocks
        anchors.fill: parent
        //onEntered: (drag) => blockDragStart(drag.source)
        onPositionChanged: (drag) => blockDragMove(drag.source)
        onExited: {
            if (placeItem) placeItem.remove()
            if (socket) socket = null
        }
        onDropped: (drop) => blockDropped(drag.source)
        /*function adjustZ() {
            let level = 0
            let step = 1 / (blocks.length + 1)
            let layersList = []
            function organizeLayer(block) {
                level += step
                block.z = level
                for (let socket of block.sockets) if (socket.next) organizeLayer(socket.next)
            }
            for (let block of blocks)
                if (!block.previous)
                    layersList.push(block)
            layersList.sort((a, b) => a.z - b.z);
            for (let layer of layersList)
                organizeLayer(layer)
        }*/
        function createNewBlock(block) {
            let newBlock = block.dragClone(overlay)
            newBlock.dragStart.connect(blockDragStart)
            newBlock.clicked.connect(toFrontPlane)
            blockDragStart(newBlock)
        }
        function blockDragStart(block) {
            block.parent = overlay
        }
        function blockDragMove(block) {
            let newSocket = bestMatch(block)
            if (newSocket) {
                if (newSocket !== socket) {
                    if (socket) socket.setGlow(false)
                    socket = newSocket
                    toFrontPlane(socket.block)
                    if (socket.type === "stack") {
                        removePlaceItem()
                        placeItem = block.clone(canvas)
                        placeItem.z = -2
                        placeItem.state = "spot"
                        placeItem.connectTo(socket)
                    } else if (socket.type === "value" || socket.type === "bool") {
                        socket.setGlow(true)
                    }
                }
            } else {
                //--------------------------------------------
                if (socket) {
                    socket.setGlow(false)
                    socket = null
                }
                if (block.type === "stack") {
                    let newStackBlock
                    let bottomBlock = block.lastInStack()
                    let distance = Infinity
                    for (let plugBlock of canvas.children) {
                        if (plugBlock.type !== "stack") continue
                        if (plugBlock === placeItem) plugBlock = placeItem.next
                        let dis = bottomBlock.bottomSocket.distance(plugBlock)
                        if (dis < 48 && dis < distance) {
                            distance = dis
                            newStackBlock = plugBlock
                        }
                    }
                    /*let block_1 = block.lastInStack()
                    function check(block) {
                        for (let socket of block.sockets) {
                            if (socket.type !== "stack") continue
                            if (socket.next) {
                                check(socket.next)
                            }
                            if (block_2.previous && block_2.previous.block !== placeItem) continue
                            if (block === placeItem) continue;
                            let dis = socket.distance(plugBlock)
                            if (dis < 48 && dis < distance) {
                                distance = dis
                                newSocket = socket
                            }
                        }
                    }
                    for (let block of canvas.children) check(block)*/
                    /*for (let block_2 of blocks) {
                        if (block_2.previous && block_2.previous.block !== placeItem) continue
                        let dis = block_1.bottomSocket.distance(block_2)
                        if (dis < 48 && dis < distance) {
                            distance = dis
                            newStackBlock = block_2
                        }
                    }*/
                    if (newStackBlock) {
                        if (newStackBlock === stackBlock ||
                                (newStackBlock.previous && newStackBlock.previous.block === placeItem))
                            return
                        removePlaceItem()
                        stackBlock = newStackBlock
                        toFrontPlane(newStackBlock)
                        placeItem = block.clone(canvas)
                        placeItem.state = "spot"
                        placeItem.x = newStackBlock.x
                        placeItem.y = newStackBlock.y - placeItem.bottomSocket.bindY
                        //placeItem.z = newStackBlock.z
                        newStackBlock.connectTo(placeItem.bottomSocket)
                        return
                    }
                }
                //--------------------------------------------
                removePlaceItem()
                stackBlock = null
            }
        }
        function blockDropped(block) {
            //addBlockToList(block)
            block.parent = canvas
            if (placeItem) {
                socket = null
                stackBlock = null
                placeItem.replace(block)
            } else if (socket) {
                if (socket.type === "value" || socket.type === "bool") {
                    block.connectTo(socket)
                }
            }
            //block.setShadowEnabled(false)
            //adjustZ()
            adjustWidth(); adjustHeight()
        }
        function bestMatch(plugBlock) {
            let distance = Infinity
            let newSocket = undefined
            function check(block) {
                for (let socket of block.sockets) {
                    if (socket.next) {
                        check(socket.next)
                    }
                    if ((plugBlock.type === "stack" && socket.type === "stack") ||
                            (plugBlock.type === "value" && socket.type === "value" && !socket.next) ||
                            (plugBlock.type === "bool" && socket.type === "bool" && !socket.next)) {
                        if (block === placeItem) continue;
                        let dis = socket.distance(plugBlock)
                        if (dis < 48 && dis < distance) {
                            distance = dis
                            newSocket = socket
                        }
                    }
                }
            }
            for (let block of canvas.children) check(block)
            return newSocket
        }
        function toFrontPlane(block) {
            block = block.rootBlock()
            var temp = block.parent
            block.parent = parent.parent//window.contentItem //null
            block.parent = temp
        }
        function removePlaceItem() {
            if (placeItem) {
                if (stackBlock) {
                    stackBlock.disconnect()
                    stackBlock.parent = canvas
                    stackBlock = null
                }
                placeItem.remove()
            }
        }
    }
    Flickable {
        id: flickable
        contentWidth: canvas.width * canvas.scale; contentHeight: canvas.height * canvas.scale
        anchors.fill: parent
        maximumFlickVelocity: 0
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScratchScrollBar {
            bottomPadding: width
        }
        ScrollBar.horizontal: ScratchScrollBar {
            leftPadding: blocksPanel.width + 2
            rightPadding: height
        }
        Image {
            id: background_image
            property real side: 24 * canvas.scale
            property real offsetX: 0
            property real offsetY: 0
            width: flickable.width + side * 2; height: flickable.height + side * 2
            //x: -flickable.contentX % 24; y: -flickable.contentY % 24
            x: flickable.contentX - (flickable.contentX - offsetX) % side - side
            y: flickable.contentY - (flickable.contentY - offsetY) % side - side
            source: "qrc:/images/scratch_background.svg"
            smooth: false
            //mipmap: true
            fillMode: Image.Tile
            horizontalAlignment: Image.AlignLeft
            verticalAlignment: Image.AlignTop
            transformOrigin: Item.TopLeft
            sourceSize: Qt.size(side, side)
            //anchors.fill: parent
        }
        Item {
            id: canvas
            //width: 2000; height: 2000
            transformOrigin: Item.TopLeft
        }
        onWidthChanged: adjustWidth()
        onHeightChanged: adjustHeight()
    }
    BlocksPanel {
        id: blocksPanel
        width: 375; height: flickable.height
        /*Component.onCompleted: {
            for (let child of content)
                if (child instanceof AbstractBlock)
                    child.dragStart.connect(dragHandler.createNewBlock)
        }*/
    }
    MultiEffect {
        source: overlay
        scale: canvas.scale
        anchors.fill: overlay
        transformOrigin: Item.TopLeft
        blurEnabled: true
        blur: 1.0
        brightness: -1
    }
    Item {
        id: overlay
        x: -flickable.contentX; y: -flickable.contentY
        width: canvas.width; height: canvas.height
        transformOrigin: Item.TopLeft
        scale: canvas.scale
    }
    component ZoomButton: Button {
        id: zoomButton
        width: 40; height: 40
        icon.width: 16; icon.height: 16
        icon.color: "white"
        containmentMask: background
        background: Shape {
            containsMode: Shape.FillContains
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: -1
                fillColor: zoomButton.pressed ? "#0F83D6" : zoomButton.hovered ? "#46BDFC" : "#1EAAFF"
                Behavior on fillColor { ColorAnimation { duration: 150 } }
                PathAngleArc {
                    centerX: width / 2; centerY: height / 2
                    radiusX: width / 2; radiusY: height / 2
                    startAngle: 0; sweepAngle: 360
                }
            }
        }
    }
    ZoomButton {
        id: zoomReset
        icon.source: "qrc:/images/zoom_reset.svg"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        onClicked: { canvas.scale = 1 }
    }
    ZoomButton {
        id: zoomOut
        icon.source: "qrc:/images/zoom_out.svg"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: zoomReset.top
        anchors.bottomMargin: 10
        onClicked: {
            canvas.scale *= 0.8
            flickable.returnToBounds()
        }
    }
    ZoomButton {
        id: zoomIn
        icon.source: "qrc:/images/zoom_in.svg"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: zoomOut.top
        anchors.bottomMargin: 10
        onClicked: { canvas.scale *= 1.25 }
    }
    function adjustWidth() {
        let w = flickable.width * 1.5
        if (canvas.children.length) {
            let min_x = Infinity
            let max_x = 0
            for (let child of canvas.children) {
                min_x = Math.min(min_x, child.x)
                max_x = Math.max(max_x, child.x + child.width)
            }
            let children_width = min_x !== Infinity && max_x !== 0 ? max_x - min_x : 0
            let dx = (children_width < flickable.width / 2 ? flickable.width - children_width : flickable.width / 2) - min_x
            for (let child of canvas.children) child.x += dx
            w = children_width < flickable.width / 2 ? flickable.width * 2 - children_width : flickable.width + children_width
            background_image.offsetX += dx * canvas.scale
            //flickable.contentX += dx * canvas.scale
            flickable.flick(dx * canvas.scale, 0)
        }
        canvas.width = w
    }
    function adjustHeight() {
        let h = flickable.height * 1.5
        if (canvas.children.length) {
            let min_y = Infinity
            let max_y = 0
            for (let child of canvas.children) {
                min_y = Math.min(min_y, child.y)
                max_y = Math.max(max_y, child.y + child.height)
            }
            let children_height = min_y !== Infinity && max_y !== 0 ? max_y - min_y + 8 : 0
            let dy = (children_height < flickable.height / 2 ? flickable.height - children_height : flickable.height / 2) - min_y
            for (let child of canvas.children) child.y += dy
            h = children_height < flickable.height / 2 ? flickable.height * 2 - children_height : flickable.height + children_height
            background_image.offsetY += dy * canvas.scale
            //flickable.contentY += dy * canvas.scale
            flickable.flick(0, dy * canvas.scale)
        }
        canvas.height = h
    }
    function topLevelBlocks() {
        let blocks = []
        for (let child of canvas.children) {
            if (child instanceof StackBlock) {
                blocks.push(child)
            }
        }
        blocks.sort((a, b) => b.y - a.y)
        return blocks
    }
    function clear() {
        for (let child of canvas.children) child.destroy()
        blocksPanel.clear()
        variables.clear()
        adjustWidth(); adjustHeight()
    }
    function save(filePath) {
        var json = {
            "app": "Scratch",
            "device": App.device.objectName,
            "contentX": flickable.contentX,
            "contentY": flickable.contentY,
            "stacks": []
        }
        function getBlockJSON(block) {
            let blockJSON = { "name": block.objectName }
            if (block.getData && block.getData()) blockJSON.data = block.getData()
            blockJSON.plugs = []
            for (let i = 0; i < block.sockets.length; ++i) {
                if (block.sockets[i].next) {
                    let plug = getBlockJSON(block.sockets[i].next)
                    plug.index = i
                    blockJSON.plugs.push(plug)
                }
            }
            return blockJSON
        }
        for (let block of canvas.children) {
            let blockJSON = getBlockJSON(block)
            blockJSON.x = block.x; blockJSON.y = block.y
            json.stacks.push(blockJSON)
        }
        if (variables.count) {
            json.variables = []
            for (let i = 0; i < variables.count; ++i) {
                let variable = variables.get(i)
                json.variables.push({"name": variable.name, "value": variable.value})
            }
        }
        App.saveFile(JSON.stringify(json, null, 4), scratch.currentFilePath)
    }
    function open(filePath: string): bool {
        clear()
        if (!filePath) return false
        const json = App.readJSON(filePath)
        if (!json) {
            return false
        } else if (json.app !== "Scratch") {
            console.error("Неверный формат"); return false
        } else if (json.device !== App.device.objectName) {
            console.error("Этот файл предназначен для другого устройства"); return false
        }
        flickable.contentX = json.contentX; flickable.contentY = json.contentY
        // заполнение переменными
        if (json.variables) {
            for (let variable of json.variables) {
                blocksPanel.addVariable(variable.name, variable.value)
            }
        }
        // создание блоков
        function createBlock(blockJSON) {
            let block = Qt.createComponent("blocks/" + blockJSON.name + ".qml").createObject(canvas, {"canvas": canvas})
            if (blockJSON.data) block.setData(blockJSON.data)
            block.dragStart.connect(dragHandler.blockDragStart)
            block.clicked.connect(dragHandler.toFrontPlane)
            for (let plug of blockJSON.plugs) {
                createBlock(plug).connectTo(block.sockets[plug.index])
            }
            return block
        }
        for (let blockJSON of json.stacks) {
            let block = createBlock(blockJSON);
            block.x = blockJSON.x; block.y = blockJSON.y
        }
        adjustWidth(); adjustHeight()
        return true
    }
}
