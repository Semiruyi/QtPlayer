import QtQuick
import QtQuick.Layouts
import "../MyComponents"

Rectangle {
    id: root

    property bool containsMouse: backBtn.hovered
    property string fileName: ""
    signal backBtnClicked()

    height: 30
    width: 500
    color: "transparent"
    RowLayout {
        id: layout

        property int itemImplicitWidth: 20

        anchors.fill: parent
        anchors.leftMargin: parent.height * 0.4 + parent.width * 0.01
        anchors.rightMargin: parent.height * 0.4 + parent.width * 0.01
        anchors.topMargin: 10
        spacing: 10

        IconButton {
            id: backBtn
            implicitWidth: layout.itemImplicitWidth
            implicitHeight: implicitWidth
            Layout.alignment: Qt.AlignVCenter
            icon: "qrc:/resources/icons/back.png"
            onClicked: function (mouse) {
                root.backBtnClicked()
            }
        }

        Text {
            text: root.fileName
            color: "white"
            font.pixelSize: 15
        }
    }
}
