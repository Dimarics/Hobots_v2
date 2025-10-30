import QtQuick
import QtCore
import Hobots
import App

Item {
    id: root
    property string defaultFilePath
    property string currentFilePath: defaultFilePath
    property list<string> openNameFilters
    property list<string> saveNameFilters: openNameFilters
    property Item toolBar: null
    //signal open(path: string);
    //signal save(path: string);
    signal exit;
    function open(data: string): bool { return false }
    function save(path: string) { }
    onToolBarChanged: {
        toolBar.parent = root
        toolBar.width = Qt.binding(()=>root.width)
        toolBar.exit.connect(exit)
    }
    Component.onDestruction: save(defaultFilePath)
    Component {
        id: openFileDialog
        FilePicker {
            title: "Открытие файла"
            fileMode: FilePicker.OpenFile
            nameFilters: root.openNameFilters
            onClosed: destroy()
            onFileReaded: data => root.open(data)
        }
    }
    Component {
        id: saveFileDialog
        FilePicker {
            title: "Открытие файла"
            fileMode: FilePicker.SaveFile
            nameFilters: root.openNameFilters
            onClosed: destroy()
            onFileReaded: data => root.save(selectedFile)
        }
    }
    Connections {
        target: toolBar
        function onOpen() {
            var fileDialog = openFileDialog.createObject(this)
            fileDialog.open()
        }
        function onSave() { root.save(root.currentFilePath) }
        function onSaveAs() {
            var fileDialog = saveFileDialog.createObject(this)
            fileDialog.open()
        }
    }
    /*Connections {
        target: toolBar
        function onOpen() { openFileDialog.createObject(this) }
        function onSave() { root.save(root.currentFilePath) }
        function onSaveAs() { saveFileDialog.createObject(this) }
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
    }*/
}
