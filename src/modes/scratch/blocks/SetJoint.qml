import ".."

StackBlock {
    id: set_joint
    objectName: "SetJoint"
    property alias jointList: joint_id.model
    ScratchText { text: "установить угол" }
    ListItem { id: joint_id; block: set_joint }
    ScratchText { text: "в" }
    ValueInput { id: angle; text: "60"; block: set_joint }
    ScratchText { text: "°" }
    function run() { console.log("joint_%1 %2".arg(joint_id.currentText()).arg(angle.value())) }
}
