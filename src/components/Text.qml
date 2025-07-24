import QtQuick as T

T.Text {
    color: Style.textColor
    //clip: true
    //antialiasing: false
    font.pointSize: Style.textSize
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
