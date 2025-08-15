import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import "../../components" as C
//import Qt5Compat.GraphicalEffects

Item {
    id: scratch
    property alias movement: workspace.movement
    property alias controls: workspace.controls
    property alias sensors: workspace.sensors
    property AbstractBlock currentBlock
    property list<AbstractBlock> topLevelBlocks
    property list<AbstractBlock> blocksWithContent
    signal exit
    C.ToolBar {
        id: toolBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        onOpen: workspace.open("D:/scratch.json")
        onSave: workspace.save(workspace.path)
        onSaveAs: workspace.save("D:/scratch.json")
        onClear: { workspace.clear(); stop() }
        onStartButtonToggled: {
            if (running) {
                topLevelBlocks = workspace.topLevelBlocks()
                if (topLevelBlocks.length) {
                    currentBlock = topLevelBlocks.pop()
                    if (currentBlock.reset) {
                        currentBlock.reset()
                        blocksWithContent.push(currentBlock)
                    }
                    currentBlock.glow = true
                    currentBlock.run()
                } else {
                    running = false
                }
            } else {
                currentBlock.run();
            }
        }
        onStop: scratch.stop()
        onExit: scratch.exit()
    }
    ScratchWorkspace {
        id: workspace
        anchors { top: toolBar.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
    }
    Connections {
        target: currentBlock
        //ignoreUnknownSignals: false
        function onCompleted(next) {
            if (!toolBar.running) return
            currentBlock.glow = false
            if (next) {
                if (next.reset) { next.reset(); blocksWithContent.push(next) }
                currentBlock = next
            } else {
                if (blocksWithContent.length) {
                    currentBlock = blocksWithContent[blocksWithContent.length - 1]
                    if (currentBlock.finished) blocksWithContent.pop()
                } else if (topLevelBlocks.length) {
                    currentBlock = topLevelBlocks.pop()
                    if (currentBlock.reset) {
                        currentBlock.reset()
                        blocksWithContent.push(currentBlock)
                    }
                } else {
                    stop(); return
                }
            }
            currentBlock.glow = true
            Qt.callLater(() => currentBlock.run())
        }
    }
    function stop() {
        if (currentBlock) {
            currentBlock.glow = false
            currentBlock = null
        }
        blocksWithContent = []
        topLevelBlocks = []
        toolBar.running = false
        //console.log("stop")
    }
}
