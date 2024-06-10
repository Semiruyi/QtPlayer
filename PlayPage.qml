import QtQuick
import QtMultimedia
import QtQuick.Controls
import Qt.labs.folderlistmodel
import QtQuick.Layouts


Item {
    id: root
    focus: true
    property variant parentValue: null
    property string folderUrl: ""
    property int epIndex: 0
    signal back()

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
        color: epArea.color


        Video {
            property bool isPlaying: false
            id: video
            width: parent.width
            height: parent.height
            MouseArea {
                id: videoMouseArea
                anchors.fill: video

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
                    videoFooter.visible = true
                    hideFooterTimer.restart()
                }
            }

        }

        Rectangle {
            id: videoFooter

            anchors.bottom: video.bottom
            height: 70
            width: video.width
            z: 2
            // color: "white"
            visible: false
            color: videoArea.color
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: videoArea.color }
            }

            Slider {
                id: progressBar
                from: 0
                to: video.duration
                value: video.position
                height: 20
                anchors.bottom: footerBtnRec.top
                anchors.bottomMargin: 5
                width: videoFooter.width

                onMoved: {
                    video.position = value
                    hideFooterTimer.restart()
                }

                Timer {
                    interval: 1000
                    running: video.playbackState === video.PlayingState
                    repeat: true
                    onTriggered: progressBar.value = video.position
                }


            }
            Rectangle {
                id: footerBtnRec
                height: 30
                width: videoFooter.width
                anchors.bottom: videoFooter.bottom
                anchors.bottomMargin: 10
                color: "transparent"
                RowLayout {
                    anchors.fill: footerBtnRec
                    spacing: 10
                    layoutDirection: Qt.LeftToRight

                    IconButton {
                        id: lastEpBtn
                        height: parent.height
                        width: height
                        scale: 0.8
                        icon: "file:///C:/y/project/QtPlayer/resources/icons/last.png"
                        visible: root.epIndex === 0 ? false : true
                        onClicked: function (mouse) {
                            epList.itemAtIndex(root.epIndex - 1).mouseArea.clicked(mouse)
                        }
                    }

                    IconButton {
                        id: palyBtn
                        height: parent.height
                        width: height
                        checked: video.isPlaying
                        icon: "file:///C:/y/project/QtPlayer/resources/icons/play.png"
                        iconChecked: "file:///C:/y/project/QtPlayer/resources/icons/pause.png"
                        onClicked: function (mouse) {
                            videoMouseArea.doubleClicked(mouse)
                        }
                    }

                    IconButton {
                        id: nextEpBtn
                        height: parent.height
                        width: height
                        scale: 0.8
                        icon: "file:///C:/y/project/QtPlayer/resources/icons/next.png"
                        onClicked: function (mouse) {
                            epList.itemAtIndex(root.epIndex + 1).mouseArea.clicked(mouse)
                        }
                    }

                    IconButton {
                        id: fullScreenBtn
                        height: parent.height
                        width: height
                        icon: "file:///C:/y/project/QtPlayer/resources/icons/fullScreen.png"
                        iconChecked: "file:///C:/y/project/QtPlayer/resources/icons/exitFullScreen.png"
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
            id: hideFooterTimer
            interval: 1500;
            repeat: false;
            running: false;
            onTriggered: {
                videoFooter.visible = false
            }
        }
    }



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
                            epList.itemAtIndex(root.epIndex).btn.state = "watched"
                            epList.itemAtIndex(root.epIndex).btn.watched = true
                            epBtn.state = "selected"
                            root.epIndex = index
                            video.isPlaying = false
                            video.source = folderUrl + "/" + fileName
                            video.play()
                            video.isPlaying = true
                        }

                        onEntered: {
                            if(epBtn.state === "selected") return
                            epBtn.state = "focus"
                        }
                        onExited: {
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
        Button {
            anchors.bottom: parent.bottom
            text: "Back"
            onClicked: {
                root.parentValue.back()
            }
        }
    }


}
