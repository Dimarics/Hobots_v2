import QtQuick
import QtQuick.Layouts
import App
import Hobots
import Components as C

C.AppWidget {
    id: scratch
    property alias movement: workspace.movement
    property alias controls: workspace.controls
    property alias sensors: workspace.sensors
    property bool debugMode: true
    property bool programmingMode: false
    property string fqbn
    property string boardOptions
    property BasicBlock currentBlock: null
    property list<BasicBlock> topLevelBlocks
    property list<BasicBlock> blocksWithContent
    defaultFilePath: `${App.tempLocation}${App.deviceName}_Scratch.json`
    openNameFilters: ["Файлы JSON (*.json)"]
    //onOpen: path => { if (workspace.open(path)) currentFilePath = path }
    //onSave: path => { currentFilePath = path; workspace.save(path)}
    function open(data: string): bool { return workspace.open(data) }
    function save(path: string) { workspace.save(path) }
    toolBar: C.ToolBar {
        processRun: debugMode
        onClear: { workspace.clear(); stop() }
        onStart: {
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
                //running = false
                status = C.ToolBar.NotRunning
            }
        }
        onPause: {
            App.device.protocol.stay()
        }
        onResume: {
            currentBlock.run()
        }
        onStop: scratch.stop()
        C.Button {
            toolTip: "Загрузить"
            icon.source: "qrc:/images/download.svg"
            icon.width: 32; icon.height: 32
            icon.color: pressed ? C.Style.buttonPressedTextColor : hovered || firmwareLoader.state !== FirmwareLoader.Inactive ?
                                      C.Style.buttonHoveredTextColor : C.Style.buttonTextColor
            visible: programmingMode
            onClicked: {
                var topLevelBlocks = workspace.topLevelBlocks()
                if (!topLevelBlocks.length) return
                var code = ""
                // инициализация переменных
                for (var i = 0; i < workspace.variables.count; ++i)
                    code += `double ${workspace.variables.get(i).name} = 0;\n`
                // добавление настроек
                code += "settings();\n"
                // добавление блоков
                while (topLevelBlocks.length) {
                    let block = topLevelBlocks.pop()
                    if ("cppCode" in block) code += block.cppCode()
                }
                code = setupCode() + "void setup() {\n" + formatCode(code) + "}\nvoid loop() {}"
                console.log(code)
                firmwareLoader.loadFirmware(code, portBox.currentText, fqbn, boardOptions)
            }
        }
        Item { Layout.fillWidth: true }
        C.ComboBox {
            id: portBox
            visible: programmingMode
            model: App.availablePorts
            Layout.preferredWidth: 140
        }
        Item { visible: programmingMode; Layout.fillWidth: true }
    }
    C.JsonSettings {
        categories: [App.deviceName, "Scratch"]
        path: App.appDataLocation + "settings.json"
        property alias scale: workspace.canvasScale
        property alias currentPath: scratch.currentFilePath
        onLoaded: if (!workspace.open(App.readFile(currentPath))) currentPath = defaultFilePath
    }
    ScratchWorkspace {
        id: workspace
        anchors { top: scratch.toolBar.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
    }
    Connections {
        target: currentBlock
        //ignoreUnknownSignals: false
        function onCompleted(next) {
            if (toolBar.status !== C.ToolBar.Running) return
            //if (!toolBar.running) return
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
                    toolBar.status = C.ToolBar.NotRunning
                    stop(); return
                }
            }
            currentBlock.glow = true
            Qt.callLater(() => currentBlock.run())
        }
    }
    FirmwareLoader {
        id: firmwareLoader
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
    function setupCode() { return "" }
    function formatCode(code: string): string {
        let tab_count = 1
        let format_code = "    "
        for (let i = 0; i < code.length; ++i) {
            format_code += code[i]
            switch (code[i]) {
            case '{':
                ++tab_count
                break
            case '\n':
                if (code[i + 1] === '}') --tab_count
                if (i != code.length - 1) for (let t = 0; t < tab_count; ++t) format_code += "    "
                break
            default: break
            }
        }
        return format_code
    }
}
