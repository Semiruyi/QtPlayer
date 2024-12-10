import QtQuick
import QtMultimedia

Item {
    id: root
    property url source
    property bool isPlaying: false
    property alias position: video.position
    property alias duration: video.duration
    property int epIndex
    property alias mediaStatus: video.mediaStatus

    signal play()
    signal pause()
    signal playStateChanged()
    signal forward()
    signal back()

    onForward: {
        video.position += 5000
    }

    onBack: {
        video.position -= 5000
    }

    onSourceChanged: {
        video.source = root.source
        root.isPlaying = false
    }

    onPlay: {
        video.play()
        isPlaying = true
    }

    onPause: {
        video.pause()
        isPlaying = false
    }

    onPlayStateChanged: {
        if(isPlaying === false) {
            video.play()
        } else {
            video.pause()
        }
        isPlaying = !isPlaying
    }

    MediaPlayer {
        id: video
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            volume: 1.0
        }
        onMediaStatusChanged: {
            if(mediaStatus === MediaPlayer.LoadedMedia) {
                video.position = qPlayHistoryConfig.getEpPos(root.epIndex)
            }
        }
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: root
    }

}
