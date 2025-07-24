import ".."

ValueBlock {
    id: diff
    objectName: "Diff"
    ValueInput { id: arg_1; block: diff }
    ScratchText { text: "-" }
    ValueInput { id: arg_2; block: diff }
    function value() { return arg_1.value() - arg_2.value() }
}
