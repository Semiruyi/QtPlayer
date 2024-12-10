import QtQuick
import QtQuick.Controls
import QtMultimedia
import "utils.js" as Utils

Item {
    id: root
    property VideoBody video
    property EpisodeList episodeList
    property bool containMouse: progressBar.hovered || progressBar.pressed

    Slider {
        id: progressBar
        anchors.fill: parent
        from: 0
        to: root.video.duration
        value: root.video.position

        onMoved: {
            if(root.video.mediaStatus == MediaPlayer.EndOfMedia)
            {
                root.video.play()
                root.video.pause()
            }

            root.video.position = value
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
                    easing.type: Easing.InOutQuad
                }
            }

            Rectangle {
                width: (progressBar.value - progressBar.from) / (progressBar.to - progressBar.from) * parent.width
                height: parent.height
                color: Utils.rgb(33,139,188)
                radius: 2
            }
        }

        handle: Rectangle {
            x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width) /*- 3 // 微调*/
            // x: progressBar.visualPosition * root.width
            y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2

            scale: root.containMouse ? 1 : 0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            implicitWidth: 10
            implicitHeight: 17
            radius: 2
            color: progressBar.pressed ? "#f0f0f0" : "#f6f6f6"
            border.color: "#bdbebf"
        }

        Timer {
            interval: 350
            running: root.video.isPlaying
            repeat: true
            onTriggered: {
                qPlayHistoryConfig.setEpPos(root.episodeList.epIndex, video.position)
            }
        }
    }
}
