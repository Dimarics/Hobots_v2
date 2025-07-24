import ".."

StackBlock {
    id: delay
    objectName: "Delay"
    borderColor: "#774DCB"
    fillColor: "#9966FF"
    ScratchText { text: "ждать" }
    ValueInput { id: value; text: "1000"; block: delay }
    ListItem { block: delay; model: ["миллисекунды", "секунды", "минуты"] }
    function run() { console.log("delay %1".arg(value.value())) }
}
