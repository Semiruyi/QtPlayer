import QtQuick
import QtQuick.Layouts
import "utils.js" as Utils

Item {
    id: root
    clip: true
    property VideoBody video
    property Rectangle videoArea
    property EpisodeList episodeList
    property int finalEpIndex
    property bool containMouse: lastEpBtn.hovered || playBtn.hovered || nextEpBtn.hovered || speedMessage.hovered || fullScreenBtn.hovered || progressBar.containMouse


    Rectangle {
        id: videoFooter
        anchors.fill: root
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#A0000000" }
        }

        transitions: Transition {
            AnchorAnimation { duration: 200; easing.type: Easing.InOutQuad}
        }

        ProgressBar {
            id: progressBar
            video: root.video
            episodeList: root.episodeList
            width: root.width
            height: root.height - footerBtnRec.height

        }

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
                    visible: root.episodeList.epIndex === 0 ? false : true
                    onClicked: function (mouse) {
                        root.episodeList.epIndex -= 1
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
                    visible: root.episodeList.epIndex === root.finalEpIndex ? false : true
                    onClicked: {
                        root.episodeList.epIndex += 1
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
                    checked: root.videoArea.isFullScreen
                    onClicked: function (mouse) {
                        root.videoArea.isFullScreen = !root.videoArea.isFullScreen
                    }
                }
            }
        }
    }
}

