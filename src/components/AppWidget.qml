import QtQuick
import QtCore
import QtQuick.Dialogs

Item {
    id: root
    property string defaultFilePath
    property string currentFilePath: currentFilePath
    property list<string> openNameFilters
    property list<string> saveNameFilters: openNameFilters
    property Item toolBar: null
    //signal open(path: string);
    //signal save(path: string);
    signal exit;
    function open(path: string): bool { return false }
    function save(path: string) { }
    onToolBarChanged: {
        toolBar.parent = root
        toolBar.width = Qt.binding(()=>root.width)
        toolBar.exit.connect(exit)
    }
    Component {
        id: openFileDialog
        FileDialog {
            title: "Открытие файла"
            fileMode: FileDialog.OpenFile
            nameFilters: root.openNameFilters
            currentFolder: currentFilePath === defaultFilePath ?
                               StandardPaths.writableLocation(StandardPaths.DocumentsLocation) :
                               "file:///" + currentFilePath
            visible: true
            onVisibleChanged: if (!visible) destroy()
            onAccepted: {
                var path = selectedFile.toString().substring(8)
                if (root.open(path)) currentFilePath = path
            }
        }
    }
    Component {
        id: saveFileDialog
        FileDialog {
            title: "Сохранение файла"
            fileMode: FileDialog.SaveFile
            //defaultSuffix: (currentFilePath.slice(currentFilePath.lastIndexOf(".")+1))
            nameFilters: root.saveNameFilters
            currentFolder: currentFilePath === defaultFilePath ?
                               StandardPaths.writableLocation(StandardPaths.DocumentsLocation) :
                               "file:///" + currentFilePath
            visible: true
            onVisibleChanged: if (!visible) destroy()
            onAccepted: {
                var path = selectedFile.toString().substring(8)
                currentFilePath = path
                root.save(path)
            }
        }
    }
    Connections {
        target: toolBar
        function onOpen() { openFileDialog.createObject(this) }
        function onSave() { root.save(root.currentFilePath) }
        function onSaveAs() { saveFileDialog.createObject(this) }
    }
}
