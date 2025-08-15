import ".."

RepeatBlock {
    id: repeatFor
    objectName: "RepeatFor"
    finished: !condition.value()
    ScratchText { text: "повторять пока" }
    BooleanSocket { id: condition; block: repeatFor }
    function run() { completed(finished ? next : contentSocket.next) }
}
