import ".."

BooleanBlock {
    id: equal
    objectName: "Equal"
    ValueInput { id: arg_1; block: equal }
    ScratchText { text: "=" }
    ValueInput { id: arg_2; text: "50"; block: equal }
    function value() { return arg_1.value() === arg_2.value() }
}
