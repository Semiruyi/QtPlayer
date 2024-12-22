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
    property bool autoPlayUsed: false
    property bool autoPlay: qPlayPageConfig.autoPlay
    property alias playBackRate: video.playbackRate

    // private
    property bool isFirstLoad: true   // MediaPlay

    signal play()
    signal pause()
    signal playStateChanged()
    signal forward()
    signal back()
    signal volumeUp()
    signal volumeDown()

    onForward: {
        video.position += 5000
    }

    onBack: {
        video.position -= 5000
    }

    onSourceChanged: {
        video.source = root.source
        root.isPlaying = false
        root.autoPlayUsed = false
        autoPlayTimer.restart()
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

    onVolumeUp: {
        audioOutput.volume += 0.05
    }

    onVolumeDown: {
        audioOutput.volume -= 0.05
    }

    MediaPlayer {
        id: video
        videoOutput: videoOutput
        audioOutput: AudioOutput {
            id: audioOutput
            volume: 1.0
        }
        onMediaStatusChanged: {
            console.log("mediaStatus", mediaStatus)
            if(mediaStatus === MediaPlayer.LoadedMedia) {
                video.position = qPlayHistoryConfig.getEpPos(root.epIndex)
            }
        }

    }

    VideoOutput {
        id: videoOutput
        anchors.fill: root
    }

    // 投降喵， 我选择暴力 每一集的自动播放
    Timer {
        id: autoPlayTimer
        running: true
        repeat: true
        interval: 400
        onTriggered: {
            // console.log("timer triggered")
            if(root.isFirstLoad) {
                autoPlayTimer.stop()
                return
            }

            if(!video.playing && !root.autoPlayUsed && root.autoPlay) {
                video.play()
                root.isPlaying = true
                root.autoPlayUsed = true
            }
        }
    }

    Timer {
        running: true
        interval: 400
        repeat: false
        onTriggered: {
            // console.log("enter  mediaStatus", video.mediaStatus)
            audioOutput.volume = 0
            video.play()
            pauseTimer.start()
        }
    }

    Timer {
        id: pauseTimer
        interval: 400
        running: false
        onTriggered: {
            if(!root.autoPlay) {
                // console.log("rrrrrr right?")
                video.pause()
                root.isPlaying = false
            } else {
                // console.log("rrrrrr error?")
                root.isPlaying = true
            }
            audioOutput.volume = 1.0
            root.isFirstLoad = false
        }
    }
}
