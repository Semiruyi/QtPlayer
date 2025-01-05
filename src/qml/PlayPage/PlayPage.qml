import QtQuick
import Qt.labs.folderlistmodel
import "utils.js" as Utils

Rectangle {
    id: root
    color: "black"

    property var parentValue: null
    property url folderUrl: ""
    property int epIndex: 0
    property int cardIndex: 0
    property real playPageRatio: root.width / root.height
    property real preferrRatio: 2.197324414715719
    property int animationDuration: qGlobalConfig.animationDuration
    focus: true
    Keys.onPressed: function (event) {
        switch (event.key) {
            case Qt.Key_Escape:
                console.log("Key_Escape")
                if(videoArea.isFullScreen == true) {
                    videoArea.isFullScreen = false
                } else
                {
                    parentValue.back();
                }
                break;
            case Qt.Key_Space:
                videoBody.playStateChanged()
                break;
            case Qt.Key_F:
                videoArea.isFullScreen = !videoArea.isFullScreen
                break;
            case Qt.Key_Return:
                videoArea.isFullScreen = true
                break;
            case Qt.Key_Left:
                autoHideTimer.restart()
                videoFooterArea.state = "display"
                videoBody.back()
                break;
            case Qt.Key_Right:
                autoHideTimer.restart()
                videoFooterArea.state = "display"
                videoBody.forward()
                break;
            case Qt.Key_Up:
                videoBody.volumeUp()
                break;
            case Qt.Key_Down:
                videoBody.volumeDown()
            default:
                break;
        }
        event.accepted = true
    }

    // Timer {
    //     running: true
    //     repeat: true
    //     interval: 1000
    //     onTriggered: {
    //         console.log(playPageRatio)
    //     }
    // }

    Rectangle {
        id: contentArea

        width: root.playPageRatio > root.preferrRatio ? height * root.preferrRatio : root.width
        height: root.height
        anchors.horizontalCenter: root.horizontalCenter

        color: "black"

        Rectangle {
            id: videoArea
            color: Utils.rgb(31,34,35)
            anchors.verticalCenter: contentArea.verticalCenter
            clip: true
            property bool containsMouse: videoAreaMouseArea.containsMouse || videoFooterArea.containMouse || videoHeaderArea.containsMouse
            property bool isFullScreen: false

            // bug: the containsMouse property is not arrcurate
            // onContainsMouseChanged: {
            //     if(!videoArea.containsMouse)
            //     {
            //         videoFooterArea.state = "hide"
            //     }
            // }

            signal singleClicked()
            signal doubleClicked()

            states: [
                State {
                    name: "normal"
                    PropertyChanges {
                        target: videoArea
                        width: contentArea.width - episodeArea.width
                        height: width / 16 * 9
                    }
                },
                State {
                    name: "fullScreen"
                    PropertyChanges {
                        target: videoArea
                        width: contentArea.width
                        height: contentArea.height
                    }
                }
            ]

            state: "normal"

            onIsFullScreenChanged: {
                if(isFullScreen) {
                    root.parentValue.showFullScreen()
                    videoArea.state = "fullScreen"
                } else {
                    root.parentValue.showNormal()
                    videoArea.state = "normal"
                }
            }

            onSingleClicked: {
                root.forceActiveFocus()
                videoBody.playStateChanged()
            }

            onDoubleClicked: {
                root.forceActiveFocus()
                videoArea.isFullScreen = !videoArea.isFullScreen
            }

            MouseArea {
                id: videoAreaMouseArea
                Timer {
                    id: videoAreaClickTimer
                    interval: 300
                    onTriggered: videoArea.singleClicked()
                }

                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: {
                    videoFooterArea.state = "display"
                    videoAreaMouseArea.cursorShape = Qt.ArrowCursor
                }

                onClicked: {
                    if(videoAreaClickTimer.running) {
                        videoArea.doubleClicked()
                        videoAreaClickTimer.stop()
                    } else {
                        videoAreaClickTimer.restart()
                    }
                }
            }

            Rectangle {
                id: videoBodyArea
                color: "black"
                anchors.fill: videoArea
                VideoBody {
                    id: videoBody
                    anchors.fill: videoBodyArea
                    epIndex: episodeList.epIndex
                }
            }

            Rectangle {
                property bool containsMouse: videoHeaderMouseArea.containsMouse || videoHeader.containsMouse
                id: videoHeaderArea
                height: 40
                width: videoArea.width
                visible: opacity < 0.01 ? false : true
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.5)  }
                    GradientStop { position: 1.0; color: "transparent"}
                }
                state: videoFooterArea.state
                states: [
                    State {
                        name: "display"
                        PropertyChanges {
                            target: videoHeaderArea
                            opacity: 1
                        }
                    },
                    State {
                        name: "hide"
                        PropertyChanges {
                            target: videoHeaderArea
                            opacity: 0
                        }
                    }
                ]
                transitions: Transition {
                    NumberAnimation {
                        property: "opacity"
                        duration: qGlobalConfig.animationDuration;
                        easing.type: Easing.OutCubic
                    }
                }
                MouseArea {
                    id: videoHeaderMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                VideoHeader {
                    id: videoHeader
                    anchors.fill: parent
                    onBackBtnClicked: {
                        if(videoArea.isFullScreen)
                        {
                            videoArea.isFullScreen = false
                            return
                        }
                        root.parentValue.back()
                    }
                    fileName: videoBody.source
                }
            }

            Rectangle {
                id: playPositionTipRec
                height: playPositionTipText.implicitHeight * 2
                width: playPositionTipText.implicitWidth * 1.1
                radius: 5
                color: Qt.rgba(0, 0, 0, 0.6)
                anchors.bottom: videoFooterArea.top
                anchors.left: videoArea.left
                anchors.bottomMargin: -5
                anchors.leftMargin: videoArea.width * 0.015
                transformOrigin: Item.BottomLeft
                scale: 0
                Behavior on scale {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    id: playPositionTipText

                    property string lastPlayPosText: "00:00"

                    anchors.centerIn: parent
                    text: qsTr("Redirected to last viewed location ") + lastPlayPosText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                    font.pixelSize: 16
                }

                Connections {
                    target: videoBody
                    function onVideoLoadedChanged() {
                        if(videoBody.videoLoaded) {
                            if(videoBody.position < 10000) {
                                return
                            }

                            playPositionTipText.lastPlayPosText = Utils.formattedVideoDuration(videoBody.position)
                            // console.log("try run times", i, "videoBody.position", playPositionTipText.lastPlayPosText)
                            videoFooterArea.state = "display"
                            playPositionTipRec.scale = 1
                            if(!videoFooterArea.containMouse && !videoHeaderArea.containsMouse) {
                                autoHideTimer.restart()
                            }
                            hidePlayPositionTipRecTimer.restart()
                        }
                    }
                }

                Timer {
                    id: hidePlayPositionTipRecTimer
                    interval: qPlayPageConfig.autoHideInterval
                    running: false
                    onTriggered: {
                        playPositionTipRec.scale = 0
                    }
                }
            }

            Rectangle {
                id: videoFooterArea
                visible: opacity < 0.01 ? false : true
                height: 90
                width: videoArea.width
                color: "transparent"
                state: "display"
                anchors.bottom: videoArea.bottom
                states: [
                    State {
                        name: "display"
                        PropertyChanges {
                            target: videoFooterArea
                            opacity: 1
                        }
                    },
                    State {
                        name: "hide"
                        PropertyChanges {
                            target: videoFooterArea
                            opacity: 0
                        }
                    }
                ]
                property bool containMouse: footerAreaMouseArea.containsMouse | videoFooter.containMouse

                MouseArea {
                    id: footerAreaMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                transitions: Transition {
                    NumberAnimation {
                        property: "opacity"
                        duration: qGlobalConfig.animationDuration;
                        easing.type: Easing.OutCubic
                    }
                }

                VideoFooter {
                    id: videoFooter
                    anchors.fill: videoFooterArea
                    video: videoBody
                    videoArea: videoArea
                    episodeList: episodeList
                    finalEpIndex: folderModel.count - 1
                    onProgressBarReleased: {
                        root.forceActiveFocus()
                    }
                }

                Timer {
                    id: autoHideTimer
                    interval: qPlayPageConfig.autoHideInterval;
                    repeat: false;
                    running: videoFooterArea.state == "display" && !videoFooterArea.containMouse && !videoHeaderArea.containsMouse
                    onTriggered: {
                        videoFooterArea.state = "hide"
                        videoAreaMouseArea.cursorShape = Qt.BlankCursor
                    }
                }
            }

            Rectangle {
                width: 55
                height: 55
                color: "transparent"
                anchors.bottom: videoArea.bottom
                anchors.right: videoArea.right
                anchors.bottomMargin: parent.height * 0.15
                anchors.rightMargin: parent.width * 0.05
                PauseIcon {
                    anchors.fill: parent
                    video: videoBody
                }
            }

        }

        Rectangle {
            id: episodeArea
            width: 250
            height: contentArea.height
            anchors.left: videoArea.right
            // color: "blue"
            color: Utils.rgb(31,34,35)
            EpisodeList {
                id: episodeList
                epIndex: root.epIndex
                lastEpIndex: root.epIndex
                anchors.fill: parent
                cardIndex: root.cardIndex
                folderModel: FolderListModel {
                    id: folderModel
                    folder: root.folderUrl
                    nameFilters: ["*.mp4", "*.mkv"]
                    showDirs: false
                }
                folderUrl: root.folderUrl
                video: videoBody
            }
        }
    }

    Component.onCompleted: {
        root.forceActiveFocus()
    }

}
