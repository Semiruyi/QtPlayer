// pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import "./MyComponents"

Window  {
    visible: true
    id: root
    width: 1200 / 2 * 2.197324414715719
    height: 1200 / 2
    color: "#1f2223"

    function back() {
        stack.pop()
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

            function appendData(pathData, titleData) {
                gridViewModel.append({
                    animationTitle: titleData,
                    path: pathData
                })
            }

            FolderDialog {
                id: folderDialog

                onAccepted: {
                    if (selectedFolder !== undefined && selectedFolder !== "") {
                        var newFolderPath = selectedFolder.toString()
                        var title = newFolderPath.replace(/^.*[\\/]/, '')
                        mainView.appendData(newFolderPath, title)
                        qMainPageConfig.appendData(newFolderPath, title)
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

            ListModel {
                id: gridViewModel
                Component.onCompleted: {
                    for(var i = 0; i < qMainPageConfig.playFolderPaths.length; i++) {
                        mainView.appendData(qMainPageConfig.playFolderPaths[i], qMainPageConfig.titles[i])
                    }
                }
            }

            MyGridView {
                id: myGridView
                height: parent.height
                width: (Math.floor(parent.width / cellWidth) < 0.01 ? 1 : Math.floor(parent.width / cellWidth)) * cellWidth
                anchors.horizontalCenter: parent.horizontalCenter
                model: gridViewModel
                cellWidth: 200 * 1.618
                cellHeight: 200
                delegate: Rectangle {
                    width: myGridView.cellWidth
                    height: myGridView.cellHeight
                    color: "transparent"
                    MyMenu {
                        id: cardMenu
                        MenuItem {
                            text: "remove"
                            onTriggered: {
                                qMainPageConfig.removeData(index)
                                gridViewModel.remove(index)
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
                        anchors.centerIn: parent
                        onLeftDoubleClicked: {
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
