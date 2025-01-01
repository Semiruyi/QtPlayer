import QtQuick
import QtQuick.Controls

StackView {
    id: stack
    property int animationDuration: 400

    pushEnter: Transition {
        ParallelAnimation {
            PropertyAnimation {
                property: "x"
                from: stack.width
                to: 0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }

            PropertyAnimation {
                property: "scale"
                from: 0.5
                to: 1.0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                property: "opacity"
                from: 0.5
                to: 1.0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    pushExit: Transition {
        PropertyAnimation {
            property: "x"
            from: 0
            to: -stack.width
            duration: 300
            easing.type: Easing.OutCubic
        }
    }
    popEnter: Transition {
        ParallelAnimation {
            PropertyAnimation {
                property: "x"
                from: -stack.width
                to: 0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }

            PropertyAnimation {
                property: "scale"
                from: 1.5
                to: 1.0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                property: "opacity"
                from: 0.5
                to: 1.0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    popExit: Transition {
        PropertyAnimation {
            property: "x"
            from: 0
            to: stack.width
            duration: stack.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    replaceEnter: Transition {
        ParallelAnimation {
            PropertyAnimation {
                property: "x"
                from: stack.width
                to: 0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }

            PropertyAnimation {
                property: "scale"
                from: 0.5
                to: 1.0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
            PropertyAnimation {
                property: "opacity"
                from: 0.5
                to: 1.0
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    replaceExit: Transition {
        PropertyAnimation {
            property: "x"
            from: 0
            to: -stack.width
            duration: 300
            easing.type: Easing.OutCubic
        }
    }


}
