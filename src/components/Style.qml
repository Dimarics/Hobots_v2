pragma Singleton
import QtQuick

QtObject {
    property int textSize: 12
    property color textColor: "white"
    property color highlightTextColor: "#00FFFF"
    property color lightWidgetColor: "#00326E"
    property color darkWidgetColor: "#002346" //"#142142"
    property color borderColor: "#002346"
    property color headerBackgroundColor: "#052D55"
    property color brightWidgetBorderColor: "#50A0F0"

    property color buttonBackgroundColor: "#20FFFFFF"
    property color buttonBorderColor: "#30FFFFFF"
    property color buttonTextColor: "white"
    property color buttonHoveredBackgroundColor: buttonBackgroundColor
    property color buttonHoveredBorderColor: buttonPressedBackgroundColor
    property color buttonHoveredTextColor: "#00FFFF"
    property color buttonPressedBackgroundColor: "#50FFFFFF"
    property color buttonPressedBorderColor: buttonPressedBackgroundColor
    property color buttonPressedTextColor: buttonHoveredTextColor
}
