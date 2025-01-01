pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects

Rectangle {
    id: root
    property string source: ""
    property var fillMode: Image.PreserveAspectCrop
    property bool smooth: true
    property bool mipmap: true
    property int nowIndex: 1

    color: "transparent"

    onSourceChanged: {
        if(source == "") {
            return
        }
        stackView.replaceCurrentItem(img, {"source": root.source})
    }

    MyStackView {
        anchors.fill: root
        id: stackView
    }
    Component {
        id: img
        Image {
            height: root.height
            width: root.width
            fillMode: root.fillMode
            smooth: root.smooth
            mipmap: root.mipmap
        }
    }
}
