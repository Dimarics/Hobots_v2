import QtQuick
import QtQuick.Layouts
import ".."

ValueBlock {
    property alias name: text.text
    objectName: "Variable"
    borderColor: "#DB6E00"
    fillColor: "#FF8C1A"
    ScratchText { id: text; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
    function copyData(target) { target.name = name }
    function value() {
        //return scratch.variables.get(name)
        return 0
    }
}
