import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: root
    visible: false
    //property alias glow: glowLoader.active
    property Item glowObject: null
    property real offsetX: 0
    property real offsetY: 0
    readonly property real bindX: {
        for (var p = parent, newX = 0; parent && p !== block; p = parent.parent, newX += parent.x);
        return x + offsetX + (p === block ? newX : 0)
    }
    readonly property real bindY: {
        for (var p = parent, newY = 0; parent && p !== block; p = parent.parent, newY += parent.y);
        return y + offsetY + (p === block ? newY : 0)
    }
    property string type: "stack"
    property Item block: parent
    property Item next: null
    property list<QtObject> path
    function distance(plugBlock: AbstractBlock): real {
        /*var worldX = block ? block.x + touchX : touchX
        var worldY = block ? block.y + touchY : touchY
        return Math.sqrt(Math.pow(worldX - plugBlock.x - plugBlock.plugX, 2) +
                         Math.pow(worldY - plugBlock.y - plugBlock.plugY, 2))*/
        var socketPos = block.mapToItem(workspace, bindX, bindY)
        var plugPos = plugBlock.mapToItem(workspace, plugBlock.plugX, plugBlock.plugY)
        return Math.sqrt(Math.pow(socketPos.x - plugPos.x, 2) + Math.pow(socketPos.y - plugPos.y, 2))
    }
    Component {
        id: glowComponent
        MultiEffect {
            z: -1
            source: Shape {
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeWidth: 5
                    Component.onCompleted: pathElements = root.path
                }
            }
            width: source.width; height: source.height
            paddingRect: Qt.rect(2, 2, 0, 0)
            blurEnabled: true
            blur: 1.0
            blurMax: 8
            brightness: 1
        }
    }
    function setGlow(glow) {
        if (glow) {
            glowObject = glowComponent.createObject(root)
        } else if (glowObject) {
            glowObject.destroy()
        }
    }
    /*Loader {
        id: glowLoader
        //parent: block ?? null
        active: false
        sourceComponent: MultiEffect {
            source: Shape {
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeWidth: 5
                    Component.onCompleted: pathElements = root.path
                }
            }
            width: source.width; height: source.height
            paddingRect: Qt.rect(2, 2, 0, 0)
            blurEnabled: true
            blur: 1.0
            blurMax: 8
            brightness: 1
        }
    }*/
    Component.onCompleted: {
        //setGlowEnabled(true)
        //block.sockets.push(this)
        block instanceof AbstractBlock ? block.sockets.push(this) : console.log("Невозможно добавить сокет")
    }
}
