import ".."

ValueBlock {
    id: diff
    objectName: "Diff"
    ValueInput { id: arg_1; block: diff }
    ScratchText { text: "-" }
    ValueInput { id: arg_2; block: diff }
    function value() { return arg_1.value() - arg_2.value() }
    /*function getData() {
        return { "arg_1": arg_1.text, "arg_2": arg_2.text }
    }
    function setData(data) {
        arg_1.text = data.arg_1
        arg_2.text = data.arg_2
    }*/
}
