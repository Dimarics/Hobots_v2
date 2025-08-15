import ".."
import App

BooleanBlock {
    id: root
    objectName: "LineSensor"
    fillColor: "#00C8A5" //"#00D7B0"
    borderColor: "#009B80" //"#00AC8D"
    property alias list: line_id.model
    ScratchText { text: "датчик линии" }
    ListItem { id: line_id; block: root }
    ScratchText { text: "видит линию" }
    function value() { return App.device.lineSensor[line_id.currentIndex] }
}
