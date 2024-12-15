import QtQuick

GridView {
    width: 200 * 1.618
    height: 200
    Behavior on width {
        NumberAnimation {
            duration: qGlobalConfig.animationDuration
            easing.type: Easing.OutCubic
        }
    }
    add: Transition {
        NumberAnimation {
            property: "scale"
            duration: qGlobalConfig.animationDuration
            easing.type: Easing.OutCubic
            from: 0.2
            to: 1
        }
    }
    remove: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "scale"
                duration: qGlobalConfig.animationDuration
                easing.type: Easing.OutCubic
                to: 0
            }
            NumberAnimation {
                property: "opacity"
                duration: qGlobalConfig.animationDuration
                easing.type: Easing.OutCubic
                to: 0
            }
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "x,y";
            duration: qGlobalConfig.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    move: Transition {
        NumberAnimation {
            properties: "x,y";
            duration: qGlobalConfig.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    populate: Transition {
        NumberAnimation {
            property: "scale"
            duration: qGlobalConfig.animationDuration * 1.5
            easing.type: Easing.OutCubic
            from: 0
            to: 1
        }
    }

}
