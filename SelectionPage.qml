import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    Rectangle {
        id: uartRectangle
        width: parent.width/2
        height: parent.height
        color: "dodgerblue"
        anchors {
            top: parent.top
            left: parent.left
        }
        Text {
            id: uartText
            anchors.centerIn: parent
            font.pointSize: 36
            font.bold: true
            text: "UART"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: stackView.push("UART.qml")
        }
    }

    Rectangle {
        id: canRectangle
        width: parent.width/2
        height: parent.height
        color: "yellowgreen"
        anchors {
            top: parent.top
            right: parent.right
        }
        Text {
            id: canText
            anchors.centerIn: parent
            font.pointSize: 36
            font.bold: true
            text: "CAN"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: stackView.push("CAN.qml")
        }
    }
}
