import QtQuick 2.12
import QtQuick.Controls

Menu {
    id: root
    // popupType: Popup.Window
    transformOrigin: Popup.TopLeft

    property bool popupEnable: true
    property int animationDuration: qGlobalConfig.animationDuration

    // background: Rectangle {
    //     color: "black"
    // }

    onClosed: {
        root.popupEnable = true
    }


    enter: Transition {
        NumberAnimation { properties: "scale, opacity"; from: 0.0; to: 1.0; duration: root.animationDuration; easing.type: Easing.OutCubic }

    }

    // 关闭菜单时的动画
    exit: Transition {
        NumberAnimation { properties: "scale, opacity"; from: 1.0; to: 0.0; duration: root.animationDuration; easing.type: Easing.OutCubic }
    }
}
