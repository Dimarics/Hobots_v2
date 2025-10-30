import Apps.Scratch
import App

StackBlock {
    id: root
    objectName: "../../../Hobot_L_type_3/ScratchBlocks/SonarRGB"
    fillColor: "#00C8A5"
    borderColor: "#009B80"
    ScratchText { text: "подсветка сонара" }
    ListItem { id: sensor_id; block: root; model: ['A', 'B', 'C', 'D', 'E', 'F'] }
    ScratchText { text: "№" }
    ValueInput { id: address; text: ""; state: "int"; block: root }
    ScratchText { text: "красный" }
    ValueInput { id: red; text: "50"; state: "int"; block: root }
    ScratchText { text: "зелёный" }
    ValueInput { id: green; text: "50"; state: "int"; block: root }
    ScratchText { text: "синий" }
    ValueInput { id: blue; text: "50"; state: "int"; block: root }
    function cppCode(): string {
        return `setSonarRGB(${sensor_id.currentIndex}, ${address.cppCode()}, ` +
                `${red.cppCode()}, ${green.cppCode()}, ${blue.cppCode()});\n${bottomSocket.cppCode()}`
    }
}
