import ".."
import App

BooleanBlock {
    id: root
    objectName: "ColorSensor"
    fillColor: "#00C8A5" //"#00D7B0"
    borderColor: "#009B80" //"#00AC8D"
    property alias colorSensors: sensor_id.model
    ScratchText { text: "датчик цвета" }
    ListItem { id: sensor_id; block: root }
    ScratchText { text: "видит линию" }
    function value() { return App.device.colorSensor[sensor_id.currentIndex] }
}
