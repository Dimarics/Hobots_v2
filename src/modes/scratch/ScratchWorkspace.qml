import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
//import Qt5Compat.GraphicalEffects

Item {
    id: scratch
    //property alias movement: blocksPanel.movement
    //property alias controls: blocksPanel.controls
    property ListModel variables: ListModel { dynamicRoles: true }
    clip: true
    DropArea {
        id: dragHandler
        property Socket socket
        property StackBlock stackBlock: null
        property AbstractBlock placeItem: null

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
                        placeItem = block.clone(workspace)
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
                    for (let plugBlock of workspace.children) {
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
                    for (let block of workspace.children) check(block)*/
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
                        placeItem = block.clone(workspace)
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
            block.parent = workspace
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
            adjustWidth()
            adjustHeight()
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
            for (let block of workspace.children) check(block)
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
                    stackBlock.parent = workspace
                    stackBlock = null
                }
                placeItem.remove()
            }
        }
    }
    Flickable {
        id: flickable
        contentWidth: workspace.width * workspace.scale; contentHeight: workspace.height * workspace.scale
        anchors.fill: parent
        //maximumFlickVelocity: 0
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        ScrollBar.vertical: ScratchScrollBar {
            bottomPadding: width
        }
        ScrollBar.horizontal: ScratchScrollBar {
            leftPadding: blocksPanel.width
            rightPadding: height
        }
        Image {
            id: background_image
            property real drawScale: workspace.scale
            source: "qrc:/images/scratch_background.svg"
            smooth: false
            //mipmap: true
            fillMode: Image.Tile
            horizontalAlignment: Image.AlignLeft
            verticalAlignment: Image.AlignTop
            transformOrigin: Item.TopLeft
            sourceSize: Qt.size(24 * drawScale, 24 * drawScale)
            //anchors.fill: parent
            width: flickable.contentWidth + 24; height: flickable.contentHeight + 24
        }
        Item {
            id: workspace
            //width: 2000; height: 2000
            transformOrigin: Item.TopLeft
        }
        onWidthChanged: adjustWidth()
        onHeightChanged: adjustHeight()
    }
    BlocksPanel {
        id: blocksPanel
        width: 375; height: flickable.height
        Component.onCompleted: {
            for (let child of content)
                if (child instanceof AbstractBlock)
                    child.dragStart.connect(dragHandler.createNewBlock)
        }
    }
    MultiEffect {
        source: overlay
        scale: workspace.scale
        anchors.fill: overlay
        transformOrigin: Item.TopLeft
        blurEnabled: true
        blur: 1.0
        brightness: -1
    }
    Item {
        id: overlay
        x: -flickable.contentX; y: -flickable.contentY
        width: workspace.width; height: workspace.height
        transformOrigin: Item.TopLeft
        scale: workspace.scale
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
        onClicked: { workspace.scale = 1 }
    }
    ZoomButton {
        id: zoomOut
        icon.source: "qrc:/images/zoom_out.svg"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: zoomReset.top
        anchors.bottomMargin: 10
        onClicked: {
            workspace.scale *= 0.8
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
        onClicked: { workspace.scale *= 1.25 }
    }
    /*function adjustSize() {
        let w = workspace.childrenRect.width < flickable.width / 2 ?
                flickable.width * 2 - workspace.childrenRect.width :
                flickable.width + workspace.childrenRect.width
        let dx = (w - workspace.childrenRect.width) / 2 - workspace.childrenRect.x
        for (let child of workspace.children) child.x += dx
        workspace.width = w
        flickable.contentX += dx
    }*/
    function adjustWidth() {
        let w = flickable.width * 1.5
        if (workspace.children.length) {
            let min_x = Infinity
            let max_x = 0
            for (let child of workspace.children) {
                min_x = Math.min(min_x, child.x)
                max_x = Math.max(max_x, child.x + child.width)
                //if (child.x < min_x) min_x = child.x
                //if (child.x + child.width > max_x) max_x = child.x + child.width
            }
            let children_width = min_x !== Infinity && max_x !== 0 ? max_x - min_x : 0
            let dx = (children_width < flickable.width / 2 ? flickable.width - children_width : flickable.width / 2) - min_x
            for (let child of workspace.children) child.x += dx
            w = children_width < flickable.width / 2 ? flickable.width * 2 - children_width : flickable.width + children_width
            background_image.x = (background_image.x + dx) % 24 - 24
            flickable.contentX += dx * workspace.scale
        }
        workspace.width = w
    }
    function adjustHeight() {
        let h = flickable.height * 1.5
        if (workspace.children.length) {
            let min_y = Infinity
            let max_y = 0
            for (let child of workspace.children) {
                min_y = Math.min(min_y, child.y)
                max_y = Math.max(max_y, child.y + child.height)
                //if (child.y < min_y) min_y = child.y
                //if (child.y + child.height > max_y) max_y = child.y + child.height
            }
            let children_height = min_y !== Infinity && max_y !== 0 ? max_y - min_y + 8 : 0
            let dy = (children_height < flickable.height / 2 ? flickable.height - children_height : flickable.height / 2) - min_y
            for (let child of workspace.children) child.y += dy
            h = children_height < flickable.height / 2 ? flickable.height * 2 - children_height : flickable.height + children_height
            background_image.y = (background_image.y + dy) % 24 - 24
            flickable.contentY += dy * workspace.scale
        }
        workspace.height = h
    }
}
