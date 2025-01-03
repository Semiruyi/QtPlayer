import QtQuick 2.12

Rectangle {
    id: root
    radius: 10
    color: "transparent"
    clip: true

    property int autoDeleteNotificationInterval: 3000
    property bool containsMouse: false

    enum NotificationType {
        Info,
        Success,
        Fail,
        Error
    }

    function addNotification(message, type) {
        listModel.insert(0, {"message" : message})
        autoDeleteTimer.restart()
    }

    ListModel {
        id: listModel
    }

    // Rectangle {
    //     anchors.fill: listView
    //     color: "black"
    // }

    MyListView {
        id: listView
        width: root.width
        height: 0// Math.min(contentHeight, root.height)
        model: listModel
        clip: true

        onContentHeightChanged: {
            if(listView.contentHeight > listView.height) {
                listView.height = Math.min(listView.contentHeight, root.height)
            }
            else {
                heightChangeTimer.start()
            }
        }

        Timer {
            id: heightChangeTimer
            interval: listView.animationDuration + 100
            onTriggered: {
                listView.height = Math.min(listView.contentHeight, root.height)
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: listView.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        delegate: Rectangle {// just a wraper
            id: textWraperRec
            width: root.width
            height: messageRec.height * 1.2
            color: "transparent"
            radius: root.radius

            Rectangle {
                id: messageRec
                width: parent.width * 0.9
                height: multiLineText.implicitHeight + multiLineText.font.pixelSize
                color: "white"
                radius: root.radius
                anchors.centerIn: parent

                Text {
                    anchors.centerIn: parent
                    id: multiLineText
                    width: parent.width * 0.9
                    text: message
                    font.family: "Microsoft YaHei"
                    wrapMode: Text.Wrap
                    font.pixelSize: 18
                    lineHeight: 1.5
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onContainsMouseChanged: {
                        root.containsMouse = containsMouse
                    }
                    acceptedButtons: Qt.RightButton | Qt.LeftButton

                    onClicked: function (mouse) {
                        if(index < 0 || index >= listModel.count) {
                            return
                        }

                        if (mouse.button === Qt.RightButton) {
                            listModel.clear()
                        }
                        else
                        {
                            listModel.remove(index)
                            autoDeleteTimer.restart()
                        }
                    }
                }
            }
        }
    }



    Timer {
        id: autoDeleteTimer
        running: listModel.count > 0 && !root.containsMouse ? true : false
        repeat: true
        interval: root.autoDeleteNotificationInterval
        onTriggered: {
            if(listModel.count > 0) {
                listModel.remove(0)
            }
        }
    }


}
