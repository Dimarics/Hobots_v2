import ".."

StackBlock {
    id: set_joint
    objectName: "SetJoint"
    property alias joints: joint_id.model
    ScratchText { text: "установить угол" }
    ListItem { id: joint_id; block: set_joint }
    ScratchText { text: "в" }
    ValueInput { id: angle; text: "60"; block: set_joint }
    ScratchText { text: "°" }
    function run() {
        App.device.motor(joint_id.currentIndex, angle.value(), ()=>completed(next))
    }
}
