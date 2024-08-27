import QtQuick
import QtQuick.Controls
import "utils.js" as Utils

Item {
    id: root
    property VideoBody video
    property EpisodeList episodeList

    Slider {
        id: progressBar
        anchors.fill: parent
        from: 0
        to: video.duration
        value: video.position

        onMoved: {
            root.video.position = value
        }

        background: Rectangle {
            x: progressBar.leftPadding
            y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4

            width: progressBar.availableWidth
            height: implicitHeight
            radius: 2
            color: "transparent"

            Rectangle {
                width: progressBar.visualPosition * parent.width
                height: parent.height
                color: Utils.rgb(33,139,188)
                radius: 2
            }
        }

        handle: Rectangle {
            x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
            y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
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
                qPlayHistory.setEpPos(root.episodeList.epIndex, video.position)
            }
        }
    }
}
