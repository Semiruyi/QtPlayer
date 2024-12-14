import QtQuick
import Qt.labs.folderlistmodel
import "utils.js" as Utils

Rectangle {
    id: root
    color: "black"

    property var parentValue: null
    property url folderUrl: ""
    property int epIndex: 0
    property real playPageRatio: root.width / root.height
    property real preferrRatio: 2.0
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
                root.forceActiveFocus()
                videoBody.playStateChanged()
            }

            onDoubleClicked: {
                root.forceActiveFocus()
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
                property bool containsMouse: videoHeaderMouseArea.containsMouse || videoHeader.containsMouse
                id: videoHeaderArea
                height: 40
                width: videoArea.width
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.5)  }
                    GradientStop { position: 1.0; color: "transparent"}
                }
                state: videoFooterArea.state
                states: [
                    State {
                        name: "display"
                        AnchorChanges {
                            target: videoHeaderArea
                            anchors.bottom: undefined
                            anchors.top: videoArea.top
                        }
                    },
                    State {
                        name: "hide"
                        AnchorChanges {
                            target: videoHeaderArea
                            anchors.top: undefined
                            anchors.bottom: videoArea.top
                        }
                    }
                ]
                transitions: Transition {
                    AnchorAnimation { duration: qGlobalConfig.animationDuration; easing.type: Easing.OutCubic}
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
                }
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
                    AnchorAnimation { duration: qGlobalConfig.animationDuration; easing.type: Easing.OutCubic}
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
                    running: videoFooterArea.state == "display" && !videoFooterArea.containMouse && !videoHeaderArea.containsMouse
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
