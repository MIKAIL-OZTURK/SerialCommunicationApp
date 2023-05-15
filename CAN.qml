import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SocketCan 1.0

Item {
    id: root
    SocketCan {
        id: socketCan
        onDataReceived: {
            console.log("Received data: " + message);
            readMessageInput.text = readMessageInput.text + "\n" + message
        }
    }

    //Window
    Rectangle {
        id: windowRectangle
        anchors.fill: parent
        color: "yellowgreen"

        Row {
            spacing: 40
            anchors.centerIn: parent

            //Column1: Connection Area
            Column {
                id: connectionColumn

                Rectangle {
                    id: firstRectangle
                    width: 380
                    height: 380
                    color: "white"
                    border {
                        width: 4
                        color: defaultRectangleBorderColor
                    }
                    radius: 5
                    Label {
                        text: "Can Type"
                        font {
                            pointSize: 20
                            bold: true
                        }
                        anchors {
                            bottom: frame.top
                            bottomMargin: 40
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                    }
                    Frame {
                        id: frame
                        anchors.centerIn: firstRectangle
                        ColumnLayout {
                            spacing: 20
                            RadioButton {
                                checked: true
                                text: qsTr("vcan0")
                            }
                            RadioButton {
                                text: qsTr("vcan1")
                            }
                        }
                    }
                    Row {
                        spacing: 10
                        anchors {
                            top: frame.bottom
                            topMargin: 40
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Button {
                            id: connectButton
                            text: "Connect"
                            onClicked:  {
                                socketCan.connectSocket()
                                firstRectangle.border.color = activeRectangleBorderColor
                                console.log("Connection Successful")
                            }
                        }
                        Button {
                            id: disconnectButton
                            text: "Disconnect"
                            onClicked: {
                                socketCan.disconnectSocket()
                                resetRectanglesBorderColor()
                                console.log("Disconnection Successful")
                            }
                        }
                    }
                }
            }

            //Column2: Transmit Message Area
            Column {
                Rectangle {
                    id: secondRectangle
                    width: 380
                    height: 380
                    color: "white"
                    border {
                        width: 4
                        color: defaultRectangleBorderColor
                    }
                    radius: 5
                    Row {
                        id: rowID
                        spacing: 50
                        anchors {
                            top: secondRectangle.top
                            topMargin: 30
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        Label {
                            id: idLabel
                            font {
                                pointSize: 16
                                bold: true
                            }
                            text: "Frame ID"
                        }
                        TextField {
                            id: idTextField
                            width: 190
                            placeholderText: "Enter ID hex or decimal"
                            onTextChanged: {
                                if(idTextField.text === "555" || idTextField.text === "0x22B") {
                                    console.log("ID Confirmed! Please enter your message in hex format...")
                                    payloadTextField.enabled =  true
                                }
                                else {
                                    console.log("Authentication Failed!")
                                    payloadTextField.enabled = false
                                }
                            }
                        }
                    }
                    Row {
                        id: rowPayload
                        spacing: 10
                        anchors {
                            top: rowID.bottom
                            topMargin: 30
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        Label {
                            id: payloadLabel
                            font {
                                pointSize: 16
                                bold: true
                            }
                            text: "Payload (hex)"
                        }
                        TextField {
                            id: payloadTextField
                            enabled: false
                            width: 190
                            placeholderText: "Please leave a space"
                            onTextChanged: {
                                if (idTextField.text !== "") {
                                    sendButton.enabled = true
                                }
                            }
                        }
                    }
                    Row {
                        id: rowFrameType
                        spacing: 24
                        anchors {
                            top: rowPayload.bottom
                            topMargin: 30
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        Label {
                            id: frameTypeLabel
                            text: "Frame Type"
                            font {
                                pointSize: 16
                                bold: true
                            }
                        }
                        ComboBox {
                            id: frameTypeComboBox
                            width: 190
                            currentIndex: 0
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "Data Frame"; choice: SocketCan.DataFrame }
                                ListElement { text: "Error Frame"; choice: SocketCan.ErrorFrame }
                                ListElement { text: "Remote Request Frame"; choice: SocketCan.RemoteRequestFrame }
                            }
                        }
                    }
                    Row {
                        id: rowFrameOptions
                        spacing: 6
                        anchors {
                            top: rowFrameType.bottom
                            topMargin: 30
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        Label {
                            id: frameOptionsLabel
                            text: "Frame Option"
                            font {
                                pointSize: 16
                                bold: true
                            }
                        }
                        ComboBox {
                            id: frameOptionsComboBox
                            width: 190
                            currentIndex: 0
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "Extended Format" }
                                ListElement { text: "Flexible Data-Rate" }
                            }
                        }
                    }
                    Button {
                        id: sendButton
                        text: "Send"
                        anchors {
                            top: rowFrameOptions.bottom
                            topMargin: 30
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        onClicked: {
                            socketCan.sendData(payloadTextField.text)
                            payloadTextField.clear()
                            secondRectangle.border.color = activeRectangleBorderColor
                        }
                    }
                }
            }

            //Column3: Receive Message Area
            Column {
                Rectangle {
                    id: thirdRectangle
                    width: 380
                    height: 380
                    color: "white"
                    border {
                        width: 4
                        color: defaultRectangleBorderColor
                    }
                    radius: 5
                    Label {
                        id: readMessageLabel
                        font {
                            pointSize: 18
                            bold: true
                        }
                        text: "Read Message"
                        anchors {
                            top: thirdRectangle.top
                            topMargin: 20
                            horizontalCenter: thirdRectangle.horizontalCenter
                        }
                    }
                    Rectangle {
                        id: readMessageBox
                        width: 250
                        height: 250
                        color: "#F5F5F5"
                        border {
                            width: 1
                            color: "#BDBDBD"
                        }
                        radius: 5
                        anchors {
                            top: readMessageLabel.bottom
                            topMargin: 15
                            horizontalCenter: thirdRectangle.horizontalCenter
                        }
                        TextArea {
                            id: readMessageInput
                            anchors.fill: parent
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            onTextChanged: {
                                thirdRectangle.border.color = activeRectangleBorderColor
                            }
                        }
                    }
                    Button {
                        id: readMessageClearButton
                        text: "Clear"
                        anchors {
                            top: readMessageBox.bottom
                            topMargin: 12
                            horizontalCenter: thirdRectangle.horizontalCenter
                        }
                        onClicked:  {
                            readMessageInput.clear()
                        }
                    }
                }
            }
        }
    }

    //BackButton
    Image {
        id: backButton
        width: 64
        height: 64
        source: "qrc:/Images/backButton.png"
        anchors {
            left: parent.left
            leftMargin: 25
            bottom: parent.bottom
            bottomMargin: 25
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (socketCan.deviceState === SocketCan.ConnectedState) {
                    console.log("Please disconnect the app first");
                } else {
                    stackView.pop();
                }
            }
        }
    }

    property string activeRectangleBorderColor: "#3ABE00"           // Green
    default property string defaultRectangleBorderColor: "#EE1C25"  // Red

    function resetRectanglesBorderColor() {
        firstRectangle.border.color = defaultRectangleBorderColor
        secondRectangle.border.color = defaultRectangleBorderColor
        thirdRectangle.border.color = defaultRectangleBorderColor
    }
}
