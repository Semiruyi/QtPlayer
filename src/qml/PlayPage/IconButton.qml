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

        onClicked: function (mouse) {
            if (root.checkable)
                root.checked = !root.checked
            root.clicked(mouse)
        }
        // onHoveredChanged: {
        //     if (mouseX > 65535) //qt5.6 touch screen release finger becomes very large e.g. 0x7fffffff
        //         return
        //     hovered = mouseArea.containsMouse
        // }
        onPressAndHold: root.pressAndHold()
    }
    states: [
        State {
            name: "brighter"
            when: root.hovered // only the first true State is applied, so put scale and opacity together
            PropertyChanges { target: root; opacity: 1.0; scale: hoveredScale }
        }/*,
        State {
            name: "pressed"
            when: pressed
            PropertyChanges {

                target: root; opacity: 1.0; scale: 0.8
            }
        },
        State {
            name: "clicked"
            when: clicked
            PropertyChanges {
                target: root; opacity: 1.0; scale: 1.0
            }
        }*/
    ]
    transitions: [
        Transition {
            from: "*"; to: "*"
            PropertyAnimation {
                properties: "opacity,scale"
                easing.type: Easing.OutQuart
                duration: 300
            }
        }
    ]
}
