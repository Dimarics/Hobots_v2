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
            for (let key of workspace.variables.keys()) keys.push(key)
            return keys
        }*/
        textRole: "name"
        //currentIndex: 0
        model: workspace.variables
    }
    ScratchText { text: "значение" }
    ValueInput { id: value; state: ""; block: set_variable }
    function run() {
        workspace.variables.set(var_list.currentIndex, {"name": var_list.currentText, "value": value.value()})
        completed(next)
    }
    function getData() {
        return { "variable": var_list.currentText, "value": value.text }
    }
    function setData(data) {
        value.text = data.value
    }
}
