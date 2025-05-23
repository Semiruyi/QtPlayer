import QtQuick
import QtQuick.Controls
import QtMultimedia
import "utils.js" as Utils

Item {
    id: root
    property VideoBody video
    property EpisodeList episodeList
    property bool containMouse: progressBar.hovered || progressBar.pressed
    property int animationDuration: 200

    signal released()

    Slider {
        id: progressBar
        anchors.fill: parent
        from: 0
        to: root.video.duration

        Timer {
            id: updateProgressBarTimer
            interval: 10
            repeat: true
            running: !progressBar.pressed
            onTriggered: function() {
                progressBar.value = root.video.position
            }
        }

        onMoved: {
            if(root.video.mediaStatus == MediaPlayer.EndOfMedia) {
                root.video.play()
                root.video.pause()
            }
            updateProgressBarTimer.stop()
            root.video.position = value
            // do not ask me why the fucking mediaplayer need to set twice
            root.video.position = value

            console.log("progressBar.position", progressBar.position)
            console.log("progressBar.visualPosition", progressBar.visualPosition)
        }

        onPressedChanged: {
            if(!progressBar.pressed) {
                root.released()
            }
        }

        background: Rectangle {
            y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4

            width: progressBar.availableWidth
            height: progressBar.hovered ? implicitHeight * 1.4 : implicitHeight

            radius: 2
            color: Qt.rgba(0.5, 0.5, 0.5, 0.4)

            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                width: progressBar.position * parent.width
                height: parent.height
                color: Utils.rgb(33,139,188)
                radius: 2

                Behavior on width {
                    NumberAnimation {
                        duration: 20
                        easing.type: Easing.Linear
                    }
                }
            }
        }

        handle: Rectangle {
            x: progressBar.visualPosition * root.width - width / 2
            y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2

            scale: progressBar.pressed ? 0.8 : (progressBar.hovered ? 1 : 0)

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }

            implicitWidth: 10
            implicitHeight: 17
            radius: 2
            color: progressBar.pressed ? "#bdbebf" : "#f6f6f6"
            border.color: "#bdbebf"
        }

        Timer {
            interval: 1500
            running: root.video.isPlaying
            repeat: true
            onTriggered: {
                qPlayHistoryConfig.setEpPos(root.episodeList.epIndex, video.position)
            }
        }
    }

}
