import QtQuick
import ".."

StackBlock {
    id: delay
    objectName: "Delay"
    borderColor: "#774DCB"
    fillColor: "#9966FF"
    ScratchText { text: "ждать" }
    ValueInput { id: value; text: "1000"; block: delay }
    ListItem { id: units; block: delay; model: ["миллисекунды", "секунды", "минуты"] }
    Timer {
        id: timer
        onTriggered: {
            //console.log("delay %1".arg(interval))
            completed(next)
        }
    }
    function run() {
        let time = value.value()
        if (units.currentText === "секунды") {
            time *= 1000
        } else if (units.currentText === "минуты") {
            time *= 60000
        }
        //console.log("delay %1".arg(time))
        //completed(next)
        timer.interval = time
        timer.restart()
    }
}
