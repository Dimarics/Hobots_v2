import ".."

StackBlock {
    id: set_variable
    property alias index: var_list.currentIndex
    objectName: "SetVariable"
    borderColor: "#DB6E00"
    fillColor: "#FF8C1A"
    ScratchText { text: "задать для" }
    ListItem {
        id: var_list
        block: set_variable
        /*model: {
            var keys = []
            for (let key of scratch.variables.keys()) keys.push(key)
            return keys
        }*/
        textRole: "name"
        //currentIndex: 0
        model: scratch.variables
    }
    ScratchText { text: "значение" }
    ValueInput { id: value; block: set_variable }
    function run() { scratch.variables.set(var_list.currentIndex, value.value()) }
}
