Button {
    id: root
    borderWidth: 3
    width: 200; height: 300
    scale: pressed ? 0.97 : 1
    contentItem: Text {
        text: root.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
