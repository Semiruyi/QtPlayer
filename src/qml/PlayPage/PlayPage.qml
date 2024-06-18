import QtQuick
import QtMultimedia
import QtQuick.Controls
import Qt.labs.folderlistmodel
import QtQuick.Layouts
import PlayControl
import "utils.js" as Utils

Item {
    id: root
    focus: true
    property variant parentValue: null
    property url folderUrl: ""
    property int epIndex: 0
    signal back()

    PlayHistory {
        id: playHistory
        Component.onCompleted: {
            playHistory.init(folderUrl + "/QtPlayerData")
        }
    }

    FolderListModel {
        id: folderModel
        folder: root.folderUrl
        nameFilters: ["*.mp4"]
        showDirs: false
    }

    function rgb(r,g,b){
        var ret=(r << 16 | g << 8 | b);
        return("#"+ret.toString(16)).toUpperCase();
    }

    Keys.onPressed: function(event){
        if (event.key === Qt.Key_F) {
            event.accepted = true;
            fullScreenBtn.clicked(event)
        } else if (event.key === Qt.Key_Space) {
            event.accepted = true;
            videoMouseArea.doubleClicked(event)
        } else if (event.key === Qt.Key_Escape) {
            root.parentValue.showNormal()
            videoArea.fullScreen = false
        }
    }

    // video play area, this area have three parts: header(back button, episode index display), body(video), footer(some buttons)
    // header and footer will show/hide automaticly
    Rectangle {
        id: videoArea
        property bool fullScreen: false
        width: videoArea.fullScreen ? root.width : root.width - epArea.width
        height: videoArea.fullScreen ? root.height : root.height
        z: fullScreen ? 1 : 0
        color: fullScreen ? "black" : epArea.color

        MouseArea {
            id: videoMouseArea
            anchors.fill: videoArea
            onDoubleClicked: {
                if(video.isPlaying){
                    video.pause()
                } else {
                    video.play()
                }

                video.isPlaying = !video.isPlaying
            }
            hoverEnabled: true
            onMouseXChanged: {
                videoHeader.visible = true
                videoFooter.state = "display"
                autoHideTimer.restart()
            }
        }

        MediaPlayer {
            property bool isPlaying: false
            id: video
            videoOutput: videoOutput
            audioOutput: AudioOutput {
                volume: 1.0
            }
            onMediaStatusChanged: {
                if(mediaStatus === MediaPlayer.LoadedMedia) {
                    video.position = playHistory.getEpPos(root.epIndex)
                    progressBar.value = video.position
                }
            }
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }

        Rectangle {
            x: videoOutput.contentRect.x
            y: videoOutput.contentRect.y
            height: videoOutput.contentRect.height
            width: videoOutput.contentRect.width
            color: "white"
            // MyComponent.MyRec {

            // }
        }

        Rectangle {
            id: videoHeader
            anchors.top: videoArea.top
            height: 40
            width: videoArea.width
            z: 2
            visible: false
            gradient: Gradient {
                GradientStop { position: 0.0; color: videoArea.color }
                GradientStop { position: 1.0; color: "transparent" }
            }
            Rectangle {
                id: headerBtnRec
                height: videoArea.fullScreen ? 30 : 20
                width: videoHeader.width
                anchors.top: videoHeader.top
                anchors.topMargin: 10
                color: "transparent"
                Row {
                    anchors.fill: headerBtnRec
                    anchors.leftMargin: headerBtnRec.height / 3
                    anchors.rightMargin: headerBtnRec.height / 3
                    spacing: videoArea.fullScreen ? footerBtnRec.height + 10 : footerBtnRec.height
                    IconButton {
                        height: parent.height + 5
                        width: height
                        icon: "qrc:/resources/icons/back.png"
                        onClicked: {
                            if(videoArea.fullScreen === true) {
                                fullScreenBtn.clicked(mouse)
                            } else {
                                root.parentValue.back()
                                playHistory.saveData()
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: pauseIconRec
            width: 55
            height: 55
            anchors.right: videoFooter.right
            anchors.bottom: videoFooter.top
            anchors.bottomMargin: 5
            anchors.rightMargin: 40
            color: "transparent"
            Image {
                id: pauseIcon
                anchors.fill: parent
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                source: "qrc:/resources/icons/pause-big.png"
                states: [
                    State {
                        name: "display"
                        when: !video.isPlaying
                        PropertyChanges {
                            target: pauseIcon
                            scale: 1.0
                            opacity: 1.0
                        }
                    },
                    State {
                        name: "hide"
                        when: video.isPlaying
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
                            easing.type: Easing.InOutQuad
                        }
                    }
                ]
            }
        }

        Rectangle {
            id: videoFooter
            anchors.top: videoArea.bottom
            height: progressBar.height + footerBtnRec.height
            width: videoArea.width

            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: videoArea.color }
            }

            states: [
                State {
                    name: "display"
                    AnchorChanges {
                        target: videoFooter
                        anchors.top: undefined
                        anchors.bottom: videoArea.bottom
                    }
                },
                State {
                    name: "hide"
                    AnchorChanges {
                        target: videoFooter
                        anchors.top: videoArea.bottom
                        anchors.bottom: undefined
                    }
                }
            ]

            transitions: Transition {
                AnchorAnimation { duration: 200; easing.type: Easing.InOutQuad}
            }

            Slider {
                id: progressBar
                from: 0
                to: video.duration
                value: video.position
                height: 25
                anchors.bottom: footerBtnRec.top
                bottomPadding: 5
                width: videoFooter.width

                onMoved: {
                    video.position = value
                    autoHideTimer.restart()
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
                        color: rgb(33,139,188)
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
                    running: video.isPlaying
                    repeat: true
                    onTriggered: {
                        progressBar.value = video.position
                        playHistory.setEpPos(epIndex, video.position)
                    }
                }
            }

            Rectangle {
                id: footerBtnRec
                height: videoArea.fullScreen ? 35 : 30
                width: videoFooter.width
                anchors.bottom: videoFooter.bottom
                color: "transparent"

                RowLayout {
                    anchors.fill: footerBtnRec
                    anchors.leftMargin: parent.height * 0.65
                    anchors.rightMargin: parent.height * 0.65
                    anchors.bottomMargin: 10
                    spacing: videoArea.fullScreen ? height * 0.8 + 5 : height * 0.8

                    IconButton {
                        id: lastEpBtn
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.maximumHeight: parent.height * 1.2
                        Layout.maximumWidth: parent.height * 1.2
                        width: height
                        scale: 0.8
                        icon: "qrc:/resources/icons/last.png"
                        visible: root.epIndex === 0 ? false : true
                        onClicked: function (mouse) {
                            epList.itemAtIndex(root.epIndex - 1).mouseArea.clicked(mouse)
                        }
                    }

                    IconButton {
                        id: playBtn
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.maximumHeight: parent.height * 1.2
                        Layout.maximumWidth: parent.height * 1.2
                        checked: video.isPlaying
                        hoveredScale: 1.4
                        icon: "qrc:/resources/icons/play.png"
                        iconChecked: "qrc:/resources/icons/pause.png"
                        onClicked: function (mouse) {
                            videoMouseArea.doubleClicked(mouse)
                        }
                    }

                    IconButton {
                        id: nextEpBtn
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.maximumHeight: parent.height * 1.2
                        Layout.maximumWidth: parent.height * 1.2
                        scale: 0.8
                        icon: "qrc:/resources/icons/next.png"
                        visible: root.epIndex === epList.count - 1 ? false : true
                        onClicked: function (mouse) {
                            epList.itemAtIndex(root.epIndex + 1).mouseArea.clicked(mouse)
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: videoProgressMessage.width
                        Layout.preferredHeight: parent.height
                        Layout.maximumHeight: parent.height * 1.2
                        Layout.maximumWidth: 220
                        color: "transparent"
                        Text {
                            id: videoProgressMessage
                            font.pixelSize: videoArea.fullScreen ? 15 : 12
                            color: "white"
                            anchors.centerIn: parent
                            text: Utils.formattedVideoDuration(video.position) + "  /  " + Utils.formattedVideoDuration(video.duration)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: parent.height
                        color: "transparent"
                    }

                    IconButton {
                        id: speedMessage
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.maximumHeight: parent.height * 1.2
                        Layout.maximumWidth: parent.height * 1.2
                        textColor: "white"
                        text: "1.0x"
                        fontBold: true
                    }

                    IconButton {
                        id: fullScreenBtn
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.maximumHeight: parent.height * 1.2
                        Layout.maximumWidth: parent.height * 1.2
                        icon: "qrc:/resources/icons/fullScreen.png"
                        iconChecked: "qrc:/resources/icons/exitFullScreen.png"
                        checked: videoArea.fullScreen
                        onClicked: function (mouse) {
                            if(videoArea.fullScreen === false){
                                root.parentValue.showFullScreen()
                            }
                            else {
                                root.parentValue.showNormal()
                            }
                            videoArea.fullScreen = !videoArea.fullScreen
                        }
                    }
                }
            }
        }

        Timer {
            id: autoHideTimer
            interval: 1500;
            repeat: false;
            running: false;
            onTriggered: {
                videoHeader.visible = false
                videoFooter.state = "hide"
            }
        }
    }

    // episode list area. create a series of button to switch episode and set animation on switch episode
    Rectangle {
        id: epArea
        width: 250
        height: root.height
        anchors.right: root.right
        color: rgb(31,34,35)

        GridView {
            id: epList
            anchors.fill: parent

            cellWidth: width / 4
            cellHeight: cellWidth
            clip: true
            model: folderModel

            delegate: Rectangle {
                width: epList.cellWidth
                height: epList.cellHeight
                color: rgb(31,34,35)
                property MouseArea mouseArea: epBtnMouseArea
                property Rectangle btn: epBtn
                Rectangle {
                    id: epBtn
                    property bool watched: false
                    width: 50
                    height: 50
                    anchors.centerIn: parent
                    radius: 10
                    color: rgb(10, 10, 10)
                    Component.onCompleted: {
                        if(index === root.epIndex) {
                            epBtn.state = "selected"
                            epBtn.watched = true
                            video.source = folderUrl + "/" + fileName
                            video.play()
                            video.pause()
                        }
                        else if(playHistory.isWatched(index)) {
                            epBtn.watched = true;
                            epBtn.state = "watched"
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: "white"//rgb(208,204,198)
                        font.pixelSize: 15
                        //font.bold: true
                    }

                    states: [
                        State {
                            name: "watched"
                            PropertyChanges {
                                target: epBtn
                                color: rgb(70,70,70)
                                scale: 1.0
                            }
                        },
                        State {
                            name: "selected";
                            PropertyChanges {
                                target: epBtn
                                color: "lightSkyBlue"
                                scale: 1.2
                            }
                        },
                        State {
                            name: "focus"
                            PropertyChanges {
                                target: epBtn
                                color: "steelBlue"
                                scale: 1.2
                            }
                        },
                        State {
                            name: "normal"
                            PropertyChanges {
                                target: epBtn
                                color: rgb(10, 10, 10)
                                scale: 1.0
                            }
                        },
                        State {
                            name: "pressed"
                            when: epBtnMouseArea.pressed
                            PropertyChanges {
                                target: epBtn
                                color: "steelBlue"
                                scale: 0.8
                            }
                        }

                    ]
                    transitions: [
                        Transition {
                            from: "*"
                            to: "*"
                            NumberAnimation {
                                target: epBtn
                                properties: "width, height, scale"
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }

                            ColorAnimation {
                                properties: "color"
                                duration: 200
                            }
                        }
                    ]

                    MouseArea {
                        id: epBtnMouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            if(index === root.epIndex) {
                                epBtn.state = "selected"
                                return
                            }
                            playHistory.setWatchState(index, true)
                            epList.itemAtIndex(root.epIndex).btn.state = "watched"
                            epBtn.watched = true
                            epBtn.state = "selected"
                            root.epIndex = index
                            video.source = folderUrl + "/" + fileName
                            video.play()
                            video.isPlaying = true
                        }

                        onEntered: {
                            if(epBtn.state === "selected") return
                            epBtn.state = "focus"
                        }
                        onExited: {
                            // console.log("test", index)
                            if(index === root.epIndex) {
                                epBtn.state = "selected"
                                return
                            }
                            if(epBtn.watched === true){
                                epBtn.state = "watched"
                            } else {
                                epBtn.state = "normal"
                            }

                        }

                    }
                }
            }
        }

    }

}
