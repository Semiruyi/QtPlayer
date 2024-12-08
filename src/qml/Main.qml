import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import "./PlayPage"

Window  {
    visible: true
    id: root
    width: 2200 / 2
    height: 1080 / 2

    function back() {
        stack.pop()
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: mainView
    }

    Rectangle {
        id: mainView
        // color: "black"
        FolderDialog {
            id: folderDialog

            onAccepted: {
                if (selectedFolder !== undefined && selectedFolder !== "") {
                    // animeList.insert(0, { "folderUrl": selectedFolder.toString() })
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

        ListView {
            anchors.fill: parent
            model: qMainPageConfig.playFolderPaths
            delegate: Button {
                text: modelData
                height: 100

                onClicked: {
                    stack.push("PlayPage/PlayPage.qml", {
                                   folderUrl: modelData,
                                   parentValue: root
                               })
                }
            }
        }

        Button {
            text: "Add"
            // width: parent.width
            // height: parent.height * 0.2
            anchors.bottom: mainView.bottom
            anchors.horizontalCenter: mainView.horizontalCenter
            anchors.bottomMargin: 20
            onClicked: {
                folderDialog.visible = true;
            }
        }
    }


}
