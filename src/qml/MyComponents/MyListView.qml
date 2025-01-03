import QtQuick 2.12

ListView {
    id: root

    property int animationDuration: 400

    add: Transition {
        NumberAnimation {
            property: "scale"
            duration: root.animationDuration
            easing.type: Easing.OutCubic
            from: 0.2
            to: 1
        }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "scale"
                duration: root.animationDuration
                easing.type: Easing.OutCubic
                to: 0
            }
            NumberAnimation {
                property: "opacity"
                duration: root.animationDuration
                easing.type: Easing.OutCubic
                to: 0
            }
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "x,y";
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    move: Transition {
        NumberAnimation {
            properties: "x,y";
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    populate: Transition {
        NumberAnimation {
            property: "scale"
            duration: root.animationDuration * 1.5
            easing.type: Easing.OutCubic
            from: 0
            to: 1
        }
    }
}
