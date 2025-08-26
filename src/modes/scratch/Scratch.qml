import QtQuick
import QtQuick.Layouts
import App
import "../../components" as C

C.AppWidget {
    id: scratch
    property alias movement: workspace.movement
    property alias controls: workspace.controls
    property alias sensors: workspace.sensors
    property BasicBlock currentBlock
    property list<BasicBlock> topLevelBlocks
    property list<BasicBlock> blocksWithContent
    defaultFilePath: App.tempLocation + App.device.objectName + "_scratch.json"
    openNameFilters: ["Файлы JSON (*.json)"]
    //onOpen: path => { if (workspace.open(path)) currentFilePath = path }
    //onSave: path => { currentFilePath = path; workspace.save(path)}
    Component.onDestruction: workspace.save(currentFilePath)
    function open(path: string): bool { return workspace.open(path) }
    function save(path: string) { workspace.save(path) }
    toolBar: C.ToolBar {
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
    }
    C.JsonSettings {
        categories: [App.device.objectName, "Scratch"]
        path: App.appDataLocation + "settings.json"
        property alias scale: workspace.canvasScale
        property alias currentPath: scratch.currentFilePath
        onLoaded: if (!workspace.open(currentPath)) currentPath = defaultFilePath
    }
    ScratchWorkspace {
        id: workspace
        anchors { top: scratch.toolBar.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
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
        //console.log("stop")
    }
}
