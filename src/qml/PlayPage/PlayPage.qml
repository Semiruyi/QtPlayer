import QtQuick
import Qt.labs.folderlistmodel
import "utils.js" as Utils

Rectangle {
    id: root
    color: "black"
    property Window parentValue
    property url folderUrl: ""
    property int epIndex: 0
    property real playPageRatio: root.width / root.height
    property real preferrRatio: 2.0
    signal back()
    focus: true

    Timer {
        id: log
        interval: 1000;
        repeat: true;
        running: false;
        onTriggered: {
            console.log("now ratio is ", root.playPageRatio)
        }
    }

    Keys.onPressed: function (event) {
        switch (event.key) {
            case Qt.Key_Escape:
                videoArea.isFullScreen = false
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
                videoBody.back()
                break;
            case Qt.Key_Right:
                videoBody.forward()
                break;
            default:
                break;
        }
        event.accepted = true
    }

    Rectangle {
        id: contentArea

        width: playPageRatio > preferrRatio ? height * preferrRatio : root.width
        height: root.height
        anchors.horizontalCenter: root.horizontalCenter

        color: "black"

        Rectangle {
            id: videoArea
            color: Utils.rgb(31,34,35)
            anchors.verticalCenter: contentArea.verticalCenter
            clip: true
            property bool isFullScreen: false

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
                videoBody.playStateChanged()
            }

            onDoubleClicked: {
                videoArea.isFullScreen = !videoArea.isFullScreen
            }

            Timer {
                id: autoHideTimer
                interval: 1500;
                repeat: false;
                running: false;
                onTriggered: {
                    // videoHeader.visible = false
                    videoFooterArea.state = "hide"
                }
            }

            MouseArea {
                Timer {
                    id: videoAreaClickTimer
                    interval: 300
                    onTriggered: videoArea.singleClicked()
                }

                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: {
                    videoFooterArea.state = "display"
                    autoHideTimer.restart()
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
                    playHistory: episodeList.playHistory
                    anchors.fill: videoBodyArea
                    epIndex: episodeList.epIndex
                    // source: "file:///C:/Users/wyy/Videos/bocchi the rock/[Airota][BOCCHI THE ROCK!][01][BDRip 1080p AVC AAC][CHS].mp4"
                }
            }

            Rectangle {
                id: videoHeader
            }

            Rectangle {
                id: videoFooterArea
                height: 50
                width: videoArea.width
                color: "transparent"
                state: "hide"
                states: [
                    State {
                        name: "display"
                        AnchorChanges {
                            target: videoFooterArea
                            anchors.top: undefined
                            anchors.bottom: videoArea.bottom
                        }
                    },
                    State {
                        name: "hide"
                        AnchorChanges {
                            target: videoFooterArea
                            anchors.top: videoArea.bottom
                            anchors.bottom: undefined
                        }
                    }
                ]

                transitions: Transition {
                    AnchorAnimation { duration: 200; easing.type: Easing.InOutQuad}
                }

                VideoFooter {
                    id: videoFooter
                    anchors.fill: videoFooterArea
                    video: videoBody
                    videoArea: videoArea
                    episodeList: episodeList
                    finalEpIndex: folderModel.count - 1

                }
            }

            Rectangle {
                width: 55
                height: 55
                color: "transparent"
                anchors.bottom: videoArea.bottom
                anchors.right: videoArea.right
                anchors.bottomMargin: 55
                anchors.rightMargin: 55
                PauseIcon {
                    anchors.fill: parent
                    video: videoBody
                }
            }
        }

        // Rectangle {
        //     id: commentArea
        //     anchors.top: videoArea.bottom
        //     width: videoArea.width
        //     height: contentArea.height - videoArea.height
        //     color: "yellow"
        //     MouseArea {
        //         anchors.fill: parent
        //         onClicked: {

        //         }
        //     }
        // }

        Rectangle {
            id: episodeArea
            width: 250
            height: contentArea.height
            anchors.left: videoArea.right
            // color: "blue"
            color: Utils.rgb(31,34,35)
            EpisodeList {
                id: episodeList
                anchors.fill: parent
                folderModel: FolderListModel {
                    id: folderModel
                    folder: root.folderUrl
                    nameFilters: ["*.mp4"]
                    showDirs: false
                }
                folderUrl: root.folderUrl
                video: videoBody
            }
        }

    }


}
