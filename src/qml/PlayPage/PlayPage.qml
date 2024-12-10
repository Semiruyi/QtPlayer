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

        width: root.playPageRatio > root.preferrRatio ? height * root.preferrRatio : root.width
        height: root.height
        anchors.horizontalCenter: root.horizontalCenter

        color: "black"

        // MouseArea {
        //     anchors.fill: parent
        //     onClicked: {
        //         qPlayHistory.setTest(1)
        //     }
        // }

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

            MouseArea {
                id: vedioMouseEvent
                Timer {
                    id: videoAreaClickTimer
                    interval: 300
                    onTriggered: videoArea.singleClicked()
                }

                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: {
                    videoFooterArea.state = "display"
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
                id: videoHeader
            }

            Rectangle {
                id: videoFooterArea
                height: 70
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
                property bool containMouse: footerAreaMouseArea.containsMouse | videoFooter.containMouse

                MouseArea {
                    id: footerAreaMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

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

                Timer {
                    id: autoHideTimer
                    interval: qPagePageConfig.autoHideInterval;
                    repeat: false;
                    running: videoFooterArea.state == "display" && !videoFooterArea.containMouse
                    onTriggered: {
                        videoFooterArea.state = "hide"
                    }
                }
            }

            Rectangle {
                width: 55
                height: 55
                color: "transparent"
                anchors.bottom: videoArea.bottom
                anchors.right: videoArea.right
                anchors.bottomMargin: 75
                anchors.rightMargin: 55
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
