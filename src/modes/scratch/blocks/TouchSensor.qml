import ".."
import App

ValueBlock {
    id: root
    objectName: "TouchSensor"
    fillColor: "#00C8A5"
    borderColor: "#009B80"
    property alias list: sensor_id.model
    ScratchText { text: "датчик нажатия" }
    ListItem { id: sensor_id; block: root }
    function value() {
        return App.device.data[3 + 5 * sensor_id.currentIndex]
    }
}
