import QtQuick as Q
import QtQuick.Controls.Basic as T

T.ToolTip {
    id: root
    delay: 1000
    timeout: 5000
    leftPadding: 4; rightPadding: 4; topPadding: 2; bottomPadding: 2
    background: Q.Rectangle {
        color: Style.darkWidgetColor
        border.color: Style.brightWidgetBorderColor
    }
    contentItem: Text {
        id: label
        text: root.text
        font.pointSize: 10
    }
}
