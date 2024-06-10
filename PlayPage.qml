import QtQuick
import QtMultimedia
import QtQuick.Controls
import Qt.labs.folderlistmodel


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

    // MouseEvent {
    //     id: mouse
    // }

    function rgb(r,g,b){
        var ret=(r << 16 | g << 8 | b);
        return("#"+ret.toString(16)).toUpperCase();
    }

    Keys.onPressed: function(event){
        if (event.key === Qt.Key_F) {
            event.accepted = true;
            fullScreenBtn.clicked()
        } else if (event.key === Qt.Key_Space) {
            event.accepted = true;
            videoMouseArea.doubleClicked(mouse)
            video.isPlaying = !video.isPlaying
        } else if (event.key === Qt.Key_Escape) {
            root.parentValue.showNormal()
            videoArea.fullScreen = false
        }
    }

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
                    interval: 1000 // 每秒更新一次进度条
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
                color: "black"
                Row {
                    anchors.fill: footerBtnRec
                    Button {
                        id: fullScreenBtn
                        text: "fullsreen"
                        onClicked: {
                            if(videoArea.fullScreen === false){
                                root.parentValue.showFullScreen()
                            }
                            else {
                                root.parentValue.showNormal()
                            }
                            videoArea.fullScreen = !videoArea.fullScreen
                        }
                    }
                    TestButton {
                        height: 40
                        width: 40
                        bgColor: "transparent"
                        icon: "file:///C:/y/project/QtPlayer/resources/icons/next.png"
                        onClicked: function (mouse) {
                            epList.itemAtIndex(root.epIndex + 1).children[0].children[1].clicked(mouse)
                        }

                        // onClicked: {
                        //     epList.itemAtIndex(root.epIndex + 1).children[0].children[1].clicked(mouse)
                        // }
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
                Rectangle {
                    id: epBtn
                    property int thisHeight: 50
                    property int thisWidth: 50
                    property bool watched: false

                    width: epBtn.thisWidth
                    height: epBtn.thisHeight
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
                                height: epBtn.thisHeight
                                width: epBtn.thisWidth
                            }
                        },
                        State {
                            name: "selected";
                            PropertyChanges {
                                target: epBtn
                                color: "lightSkyBlue"
                                height: epBtn.thisHeight + 10
                                width: epBtn.thisWidth + 10
                            }
                        },
                        State {
                            name: "focus"
                            PropertyChanges {
                                target: epBtn
                                color: "steelBlue"
                                height: epBtn.thisHeight + 10
                                width: epBtn.thisWidth + 10
                            }
                        },
                        State {
                            name: "normal"
                            PropertyChanges {
                                target: epBtn
                                color: rgb(10, 10, 10)
                                height: epBtn.thisHeight
                                width: epBtn.thisWidth
                            }
                        },
                        State {
                            name: "pressed"
                            when: epBtnMouseArea.pressed
                            PropertyChanges {
                                target: epBtn
                                color: "steelBlue"
                                height: epBtn.thisHeight - 10
                                width: epBtn.thisWidth - 10
                            }
                        }

                    ]
                    transitions: [
                        Transition {
                            from: "*"
                            to: "*"
                            NumberAnimation {
                                target: epBtn
                                properties: "width, height"
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
                            epList.itemAtIndex(root.epIndex).children[0].state = "watched"
                            epList.itemAtIndex(root.epIndex).children[0].watched = true
                            epBtn.state = "selected"
                            root.epIndex = index
                            video.isPlaying = false
                            video.source = folderUrl + "/" + fileName
                            video.play()
                            video.pause()
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
