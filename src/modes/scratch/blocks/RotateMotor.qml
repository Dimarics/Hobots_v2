import ".."
import App

StackBlock {
    id: root
    objectName: "RotateMotor"
    property alias list: motor_id.model
    ScratchText { text: "вращать мотор" }
    ListItem { id: motor_id; block: root }
    ListItem { id: dir; block: root; model: ["по часовой стрелке", "против часовой стрелки"] }
    ScratchText { text: "со скоростью" }
    ValueInput { id: speed; text: "100"; block: root }
    function run() {
        //App.device.protocol.rotateMotor(motor_id.currentIndex, dir.currentIndex, speed.value(), ()=>completed(next))
        App.device.protocol.rotateMotor(motor_id.currentIndex, dir.currentIndex, speed.value())
        completed(next)
    }
}
