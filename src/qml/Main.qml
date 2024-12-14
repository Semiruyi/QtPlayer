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
    width: 2200 / 2 - 50
    height: 1080 / 2
    color: "black"

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
                    easing.type: Easing.InOutQuad
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
                    easing.type: Easing.InOutQuad
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
                        var playFolderPaths = qMainPageConfig.playFolderPaths
                        playFolderPaths.push(newFolderPath)
                        qMainPageConfig.setPlayFolderPaths(playFolderPaths)
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
                color: "gray"
            }

            MyGridView {
                id: myGridView
                height: parent.height
                width: Math.floor(parent.width / cellWidth) * cellWidth
                anchors.horizontalCenter: parent.horizontalCenter
                model: qMainPageConfig.playFolderPaths
                cellWidth: 200 * 1.618
                cellHeight: 200
                delegate: MyCardView {
                    width: 200 * 1.618 * 0.9
                    height: 200 * 0.9
                    onLeftClicked: {
                        stack.push("PlayPage/PlayPage.qml", {
                                       folderUrl: modelData,
                                       parentValue: root
                                   })
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
                Button {
                    text: "remove"
                    onClicked: {
                    }
                }
            }
        }
    }

}
