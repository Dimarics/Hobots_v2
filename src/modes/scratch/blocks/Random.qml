import ".."

ValueBlock {
    id: rand
    objectName: "Random"
    ScratchText { text: "случайное от" }
    ValueInput { id: min; text: "1"; block: rand }
    ScratchText { text: "до" }
    ValueInput { id: max; text: "10"; block: rand }
    function value() { return Math.random() * (max.value() - min.value()) + min.value() }
}
