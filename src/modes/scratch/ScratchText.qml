import QtQuick

Text {
    color: "white"
    font.family: "Segoe UI"; font.pointSize: 14; font.weight: Font.DemiBold
    verticalAlignment: Text.AlignVCenter
    function copy(block: AbstractBlock): ScratchText {
        return Qt.createComponent("ScratchText.qml").createObject(null, { text: text })
    }
}
