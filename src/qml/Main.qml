// pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import "./MyComponents"
import "./PlayPage"

Window  {
    visible: true
    id: root
    width: 1200 / 2 * 2.197324414715719
    height: 1200 / 2
    color: "#1f2223"

    property int animationDuration: qGlobalConfig.animationDuration

    signal refresh()

    function back() {
        stack.pop()
        root.refresh()
    }

    MyStackView {
        id: stack
        animationDuration: root.animationDuration
        anchors.fill: parent
        initialItem: mainViewComponet
    }

    NotificationView {
        id: notificationView
        height: parent.height * 0.7
        width: parent.width * 0.5
        y: parent.height * 0.03
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.8
    }

    Component {
        id: mainViewComponet
        Rectangle {
            id: mainView
            color: "transparent"
            width: root.width
            height: root.height
            // scale: 0.95

            FolderDialog {
                id: folderDialog
                currentFolder: qMainPageConfig.lastOpenedFolder
                onAccepted: {
                    if (selectedFolder !== undefined && selectedFolder !== "") {
                        var newFolderPath = selectedFolder.toString()
                        var title = newFolderPath.replace(/^.*[\\/]/, '')
                        qMainPageConfig.playCardModel.append({
                                                                "animationTitle": title,
                                                                "path" : newFolderPath,
                                                                "lastPlayedEpisode" : 0,
                                                                "coverPosition": 10
                                                             })
                        var info = qsTr("Add play folder success")
                        notificationView.addNotification(info, NotificationView.Info)
                        var lastOpenedFolder = newFolderPath.split("/");
                        lastOpenedFolder.pop();
                        lastOpenedFolder = lastOpenedFolder.join("/");
                        qMainPageConfig.lastOpenedFolder = lastOpenedFolder
                    } else{
                        console.log("Error on user selecting folder")
                    }
                }
                onRejected: {
                    console.log("Canceled")
                }
            }

            Rectangle {
                anchors.fill: myGridView
                color: "transparent"
            }

            MyGridView {
                id: myGridView
                flow: GridView.FlowLeftToRight
                height: parent.height
                width: (Math.floor(parent.width / cellWidth) < 0.01 ? 1 : Math.floor(parent.width / cellWidth)) * cellWidth
                anchors.horizontalCenter: parent.horizontalCenter
                model: qMainPageConfig.playCardModel
                cellWidth: 200 * 1.618
                cellHeight: 200
                animationDuration: qGlobalConfig.animationDuration
                delegate: Rectangle {

                    property int watchedCount: 0

                    width: myGridView.cellWidth
                    height: myGridView.cellHeight
                    color: "transparent"
                    MyMenu {
                        id: cardMenu
                        MenuItem {
                            text: qsTr("remove")
                            onTriggered: {
                                qMainPageConfig.playCardModel.remove(index)
                            }
                        }
                        MenuItem {
                            text: qsTr("change cover")
                            onTriggered: {
                                var position = Math.floor(Math.random() * 600) + 1
                                var source = qVideoProcesser.qmlGetFrame(path, position, true)
                                if(source == "")
                                {
                                    var errMsg = animationTitle +  qsTr(" cover load faild!")
                                    notificationView.addNotification(errMsg, NotificationView.Error)
                                    return ;
                                }
                                qCoverImageProvider.removeImage(cardView.imageSource)

                                qMainPageConfig.playCardModel.setData(index, "coverPosition", position)

                                cardView.imageSource = source
                            }
                        }
                        MenuItem {
                            text: qsTr("move to first")
                            onTriggered: {
                                qMainPageConfig.playCardModel.move(index, 0)
                            }
                        }
                        onOpenedChanged: {
                            if(!cardMenu.opened)
                            {
                                cardView.allwaysDisplayTextContent = false
                            }
                        }
                    }

                    MyCardView {
                        id: cardView
                        property int watchedCount: qMainPageConfig.getWatchedCount(path + "/history.db")
                        property int totalVideoCount: qUtilities.getVideoFiles(path).length
                        title: animationTitle
                        width: 200 * 1.618 * 0.9
                        height: 200 * 0.9
                        text: qsTr("total: ") + cardView.totalVideoCount + "      " + qsTr("watched: ") + cardView.watchedCount
                        anchors.centerIn: parent
                        onLeftClicked: {
                            if(!qUtilities.checkFolderPathIsValid(path))
                            {
                                var errMsg = qsTr("Can not find this folder, maybe it has be moved or renamed")
                                notificationView.addNotification(errMsg, NotificationView.Error)
                                return
                            }

                            stack.push(playPage)
                        }
                        onRightClicked: {
                            if(cardMenu.popupEnable)
                            {
                                cardMenu.popupEnable = false
                                cardMenu.popup()
                                cardView.allwaysDisplayTextContent = true
                            }
                        }

                        Component.onCompleted: {
                            var source = qVideoProcesser.qmlGetFrame(path, coverPosition, true)
                            console.log("source is ", source)
                            if(source == "")
                            {
                                var errMsg = animationTitle +  qsTr(" Cover loading failed")
                                notificationView.addNotification(errMsg, NotificationView.Error)
                                return ;
                            }

                            cardView.imageSource = source

                            if(path == qMainPageConfig.appStartWithPath) {
                                if(!qUtilities.checkFolderPathIsValid(path))
                                {
                                    qMainPageConfig.appStartWithPath = ""
                                    var errMsg = qsTr("Can not find this folder, maybe it has be moved or renamed")
                                    notificationView.addNotification(errMsg, NotificationView.Error)
                                    return
                                }

                                delayEnterPlayPageTimer.start()
                            }
                        }

                        Timer {
                            id: delayEnterPlayPageTimer
                            interval: 600
                            onTriggered: {
                                stack.push(playPage)
                            }
                        }

                        Component {
                            id: playPage
                            PlayPage {
                                folderUrl: path
                                parentValue: root
                                epIndex: lastPlayedEpisode
                                cardIndex: index
                            }
                        }

                        Connections {
                            target: root
                            function onRefresh() {
                                cardView.text = qsTr("total: ") + cardView.totalVideoCount + "      " + qsTr("watched: ") + qMainPageConfig.getWatchedCount(path + "/history.db")
                            }
                        }
                    }
                }
            }

            RowLayout {
                anchors.bottom: mainView.bottom
                anchors.horizontalCenter: mainView.horizontalCenter
                anchors.bottomMargin: 40
                IconButton {
                    implicitWidth: 50
                    implicitHeight: 50
                    icon: "qrc:/resources/icons/plus.png"
                    onClicked: {
                        folderDialog.visible = true
                    }
                }
                // Button {
                //     text: "test"
                //     onClicked: {
                //         qGlobalConfig.language = "chinese"
                //         console.log(qGlobalConfig.language)
                //     }
                // }
            }
        }
    }

}
