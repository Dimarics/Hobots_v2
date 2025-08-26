import QtQuick as Q
import QtQuick.Layouts

Q.Item {
    id: root
    default property alias content: layout.data
    property alias running: startButton.checked
    signal create
    signal open
    signal save
    signal saveAs
    signal clear
    signal startButtonToggled
    signal stop
    signal exit
    //signal startToggled: startButton.toggled
    height: exitButton.height + 30
    onStop: running = false
    Flickable {
        id: flickable
        clip: true
        width: parent.width - exitButton.width - 30; height: parent.height
        contentWidth: Math.max(layout.implicitWidth, flickable.width)
        boundsMovement: width < contentWidth ? Flickable.FollowBoundsBehavior : Flickable.StopAtBounds
        RowLayout {
            id: layout
            spacing: 15
            anchors.fill: parent
            anchors.margins: 15
            Button {
                toolTip: "Создать"
                visible: false
                icon.source: "qrc:/images/create.svg"
                icon.width: 0; icon.height: 40
                onClicked: create()
            }
            Button {
                toolTip: "Открыть"
                icon.source: "qrc:/images/open.svg"
                icon.width: 40; icon.height: 0
                onClicked: open()
            }
            Button {
                toolTip: "Сохранить"
                icon.source: "qrc:/images/save.svg"
                icon.width: 36; icon.height: 36;
                onClicked: save()
            }
            Button {
                toolTip: "Сохранить как"
                icon.source: "qrc:/images/save_as.svg"
                icon.width: 36; icon.height: 36;
                onClicked: saveAs()
            }
            Button {
                toolTip: "Очистить"
                icon.source: "qrc:/images/trash.svg"
                icon.width: 32; icon.height: 0;
                onClicked: clear()
            }
            Button {
                id: startButton
                toolTip: checked ? "Старт" : "Пауза"
                checkable: true
                icon.source: checked ? "qrc:/images/pause.svg" : "qrc:/images/start.svg"
                icon.width: 32; icon.height: 32
                onToggled: startButtonToggled()
            }
            Button {
                toolTip: "Стоп"
                icon.source: "qrc:/images/stop.svg"
                icon.width: 32; icon.height: 32
                onClicked: stop()
            }
            Q.Item { Layout.fillWidth: true }
        }
    }
    Button {
        id: exitButton
        toolTip: "Выход"
        icon.source: "qrc:/images/exit.svg"
        icon.width: 32; icon.height: 32
        anchors { verticalCenter: parent.verticalCenter; right: parent.right; margins: 15}
        onClicked: exit()
    }
}
