import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as T
import Style
import Hobots
import App
import "../../components" as C

C.AppWidget {
    id: root
    enum Templates {
        Coordinates, Joints, Speed, Laser, Pomp, Grub, PWM//, Delay
    }
    property list<int> templates: [
        Script.Coordinates, Script.Joints, Script.Speed, Script.Laser,
        Script.Pomp, Script.Grub, Script.PWM//, Script.Delay
    ]
    defaultFilePath: App.tempLocation + App.device.objectName + "_script.json"
    openNameFilters: {
        //console.log(ScriptBackend.Python)
        switch (scriptBackend.language) {
        case ScriptBackend.Cpp:
            return ["Файлы исходных текстов (*.cpp *.c)", "Текстовые файлы (*.txt)", "Все файлы (*.*)"]
        case ScriptBackend.Python:
            return ["Файлы скриптов Python (*.py)", "Текстовые файлы (*.txt)", "Все файлы (*.*)"]
        default: return []
        }
    }
    toolBar: C.ToolBar {
        //Item { Layout.fillWidth: true}
        C.TabBox {
            id: languageBox
            model: ["C++", "Python"]
            onCurrentIndexChanged: scriptBackend.language = currentIndex
            Component.onCompleted: scriptBackend.language = currentIndex
        }
        Item { Layout.fillWidth: true}
        onClear: textEdit.text = ""
        onStartButtonToggled: scriptBackend.start(textEdit.text)
    }
    function open(path: string): bool {
        const text = App.readFile(path);
        if (!text) return false
        textEdit.text = text; return true
    }
    function save(path: string) { App.saveFile(textEdit.text, path) }
    C.JsonSettings {
        categories: [App.device.objectName, "Script"]
        path: App.appDataLocation + "settings.json"
        property alias language: languageBox.currentIndex
        property alias currentPath: root.currentFilePath
        onLoaded: if (!open(currentPath)) currentPath = defaultFilePath
    }
    /*C.ComboBox {
        id: languageBox
        //width: 250
        model: ["C++", "Python"]
        anchors {
            top: toolBar.bottom
            left: commandListHeader.left; leftMargin: 12
            right: commandListHeader.right; rightMargin: 12
        }
    }*/
    C.Text {
        id: commandListHeader
        text: "Hobots API"
        width: 250
        padding: 4
        horizontalAlignment: Text.AlignHCenter
        background: Rectangle { color: Style.headerBackgroundColor }
        anchors.top: toolBar.bottom
        //anchors.topMargin: 12
    }
    ListView {
        id: commandList
        width: commandListHeader.width
        //padding: 12
        clip: true
        anchors { top: commandListHeader.bottom; bottom: parent.bottom }
        model: ListModel { }
        delegate: T.ItemDelegate {
            id: delegate
            //required property var model
            required property int index
            required property string tip
            required property string template
            width: ListView.view.width//; height: root.height
            leftPadding: 16; rightPadding: 16; topPadding: 4; bottomPadding: 4
            contentItem: C.Text {
                text: tip
                font.pointSize: Style.textSize
                scale: delegate.pressed ? 0.97 : 1
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
            background: Rectangle {
                color: delegate.hovered ? Style.highlightBackgroundColor : "transparent"
                border.color: "transparent"
            }
            onClicked: textEdit.insert(textEdit.cursorPosition, template)
        }
        Component.onCompleted: {
            for (let template of templates) {
                switch (template) {
                case Script.Coordinates:
                    model.append({"tip": "перейти в точку x, y", "template": "moveToXY(x, y)"})
                    model.append({"tip": "перейти в точку x, y, z", "template": "moveToXYZ(x, y, z)"})
                    break;
                case Script.Joints:
                    model.append({"tip": "установить угол", "template": "setJoint(index, value)"})
                    model.append({"tip": "значение угла", "template": "joint(index)"})
                    break;
                case Script.Speed:
                    model.append({"tip": "установить скорость", "template": "setSpeed(значение)"})
                    break;
                case Script.Grub:
                    model.append({"tip": "захват", "template": "grub(0 - открыт, 1 - закрыт)"})
                    break;
                case Script.Pomp:
                    model.append({"tip": "помпа", "template": "pomp(0 - выключена, 1 - активна)"})
                    break;
                case Script.Laser:
                    model.append({"tip": "лазер", "template": "laser(0 - выключен, 1 - активен)"})
                    break;
                case Script.PWM:
                    model.append({"tip": "ШИМ", "template": "pwm(pin, value)"})
                    break;
                }
            }
            model.append({"tip": "ждать", "template": "delay(msecs)"})
        }
    }
    Rectangle {
        id: lineCount
        color: "#EAEAEA"
        width: lineCountText.width
        clip: true
        anchors { left: commandList.right; top: toolBar.bottom; bottom: parent.bottom }
        Text {
            id: lineCountText
            color: "gray"
            font: textEdit.font
            y: -flickable.contentY
            width: Math.max(implicitWidth, 60)
            //verticalAlignment: Qt.AlignTop
            horizontalAlignment: Qt.AlignRight
            leftPadding: 16; rightPadding: 16
            topPadding: textEdit.topPadding; bottomPadding: textEdit.bottomPadding
            textFormat: Text.RichText
            text: {
                var numbers = ""
                for (let i = 1; i <= textEdit.lineCount; ++i)
                    numbers += i === textEdit.currentLine ? "<b>" + i + "</b><br>" : i + "<br>"
                return numbers
            }
        }
    }
    Rectangle {
        id: background
        color: "white"
        width: parent.width
        anchors { left: lineCount.right; right: parent.right; top: toolBar.bottom; bottom: parent.bottom }
    }
    C.Flickable {
        id: flickable
        clip: true
        sliderColor: "gray"
        contentWidth: textEdit.width; contentHeight: textEdit.height
        anchors.fill: background
        TextEdit {
            id: textEdit
            property int currentLine: 1
            focus: true
            color: "black"
            selectionColor: Style.textSelectionColor
            font.pointSize: 14
            font.family: "consolas"
            padding: 10; leftPadding: 6
            Keys.onTabPressed: insert(cursorPosition, "    ")
            width: Math.max(implicitWidth, flickable.width); height: Math.max(implicitHeight, flickable.height)
            //textFormat: TextEdit.RichText
            /*Timer {
                    interval: 100; repeat: true; running: true
                    onTriggered: {

                    }
                }*/
            onCursorPositionChanged: {
                var line = 1, pos = 0;
                while ((pos = text.indexOf('\n', pos) + 1) > 0 && pos <= cursorPosition) {
                    line++;
                }
                currentLine = line;
                scrollToCursor()
            }
            //onCursorRectangleChanged: console.log(cursorRectangle)
            //onCursorRectangleChanged: scrollToCursor()
            function scrollToCursor() {
                var speed = 500
                var padding = 4
                var viewRect = Qt.rect(flickable.contentX, flickable.contentY, flickable.width, flickable.height)

                if (viewRect.left + padding > cursorRectangle.left) {
                    flickable.contentX += -viewRect.left + cursorRectangle.left - padding
                } else if (viewRect.right - padding < cursorRectangle.right) {
                    flickable.contentX += -viewRect.right + cursorRectangle.right + padding
                }

                if (viewRect.top + padding > cursorRectangle.top) {
                    flickable.contentY += -viewRect.top + cursorRectangle.top - padding
                } else if (viewRect.bottom - padding < cursorRectangle.bottom) {
                    flickable.contentY += -viewRect.bottom + cursorRectangle.bottom + padding
                }
            }
        }
        Behavior on contentX { NumberAnimation { duration: 100 } }
        Behavior on contentY { NumberAnimation { duration: 100 } }
        //onFlickEnded: textEdit.scrollToCursor()
    }
    ScriptBackend {
        id: scriptBackend
        textDocument: textEdit.textDocument
    }
}
