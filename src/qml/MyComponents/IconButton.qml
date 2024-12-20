import QtQuick

Rectangle {
    id: root
    property string text
    property url icon
    property alias iconChecked: iconChecked.source
    property bool checkable: false
    property bool checked: false
    property color bgColor: "transparent"
    property color bgColorSelected: "transparent"
    property color textColor: "white"
    property bool hovered: mouseArea.containsMouse
    property real normalScale: 1.0
    property real pressedScale: 0.8
    property real hoveredScale: 1.2
    property bool fontBold: false
    readonly property alias pressed: mouseArea.pressed
    signal clicked(MouseEvent mouse)
    signal pressAndHold()

    width: 30
    height: 30
    opacity: 0.9
    color: checked ? bgColorSelected : mouseArea.pressed ? Qt.darker(bgColor) : bgColor
    border.color: Qt.lighter(color)

    Text {
        id: text
        anchors.fill: parent
        text: root.text
        font.pixelSize: 0.7 * parent.height
        color: root.textColor
        font.bold: root.fontBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Image {
        source: root.icon
        anchors.fill: parent
        visible: !root.checked
    }
    Image {
        id: iconChecked
        anchors.fill: parent
        visible: root.checked
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        // acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (mouse) {
            if (root.checkable)
                root.checked = !root.checked
            root.clicked(mouse)
        }
        onPressAndHold: root.pressAndHold()
    }
    // state: "hide"
    states: [
        State {
            name: "brighter"
            when: mouseArea.containsMouse && !mouseArea.pressed // only the first true State is applied, so put scale and opacity together
            PropertyChanges { target: root; opacity: 1.0; scale: hoveredScale }
        },
        State {
            name: "pressed"
            when: mouseArea.pressed
            PropertyChanges {
                target: root; opacity: 1.0; scale: root.pressedScale
            }
        }
    ]

    transitions: [
        Transition {
            PropertyAnimation {
                properties: "opacity,scale"
                easing.type: Easing.OutQuart
                duration: 300
            }
        }
    ]

}
