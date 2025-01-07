import QtQuick
import Qt.labs.folderlistmodel
import QtQuick.Controls
import "../MyComponents"
import "utils.js" as Utils

Item {
    id: root

    property url folderUrl
    property VideoBody video
    property int epIndex: qMainPageConfig.playCardModel.getData(root.cardIndex, "lastPlayedEpisode")
    property int lastEpIndex: qMainPageConfig.playCardModel.getData(root.cardIndex, "lastPlayedEpisode")
    property int cardIndex: 0
    property var videoFilePathList: qUtilities.getVideoFiles(folderUrl)

    property bool isInited: false

    onEpIndexChanged: {
        if(!root.isInited) {
            return
        }

        video.epIndex = epIndex
        video.source = videoFilePathList[root.epIndex]
        video.pause()
        epList.itemAtIndex(root.lastEpIndex).btn.state = "watched"
        epList.itemAtIndex(root.epIndex).btn.watched = true
        epList.itemAtIndex(root.epIndex).btn.state = "selected"
        lastEpIndex = epIndex
        qMainPageConfig.playCardModel.setData(root.cardIndex, "lastPlayedEpisode", root.epIndex)
        // console.log(qUtilites.getVideoFiles(folderUrl).length)
    }

    Component.onCompleted: {
        qPlayHistoryConfig.init(folderUrl + "/history.db")
        root.isInited = true
    }

    MyGridView {
        id: epList
        width: parent.width
        height: root.height
        // anchors.fill: parent

        cellWidth: width / 4
        cellHeight: cellWidth
        clip: true
        model: root.videoFilePathList

        ScrollBar.vertical: ScrollBar {       //滚动条
            anchors.right: epList.right
            width: 10
            active: true
            background: Item {            //滚动条的背景样式
                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                }
            }

            contentItem: Rectangle {
                radius: qGlobalConfig.radius
                color: 'gray'
            }
        }


        delegate: Rectangle {
            width: epList.cellWidth
            height: epList.cellHeight
            color: Utils.rgb(31,34,35)
            property Rectangle btn: epBtn
            Rectangle {
                id: epBtn
                property bool watched: false
                width: 50
                height: 50
                anchors.centerIn: parent
                radius: qGlobalConfig.radius
                color: Utils.rgb(10, 10, 10)
                Component.onCompleted: {
                    qPlayHistoryConfig.init(folderUrl + "/history.db")
                    if(qPlayHistoryConfig.isWatched(index)) {
                        epBtn.watched = true;
                        epBtn.state = "watched"
                    }

                    if(index === root.epIndex) {
                        epBtn.state = "selected"
                        epBtn.watched = true
                        root.video.source = modelData
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    color: "white"//rgb(208,204,198)
                    font.pixelSize: 15
                }

                states: [
                    State {
                        name: "watched"
                        PropertyChanges {
                            target: epBtn
                            color: Utils.rgb(70,70,70)
                            scale: 1.0
                        }
                    },
                    State {
                        name: "selected";
                        PropertyChanges {
                            target: epBtn
                            color: "lightSkyBlue"
                            scale: 1.05
                        }
                    },
                    State {
                        name: "focus"
                        PropertyChanges {
                            target: epBtn
                            color: "steelBlue"
                            scale: 1.05
                        }
                    },
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: epBtn
                            color: Utils.rgb(10, 10, 10)
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
                            easing.type: Easing.OutCubic
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
                        if(index === root.epIndex) {
                            epBtn.state = "selected"
                            return
                        }
                        root.epIndex = index
                    }

                    onEntered: {
                        if(epBtn.state === "selected") return
                        epBtn.state = "focus"
                    }
                    onExited: {
                        // console.log("test", index)
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
}
