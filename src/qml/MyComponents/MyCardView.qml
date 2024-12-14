import QtQuick
import QtQuick.Effects
import QtQuick.Controls 2.15
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: "孤独摇滚"
    property double titleRatio: 0.5
    property string text: "total: 12   watched: 4"
    property string textRatio: 1 - titleRatio
    property string imageSource: "qrc:/resources/icons/atrly.png"
    property double textContentHeightRatio: 0.5
    signal leftClicked()
    signal rightClicked()

    radius: 10
    width: 200 * 1.618
    height: 200
    clip: true

    color: "transparent"

    Rectangle {
        id: gradSrc
        width: img.width
        height: img.height
        gradient: Gradient {
            GradientStop { position: 0; color: "black" }
            GradientStop { position: 1; color: "transparent" }
        }
        radius: root.radius
        layer.enabled: true
        visible: false
    }

    Rectangle {
        id: radSrc
        anchors.fill: img
        radius: root.radius
        layer.enabled: true
        visible: false
    }

    Image {
        id: img
        sourceSize {
            height: 2160
        }
        anchors.fill: parent
        anchors.top: parent.top
        anchors.left: parent.left
        smooth: true
        mipmap: true
        source: root.imageSource
        visible: false
        fillMode: Image.PreserveAspectCrop
    }

    MultiEffect {
        source: img
        anchors.fill: img
        maskEnabled: true
        maskSource: radSrc
    }

    MultiEffect {
        id: blurEffect
        source: img
        anchors.fill: img
        blurEnabled: true
        blur: 1.0                // 模糊度
        brightness: -0.1
        maskEnabled: true
        maskSource: gradSrc
        maskThresholdMax: mainMouseArea.containsMouse ? root.textContentHeightRatio : 0     // 模糊范围
        maskSpreadAtMax: 0.05   // 模糊边界过渡范围
        Behavior on maskThresholdMax {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: mainMouseArea
        anchors.fill: img
        hoverEnabled: true
        anchors.left: img.left
        anchors.bottom: img.bottom

        onClicked:function handleMousePress(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.leftClicked()
            }
        }
    }

    Rectangle {
        id: titleRec
        width: parent.width
        height: root.textRatio * root.textContentHeightRatio * root.height
        color: "transparent"
        y: (1 - blurEffect.maskThresholdMax) * root.height

        // 标题文本
        Text {
            id: titleText
            text: root.title
            font.pixelSize: 25
            font.bold: true
            color: "white"
            anchors.centerIn: parent
        }
    }

    Rectangle {
        id: textRec
        anchors.top: titleRec.bottom
        width: parent.width
        height: root.textRatio * root.textContentHeightRatio * root.height

        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" } // 渐变开始颜色
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.3) } // 渐变结束颜色
        }

        // radius: root.radius
        Text {
            text: root.text
            font.pixelSize: 15
            font.weight: Font.DemiBold
            height: parent.height * 0.95
            width: parent.width * 0.8
            color: "white"
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter // 水平居中
            verticalAlignment: Text.AlignVCenter   // 垂直居中
        }
    }

    // debug only
    // ColumnLayout {
    //     anchors.top: img.bottom
    //     spacing: 10
    //     Slider {
    //         implicitWidth: 300
    //         from: 0
    //         value: 0.1
    //         to: 1
    //         onMoved: {
    //             console.log("maskThresholdMax", value)
    //             blurEffect.maskThresholdMax = value
    //         }
    //     }
    //     Slider {
    //         implicitWidth: 300
    //         from: 0
    //         value: 0.1
    //         to: 1
    //         onMoved: {
    //             console.log("maskSpreadAtMax", value)
    //             blurEffect.maskSpreadAtMax = value
    //         }
    //     }
    //     Slider {
    //         implicitWidth: 300
    //         from: 0
    //         value: 0.1
    //         to: 1
    //         onMoved: {
    //             console.log("blur", value)
    //             blurEffect.blur = value
    //         }
    //     }
    // }
}
