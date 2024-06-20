import QtQuick
import Qt.labs.folderlistmodel

Item {
    id: root
    property Window parentValue
    property url folderUrl: ""
    property int epIndex: 0
    property real playPageRatio: root.width / root.height
    property real preferrRatio: 1.8
    signal back()
    focus: true
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

        Rectangle {
            id: videoArea
            property bool isFullScreen: false

            signal singleClicked()
            signal doubleClicked()

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
                onMouseXChanged: {
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

            state: "normal"
            color: "black"

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

            // transitions: [
            //     Transition {
            //         from: "*"
            //         to: "*"
            //         NumberAnimation {
            //             target: videoArea
            //             properties: "width, height"
            //             duration: 500
            //             easing.type: Easing.InOutQuad
            //         }
            //     }
            // ]

            Rectangle {
                id: videoBodyArea
                anchors.fill: videoArea
                VideoBody {
                    id: videoBody
                    playHistory: episodeList.playHistory
                    anchors.fill: videoBodyArea
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
                // anchors.bottom: videoArea.bottom
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
                    epList: episodeList
                    finalEpIndex: folderModel.count - 1
                }
            }
        }

        Rectangle {
            id: commentArea
            anchors.top: videoArea.bottom
            width: videoArea.width
            height: contentArea.height - videoArea.height
            color: "yellow"
            MouseArea {
                anchors.fill: parent
                onClicked: {

                }
            }
        }

        Rectangle {
            id: episodeArea
            width: 250
            height: contentArea.height
            anchors.left: videoArea.right
            color: "blue"
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
