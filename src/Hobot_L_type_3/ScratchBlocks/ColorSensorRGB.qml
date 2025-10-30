import Apps.Scratch
import App

StackBlock {
    id: root
    objectName: "../../../Hobot_L_type_3/ScratchBlocks/ColorSensorRGB"
    fillColor: "#00C8A5"
    borderColor: "#009B80"
    ScratchText { text: "подсветка датчика цвета" }
    ListItem { id: sensor_id; block: root; model: ['A', 'B', 'C', 'D', 'E', 'F'] }
    ScratchText { text: "красный" }
    ValueInput { id: red; text: "50"; state: "int"; block: root }
    ScratchText { text: "зелёный" }
    ValueInput { id: green; text: "50"; state: "int"; block: root }
    ScratchText { text: "синий" }
    ValueInput { id: blue; text: "50"; state: "int"; block: root }
    function cppCode(): string {
        return `setColorSensorRGB(${sensor_id.currentIndex}, ${red.cppCode()}, ${green.cppCode()}, ${blue.cppCode()});\n${bottomSocket.cppCode()}`
    }
}
