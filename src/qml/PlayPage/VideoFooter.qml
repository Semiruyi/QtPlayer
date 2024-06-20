import QtQuick
import QtQuick.Layouts
import "utils.js" as Utils

Item {
    id: root
    property VideoBody video
    property Rectangle videoArea
    property EpisodeList epList
    property int finalEpIndex

    Rectangle {
        id: videoFooter
        anchors.fill: root
        y: root.height
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }

        transitions: Transition {
            AnchorAnimation { duration: 200; easing.type: Easing.InOutQuad}
        }

        // Slider {
        //     id: progressBar
        //     from: 0
        //     to: video.duration
        //     value: video.position
        //     height: 25
        //     anchors.bottom: footerBtnRec.top
        //     bottomPadding: 5
        //     width: videoFooter.width

        //     onMoved: {
        //         video.position = value
        //         autoHideTimer.restart()
        //     }

        //     background: Rectangle {
        //         x: progressBar.leftPadding
        //         y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
        //         implicitWidth: 200
        //         implicitHeight: 4

        //         width: progressBar.availableWidth
        //         height: implicitHeight
        //         radius: 2
        //         color: "transparent"

        //         Rectangle {
        //             width: progressBar.visualPosition * parent.width
        //             height: parent.height
        //             color: rgb(33,139,188)
        //             radius: 2
        //         }
        //     }

        //     handle: Rectangle {
        //         x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
        //         y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
        //         implicitWidth: 10
        //         implicitHeight: 17
        //         radius: 2
        //         color: progressBar.pressed ? "#f0f0f0" : "#f6f6f6"
        //         border.color: "#bdbebf"
        //     }

        //     Timer {
        //         interval: 350
        //         running: video.isPlaying
        //         repeat: true
        //         onTriggered: {
        //             progressBar.value = video.position
        //             playHistory.setEpPos(epIndex, video.position)
        //         }
        //     }
        // }

        Rectangle {
            id: footerBtnRec
            height: 30
            width: root.width
            anchors.bottom: videoFooter.bottom
            color: "transparent"

            RowLayout {
                anchors.fill: footerBtnRec
                anchors.leftMargin: parent.height * 0.65
                anchors.rightMargin: parent.height * 0.65
                anchors.bottomMargin: 10
                spacing: 10

                IconButton {
                    id: lastEpBtn
                    Layout.preferredWidth: parent.height
                    Layout.preferredHeight: parent.height
                    Layout.maximumHeight: parent.height * 1.2
                    Layout.maximumWidth: parent.height * 1.2
                    width: height
                    scale: 0.8
                    icon: "qrc:/resources/icons/last.png"
                    visible: root.epList.epIndex === 0 ? false : true
                    onClicked: function (mouse) {
                        root.epList.epIndex -= 1
                    }
                }

                IconButton {
                    id: playBtn
                    Layout.preferredWidth: parent.height
                    Layout.preferredHeight: parent.height
                    Layout.maximumHeight: parent.height * 1.2
                    Layout.maximumWidth: parent.height * 1.2
                    checked: root.video.isPlaying
                    hoveredScale: 1.4
                    icon: "qrc:/resources/icons/play.png"
                    iconChecked: "qrc:/resources/icons/pause.png"
                    onClicked: function (mouse) {
                        root.video.playStateChanged()
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
                    visible: root.epList.epIndex === root.finalEpIndex ? false : true
                    onClicked: {
                        root.epList.epIndex += 1
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
                        font.pixelSize: root.videoArea.isFullScreen ? 15 : 12
                        color: "white"
                        anchors.centerIn: parent
                        text: Utils.formattedVideoDuration(root.video.position) + "  /  " + Utils.formattedVideoDuration(root.video.duration)
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: parent.height
                    color: "white"
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
                    checked: root.videoArea.isFullScreen
                    onClicked: function (mouse) {
                        root.videoArea.isFullScreen = !root.videoArea.isFullScreen
                    }
                }
            }
        }
    }
}

