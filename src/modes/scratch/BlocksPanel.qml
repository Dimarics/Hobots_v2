import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Shapes
import "blocks"

Item {
    id: root
    default property alias content: layout.data
    component SectionLabel: Text {
        color: "#555F73"
        font.family: "Segoe UI"; font.pointSize: 14; font.weight: Font.DemiBold
    }
    component BPButton: Button {
        id: button
        //backgroundColor: pressed ? "#FF320A" : hovered ? "#E6320A" : "#C8320A"
        //borderWidth: 1
        //borderRadius: height / 2
        //borderColor: "#96320A"
        background: Rectangle {
            radius: 4
            color: button.hovered ? "#20000000" : "white"
            border.color: "#40000000"
            border.width: 1
        }
        contentItem: Text {
            text: "Cоздать переменную"
            color: "#555F73"
            elide: Text.ElideNone
            font.family: "Segoe UI"; font.pointSize: 12; font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
        }
    }
    component ScratchPopup: Popup {
        id: scratchPopup
        parent: scratch
        anchors.centerIn: parent
        dim: true
        font.family: "Segoe UI"; font.pointSize: 12
        Overlay.modeless: Rectangle { color: "#30000000"; parent: scratch }
        background: Rectangle {
            radius: 8
        }
    }
    ScratchPopup {
        id: newVariable
        onOpened: varName.forceActiveFocus()
        onClosed: varName.clear()
        ColumnLayout {
            spacing: 12
            anchors.fill: parent
            //anchors.margins: 16
            Text {
                text: "Новая переменная"
                font.family: "Segoe UI"; font.pointSize: 14; font.weight: Font.DemiBold
            }
            Text {
                text: "Имя новой переменной:"
                font: newVariable.font
            }
            TextField {
                id: varName
                font: newVariable.font
                Layout.fillWidth: true
            }
            Row {
                spacing: 12
                Button { text: "Отмена"; font: newVariable.font; onClicked: newVariable.close() }
                Button { text: "ОК"; font: newVariable.font;
                    onClicked: {
                        var name = varName.text.trim()
                        if (name) {
                            var variable = Qt.createComponent("blocks/Variable.qml").createObject(null, { name: name })
                            variable.dragStart.connect(dragHandler.createNewBlock)
                            //scratch.variables.set(name, 0)
                            function compare(a, b) {
                                if (parseFloat(a) && parseFloat(b)) {
                                    return parseFloat(b) - parseFloat(a)
                                }
                                return b.localeCompare(a)
                            }
                            for (var i = 0; i < scratch.variables.count && compare(name, scratch.variables.get(i).name) < 0; ++i);
                            layout.insert(variable, layout.children.lastIndexOf(variableSection) + 3 + i)
                            scratch.variables.insert(i, {"name": name, "value": undefined})
                            if (scratch.variables.count === 1) set_variable.index = 0
                        }
                        newVariable.close()
                    }
                }
            }
        }
    }
    HoverHandler { parent.clip: !hovered }
    Rectangle {
        opacity: 0.9
        color: "white"
        anchors.fill: parent
    }
    Rectangle {
        id: border
        width: 1
        color: "#BEDCFF"
        anchors.top: root.top
        anchors.right: root.right
        anchors.bottom: root.bottom
    }
    Flickable {
        id: blocksPanel
        anchors.fill: root
        anchors.rightMargin: border.width
        maximumFlickVelocity: 0
        boundsMovement: Flickable.StopAtBounds
        boundsBehavior: Flickable.DragAndOvershootBounds
        contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
        ScrollBar.vertical: ScratchScrollBar {}
        ColumnLayout {
            id: layout
            spacing: 24
            anchors.fill: parent
            anchors.margins: 16
            SectionLabel { text: "Движение" }
            SetJoint { jointList: ['1', '2', '3', '4', '5', '6'] }
            SectionLabel { text: "Управление" }
            Delay {}
            SectionLabel { text: "Операторы" }
            //id: sum; Timer{running: true; interval: 500; repeat: true; onTriggered: {console.log(sum.value())}}
            Sum {}
            Diff {}
            Multiply {}
            Divide {}
            Random {}
            More {}
            Less {}
            Equal {}
            And {}
            Or {}
            Not {}
            SectionLabel { text: "Циклы и условия" }
            IfElse {}
            SectionLabel { id: variableSection; text: "Переменные" }
            BPButton {
                id: createVariable
                onClicked: newVariable.open()
            }
            SetVariable {
                id: set_variable;
                visible: scratch.variables.count
                //onVisibleChanged: if (visible) update()
            }
            function insert(item, index) {
                let shiftElements = []
                for (let i = index; i < children.length; ++i) {
                    shiftElements.push(children[i])
                }
                item.parent = this
                for (let element of shiftElements) {
                    element.parent = parent//window.contentItem //null
                    element.parent = this
                }
            }
        }
    }
    DropArea {
        anchors.fill: parent
        Rectangle {
            id: trashOverlay
            color: "#33000000"
            opacity: 0
            anchors.fill: parent
            Behavior on opacity { OpacityAnimator { duration: 300 } }
            Image {
                id: logo
                width: 64; height: 64
                source: "qrc:/images/trash_opened.svg"
                sourceSize: Qt.size(width, height)
                fillMode: Image.PreserveAspectFit
                mipmap: true
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                anchors.centerIn: parent
            }
        }
        onEntered: function(drag) {
            trashOverlay.opacity = 1
            drag.source.cursorShape = Qt.ForbiddenCursor
        }
        onExited: {
            trashOverlay.opacity = 0
            drag.source.cursorShape = Qt.ClosedHandCursor
        }
        onDropped: function(drop) {
            trashOverlay.opacity = 0
            drop.source.destruct()
        }
    }
}
