import QtQuick as Q
import QtQuick.Controls.Basic as T
import QtQuick.Layouts
import QtQuick.Controls.impl

T.ComboBox {
    id: root
    font.pointSize: Style.textSize
    //leftPadding: 10
    height: 30
    Layout.preferredHeight: 30
    background: Q.Rectangle {
        radius: height / 2
        color: Style.darkWidgetColor
        border.width: 1
        border.color: hovered ? Style.brightWidgetBorderColor : "#30FFFFFF" //"#90FFFFFF"
        Q.Behavior on border.color { Q.ColorAnimation { duration: 100 } }
    }
    contentItem: Text {
        leftPadding: 10
        rightPadding: root.indicator.width + root.spacing
        text: root.displayText
        font: root.font
        color: Style.highlightTextColor
    }
    indicator: ColorImage  {
        x: root.width - width - 10
        y: root.topPadding + (root.availableHeight - height) / 2 + 2
        width: 13; height: 8
        color: "#90A6C0"
        //color: "white"
        //color: hovered ? "white" : "#90A6C0"
        //defaultColor: "#c8c8c8"
        source: "qrc:/images/down-arrow.svg"
        sourceSize: Qt.size(width, height)
        //source: "qrc:/qt-project.org/imports/QtQuick/Controls/Universal/images/downarrow.png"
        //source: "qrc:/qt-project.org/imports/QtQuick/Controls/Fusion/images/arrow.png"
        //source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/drop-indicator.png"
    }
    /*indicator: Q.Canvas {
        id: canvas
        x: root.width - width - root.rightPadding
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 13
        height: 7
        contextType: "2d"
        Q.Connections {
            target: root
            function onPressedChanged() { canvas.requestPaint(); }
        }
        onPaint: {
            context.reset();
            context.strokeStyle = "#c8c8c8";
            context.moveTo(0, 0)
            context.lineTo((width - 1) / 2, height);
            context.lineTo(width - 1, 0);
            context.stroke();
        }
    }*/
    delegate: T.ItemDelegate {
        id: delegate
        required property var model
        required property int index
        width: Q.ListView.view.width; height: root.height
        contentItem: Text {
            text: delegate.model[root.textRole]
            color: Style.highlightTextColor
            font: root.font
        }
        background: Q.Rectangle {
            id: highlight
            states: Q.State {
                when: highlightedIndex === index
                Q.PropertyChanges {
                    target: highlight
                    color: "#145FA5"
                    border.color: Style.brightWidgetBorderColor
                }
            }
            color: "transparent"
            border.color: "transparent"
        }
    }
    popup: T.Popup {
        leftPadding: 1
        rightPadding: 1
        topPadding: 15
        bottomPadding: 15
        padding: 0
        width: root.width
        contentItem: Q.ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.delegateModel
            currentIndex: root.highlightedIndex
            //populate: Q.Transition { Q.NumberAnimation { properties: "x,y"; duration: 100 } }
        }
        background: Q.Rectangle {
            color: root.background.color
            border.color: root.background.border.color
            radius: 15
        }
        onVisibleChanged: if (visible && !root.delegateModel) visible = false
    }
    //model: ["Firstooooooooooooooooooooooooooo", "Second", "Third"]
}
