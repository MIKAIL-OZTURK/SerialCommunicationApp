import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1

Window {
    id: window
    width: 900
    height: 500
    visible: true
    title: qsTr("Serial Communication")

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: "SelectionPage.qml"
    }

    Settings {
        property alias x: window.x
        property alias y: window.y
        property alias width: window.width
        property alias height: window.height
    }
}
