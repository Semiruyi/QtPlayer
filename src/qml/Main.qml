// pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import "./MyComponents"

Window  {
    visible: true
    id: root
    width: 1200 / 2 * 2.197324414715719
    height: 1200 / 2
    color: "#1f2223"

    signal refresh()

    function back() {
        stack.pop()
        root.refresh()
    }

    StackView {
        id: stack
        property int animationDuration: qGlobalConfig.animationDuration
        anchors.fill: parent
        initialItem: mainViewComponet
        pushEnter: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: stack.width
                    to: 0
                    duration: stack.animationDuration
                    easing.type: Easing.OutCubic
                }

                PropertyAnimation {
                    property: "scale"
                    from: 0.5
                    to: 1.0
                    duration: stack.animationDuration
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.5
                    to: 1.0
                    duration: stack.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }


        pushExit: Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: -stack.width
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        popEnter: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "x"
                    from: -stack.width
                    to: 0
                    duration: stack.animationDuration
                    easing.type: Easing.OutCubic
                }

                PropertyAnimation {
                    property: "scale"
                    from: 1.5
                    to: 1.0
                    duration: stack.animationDuration
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    property: "opacity"
                    from: 0.5
                    to: 1.0
                    duration: stack.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // 自定义 popExit 动画
        popExit: Transition {
            PropertyAnimation {
                property: "x"
                from: 0
                to: stack.width
                duration: stack.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Component {
        id: mainViewComponet
        Rectangle {
            id: mainView
            color: "transparent"

            FolderDialog {
                id: folderDialog

                onAccepted: {
                    if (selectedFolder !== undefined && selectedFolder !== "") {
                        var newFolderPath = selectedFolder.toString()
                        var title = newFolderPath.replace(/^.*[\\/]/, '')
                        qMainPageConfig.playCardModel.append({
                                                                "animationTitle": title,
                                                                "path" : newFolderPath
                                                             })
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
                height: parent.height
                width: (Math.floor(parent.width / cellWidth) < 0.01 ? 1 : Math.floor(parent.width / cellWidth)) * cellWidth
                anchors.horizontalCenter: parent.horizontalCenter
                model: qMainPageConfig.playCardModel
                cellWidth: 200 * 1.618
                cellHeight: 200
                delegate: Rectangle {

                    property int watchedCount: 0

                    width: myGridView.cellWidth
                    height: myGridView.cellHeight
                    color: "transparent"
                    MyMenu {
                        id: cardMenu
                        MenuItem {
                            text: "remove"
                            onTriggered: {
                                qMainPageConfig.playCardModel.remove(index)
                            }
                        }
                        MenuItem {
                            text: "Item 2"
                        }
                        MenuItem {
                            text: "Item 3"
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

                        title: animationTitle
                        width: 200 * 1.618 * 0.9
                        height: 200 * 0.9
                        text: qsTr("total: ") + folderModel.count + "      " + qsTr("watched: ") + qMainPageConfig.getWatchedCount(path + "/history.db")
                        anchors.centerIn: parent
                        onLeftClicked: {
                            stack.push("PlayPage/PlayPage.qml", {
                                           folderUrl: path,
                                           parentValue: root
                                       })
                        }
                        onRightClicked: {
                            if(cardMenu.popupEnable)
                            {
                                cardMenu.popupEnable = false
                                cardMenu.popup()
                                cardView.allwaysDisplayTextContent = true
                            }
                        }

                        Connections {
                            target: root
                            function onRefresh() {
                                cardView.text = qsTr("total: ") + folderModel.count + "      " + qsTr("watched: ") + qMainPageConfig.getWatchedCount(path + "/history.db")
                            }
                        }

                        FolderListModel {
                            id: folderModel
                            folder: path
                            nameFilters: ["*.mp4", "*.mkv"]
                            showDirs: false
                        }
                    }
                }
            }

            RowLayout {
                anchors.bottom: mainView.bottom
                anchors.horizontalCenter: mainView.horizontalCenter
                anchors.bottomMargin: 20
                Button {
                    text: "Add"
                    onClicked: {
                        folderDialog.visible = true
                    }
                }
            }
        }
    }

}
