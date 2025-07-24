import ".."

BooleanBlock {
    id: not
    objectName: "Not"
    ScratchText { text: "не" }
    BooleanSocket { id: arg; block: not }
    function value() { return !arg.value() }
}
