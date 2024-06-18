import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtMultimedia
import Qt.labs.folderlistmodel
import "PlayPage" as PlayPage

Window  {
    visible: true
    id: root
    width: 2200 / 2
    height: 1080 / 2

    function back() {
        stack.pop()
    }

    property StackView stack: stack

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: mainView
    }

    Item {
        id: mainView
        FolderDialog {
            id: folderDialog

            onAccepted: {
                if (selectedFolder !== undefined && selectedFolder !== "") {
                    //console.log("folderDialog select: ", selectedFolder)
                    animeList.insert(0, { "folderUrl":selectedFolder })
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
            model: ListModel {
                id: animeList
                ListElement {
                    folderUrl: "file:///C:/Users/wyy/Videos/bocchi the rock"
                }
            }
            spacing: 10
            delegate: Button {
                text: folderUrl
                height: 100
                onClicked: {
                    // console.log(folderUrl)
                    stack.push("PlayPage/PlayPage-New.qml", {
                                   folderUrl: folderUrl,
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
