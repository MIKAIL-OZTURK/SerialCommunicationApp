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
            console.log("Received data: ID = " + ID + ", message = " + message);
            readMessageInput.text = ID + " # " + message + "\n";
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
                    Row {
                        id: rowCanType
                        spacing: 50
                        anchors {
                            top: firstRectangle.top
                            topMargin: 40
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            id: canTypeLabel
                            text: "Can Type"
                            font {
                                pointSize: 16
                                bold: true
                            }

                        }
                        TextField {
                            id: selectCanTextField
                            width: 190
                            placeholderText: "Enter CAN type"
                        }
                    }
                    Row {
                        id: rowCanBitRate
                        spacing: 64
                        anchors {
                            top: rowCanType.bottom
                            topMargin: 40
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            id: canBitRateLabel
                            text: "BitRate"
                            font {
                                pointSize: 16
                                bold: true
                            }
                        }
                        ComboBox {
                            id: bitRateComboBox
                            width: 190
                            currentIndex: 1
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                id: bitRateValues
                                ListElement { text: "125";  /* choice: socketCan.BitRate125Kbps */ }
                                ListElement { text: "250";  /* choice: socketCan.BitRate250Kbps */ }
                                ListElement { text: "500";  /* choice: socketCan.BitRate500Kbps */ }
                                ListElement { text: "1000"; /* choice: socketCan.BitRate1000Kbps */ }
                            }
                            onSelectTextByMouseChanged: {
                                socketCan.setBitRate(bitRateValues.get(currentIndex).value);
                            }
                        }
                    }
                    Row {
                        id: rowConnectArea
                        spacing: 15
                        anchors {
                            bottom: firstRectangle.bottom
                            bottomMargin: 50
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Button {
                            id: connectButton
                            text: "Connect"
                            onClicked:  {
                                socketCan.connectSocket()
                                socketCan.bindSocket(selectCanTextField.text, bitRateComboBox.currentText)
                                firstRectangle.border.color = activeRectangleBorderColor
                                secondColumn.enabled = true
                                thirdColumn.enabled = true
                                console.log("Connection Successful")
                            }
                        }
                        Button {
                            id: disconnectButton
                            text: "Disconnect"
                            onClicked: {
                                socketCan.disconnectSocket()
                                resetRectanglesBorderColor()
                                secondColumn.enabled = false
                                thirdColumn.enabled = false
                                console.log("Disconnection Successful")
                            }
                        }
                    }
                }
            }

            //Column2: Transmit Message Area
            Column {
                id: secondColumn
                enabled: false
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
                            topMargin: 40
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
                        }
                    }
                    Row {
                        id: rowPayload
                        spacing: 60
                        anchors {
                            top: rowID.bottom
                            topMargin: 40
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        Label {
                            id: payloadLabel
                            font {
                                pointSize: 16
                                bold: true
                            }
                            text: "Payload"
                        }
                        TextField {
                            id: payloadTextField
                            width: 190
                            placeholderText: "Please leave a space"
                        }
                    }
                    Button {
                        id: sendButton
                        text: "Send"
                        anchors {
                            bottom: secondRectangle.bottom
                            bottomMargin: 50
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        onClicked: {
                            socketCan.sendData(idTextField.text, payloadTextField.text)
                            secondRectangle.border.color = activeRectangleBorderColor
                        }
                    }
                }
            }

            //Column3: Receive Message Area
            Column {
                id: thirdColumn
                enabled: false
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
