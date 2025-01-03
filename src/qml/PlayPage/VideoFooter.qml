import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../MyComponents"
import "utils.js" as Utils

Item {
    id: root
    clip: true
    property VideoBody video
    property var videoArea
    property EpisodeList episodeList
    property int finalEpIndex
    property bool containMouse: lastEpBtn.hovered || playBtn.hovered || nextEpBtn.hovered || speedMessage.hovered || fullScreenBtn.hovered || progressBar.containMouse
    signal progressBarReleased()

    Rectangle {
        id: videoFooter
        anchors.fill: root
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#A0000000" }
        }

        VideoProgressBar {
            id: progressBar
            video: root.video
            episodeList: root.episodeList
            width: root.width * 0.97
            height: root.height - footerBtnRec.height
            anchors.horizontalCenter: parent.horizontalCenter
            onReleased: {
                root.progressBarReleased()
            }
        }

        Rectangle {
            id: footerBtnRec
            height: 50
            width: root.width
            anchors.bottom: videoFooter.bottom
            color: "transparent"

            RowLayout {
                id: footerRowLayout
                anchors.fill: footerBtnRec
                anchors.leftMargin: parent.height * 0.5 + parent.width * 0.01
                anchors.rightMargin: parent.height * 0.5 + parent.width * 0.01
                anchors.bottomMargin: 10
                spacing: 15
                property int itemImplicitWidth: 20

                IconButton {
                    id: lastEpBtn
                    implicitWidth: footerRowLayout.itemImplicitWidth
                    implicitHeight: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    icon: "qrc:/resources/icons/last.png"
                    visible: root.episodeList.epIndex === 0 ? false : true
                    onClicked: function (mouse) {
                        root.episodeList.epIndex -= 1
                    }
                }

                IconButton {
                    id: playBtn
                    implicitWidth: footerRowLayout.itemImplicitWidth + 6
                    implicitHeight: footerRowLayout.itemImplicitWidth + 6
                    Layout.alignment: Qt.AlignVCenter
                    checked: root.video.isPlaying
                    icon: "qrc:/resources/icons/play.png"
                    iconChecked: "qrc:/resources/icons/pause.png"
                    onClicked: function (mouse) {
                        root.video.playStateChanged()
                    }
                }

                IconButton {
                    id: nextEpBtn
                    implicitWidth: footerRowLayout.itemImplicitWidth
                    implicitHeight: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    icon: "qrc:/resources/icons/next.png"
                    visible: root.episodeList.epIndex === root.finalEpIndex ? false : true
                    onClicked: {
                        root.episodeList.epIndex += 1
                    }
                }

                Rectangle {
                    implicitWidth: 5
                    color: "transparent"
                }

                Text {
                    id: videoProgressMessage
                    font.pixelSize: root.videoArea.isFullScreen ? 15 : 12
                    color: "white"
                    // anchors.centerIn: parent
                    text: Utils.formattedVideoDuration(root.video.position) + "  /  " + Utils.formattedVideoDuration(root.video.duration)
                }

                Rectangle {
                    Layout.fillWidth: true
                    color: "transparent"
                }

                IconButton {
                    id: speedMessage

                    implicitWidth: footerRowLayout.itemImplicitWidth
                    implicitHeight: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
                    textColor: "white"
                    text: "1.0x"
                    fontBold: true
                    onClicked: {
                        if(speedMessage.text == "1.0x") {
                            speedMessage.text = "1.25x"
                            root.video.playBackRate = 1.25
                        }
                        else if(speedMessage.text == "1.25x") {
                            speedMessage.text = "1.5x"
                            root.video.playBackRate = 1.5
                        }
                        else {
                            speedMessage.text = "1.0x"
                            root.video.playBackRate = 1.0
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 10
                    color: "transparent"
                }

                IconButton {
                    id: fullScreenBtn
                    implicitWidth: footerRowLayout.itemImplicitWidth
                    implicitHeight: implicitWidth
                    Layout.alignment: Qt.AlignVCenter
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

