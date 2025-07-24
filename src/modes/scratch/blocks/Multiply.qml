import ".."

ValueBlock {
    id: multiply
    objectName: "Multiply"
    ValueInput { id: arg_1; block: multiply }
    ScratchText { text: "*" }
    ValueInput { id: arg_2; block: multiply }
    function value() { return arg_1.value() * arg_2.value() }
}
