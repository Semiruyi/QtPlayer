import QtQuick

Item {

    id: root
    property VideoBody video

    Rectangle {
        id: pauseIconRec
        color: "transparent"
        anchors.fill: parent
        Image {
            id: pauseIcon
            anchors.fill: parent
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: "qrc:/resources/icons/pause-big.png"
            states: [
                State {
                    name: "display"
                    when: !root.video.isPlaying
                    PropertyChanges {
                        target: pauseIcon
                        scale: 1.0
                        opacity: 1.0
                    }
                },
                State {
                    name: "hide"
                    when: root.video.isPlaying
                    PropertyChanges {
                        target: pauseIcon
                        scale: 0
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "*"
                    to: "*"
                    PropertyAnimation {
                        target: pauseIcon
                        properties: "scale, opacity"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            ]
        }
    }

}
