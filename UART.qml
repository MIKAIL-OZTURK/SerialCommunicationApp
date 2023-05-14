import QtQuick 2.15
import QtQuick.Controls 2.15
import SerialPort 1.0

Item {
    SerialPort {
        id: serialPort
        property string buffer: ""
        onDataReceived: {
            buffer += data;
            var end = buffer.indexOf("\r\n");
            readMessageInput.text = buffer;
        }
    }

    //Window
    Rectangle {
        color: "dodgerblue"
        anchors.fill: parent
        Row {
            spacing: 40
            anchors.centerIn: parent

            //Column1: Coonfiguration & Connection Area
            Column {
                Rectangle {
                    id: firstRectangle
                    width: 380
                    height: 380
                    color: "white"
                    border.width: 4
                    border.color: "#EE1C25"
                    radius: 5

                    // Port
                    Row {
                        id: rowPort
                        spacing: 84
                        anchors {
                            top: firstRectangle.top
                            topMargin: 20
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            text: "Port"
                            font.pointSize: 14
                            font.bold: true
                        }
                        TextField {
                            id: portTextField
                            width: 170
                            placeholderText: "/dev/ttyACM0"
                        }
                    }

                    // Baud Rate
                    Row {
                        id: rowBaudRate
                        spacing: 30
                        anchors {
                            top: rowPort.bottom
                            topMargin: 10
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            text: "Baud Rate"
                            font.pointSize: 14
                            font.bold: true
                        }
                        ComboBox {
                            id: baudRateComboBox
                            width: 170
                            currentIndex: 0
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "9600";     choice: SerialPort.BaudRate9600     }
                                ListElement { text: "115200";   choice: SerialPort.BaudRate115200   }
                            }
                        }
                    }

                    // Data Bits
                    Row {
                        id: rowDataBits
                        spacing: 38
                        anchors {
                            top: rowBaudRate.bottom
                            topMargin: 10
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            text: "Data Bits"
                            font.pointSize: 14
                            font.bold: true
                        }
                        ComboBox {
                            id: dataBitsComboBox
                            width: 170
                            currentIndex: 3
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "5";    choice: SerialPort.DataBits5  }
                                ListElement { text: "6";    choice: SerialPort.DataBits6  }
                                ListElement { text: "7";    choice: SerialPort.DataBits7  }
                                ListElement { text: "8";    choice: SerialPort.DataBits8  }
                            }
                        }
                    }

                    //Stop Bit
                    Row {
                        id: rowStopBit
                        spacing: 38
                        anchors {
                            top: rowDataBits.bottom
                            topMargin: 10
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            text: "Stop Bits"
                            font.pointSize: 14
                            font.bold: true
                        }
                        ComboBox {
                            id: stopBitsComboBox
                            width: 170
                            currentIndex: 0
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "1";    choice: SerialPort.OneStop          }
                                ListElement { text: "1.5";  choice: SerialPort.OneAndHalfStop   }
                                ListElement { text: "2";    choice: SerialPort.TwoStop          }
                            }
                        }
                    }

                    // Parity Bit
                    Row {
                        id: rowParityBit
                        anchors {
                            top: rowStopBit.bottom
                            topMargin: 10
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        spacing: 38
                        Label {
                            text: "Parity Bit"
                            font.pointSize: 14
                            font.bold: true
                        }
                        ComboBox {
                            id: parityBitComboBox
                            width: 170
                            currentIndex: 0
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "No parity";    choice: SerialPort.NoParity     }
                                ListElement { text: "Even parity";  choice: SerialPort.EvenParity   }
                                ListElement { text: "Odd parity";   choice: SerialPort.OddParity    }
                                ListElement { text: "Space parity"; choice: SerialPort.SpaceParity  }
                                ListElement { text: "Mark parity";  choice: SerialPort.MarkParity   }
                            }
                        }
                    }

                    // Flow Control
                    Row {
                        id: rowFlowControl
                        spacing: 10
                        anchors {
                            top: rowParityBit.bottom
                            topMargin: 10
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Label {
                            text: "Flow Control"
                            font.pointSize: 14
                            font.bold: true
                        }
                        ComboBox {
                            id: flowControlComboBox
                            width: 170
                            currentIndex: 0
                            textRole: "text"
                            valueRole: "choice"
                            model: ListModel {
                                ListElement { text: "No Flow Control";  choice: SerialPort.NoFlowControl    }
                                ListElement { text: "Hardware Control"; choice: SerialPort.HardwareControl  }
                                ListElement { text: "Software Control"; choice: SerialPort.SoftwareControl  }
                            }
                        }
                    }

                    // Connect & Disconnect Buttons
                    Row {
                        spacing: 15
                        anchors {
                            top: rowFlowControl.bottom
                            topMargin: 14
                            horizontalCenter: firstRectangle.horizontalCenter
                        }
                        Button {
                            id: connectButton
                            text: "Connect"
                            onClicked: {
                                serialPort.portName = (portTextField.text);
                                serialPort.baudRate = parseInt(baudRateComboBox.currentText);
                                serialPort.dataBits = dataBitsComboBox.currentValue;
                                serialPort.stopBits = stopBitsComboBox.currentValue;
                                serialPort.parity = parityBitComboBox.currentValue;
                                serialPort.flowControl = flowControlComboBox.currentIndex;
                                serialPort.open();
                                firstRectangle.border.color = "#3ABE00"
                                console.log("Port Name: ",  serialPort.portName)
                                console.log("Port BaudRate: ", serialPort.baudRate)
                                console.log("Port DataBits:", serialPort.dataBits)
                                console.log("Port StopBits: ", serialPort.stopBits)
                                console.log("Port ParityBit: ", serialPort.parity)
                                console.log("Port FlowControl: ", serialPort.flowControl)
                            }
                        }
                        Button {
                            id: disconnectButton
                            text: "Disconnect"
                            onClicked: {
                                serialPort.close();
                                console.log("Port Closed")
                                firstRectangle.border.color = "#EE1C25"
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
                    border.width: 4
                    border.color: "#EE1C25"
                    radius: 5
                    Label {
                        id: writeMessageLabel
                        text: "Write Message"
                        font.pointSize: 14
                        font.bold: true
                        anchors {
                            top: secondRectangle.top
                            topMargin: 20
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                    }
                    Rectangle {
                        id: writeMessageBox
                        width: 250
                        height: 250
                        color: "#F5F5F5"
                        border.color: "#BDBDBD"
                        border.width: 1
                        radius: 5
                        anchors {
                            top: writeMessageLabel.bottom
                            topMargin: 15
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        TextInput {
                            id: writeMessageInput
                            anchors.fill: parent
                            text: "Write your message"
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                        }
                    }
                    Button {
                        id: sendMessageButton
                        text: "Send"
                        anchors {
                            top: writeMessageBox.bottom
                            topMargin: 12
                            horizontalCenter: secondRectangle.horizontalCenter
                        }
                        onClicked: {
                            var message = writeMessageInput.text.trim();
                            if (message.length > 0) {
                                serialPort.sendData(message + "\r\n");
                                console.log("Message is sending: " + message);
                                writeMessageInput.text = "";
                                firstRectangle.border.color = "#3ABE00"
                            }
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
                    border.width: 4
                    border.color: "#EE1C25"
                    radius: 5
                    Label {
                        id: readMessageLabel
                        text: "Read Message"
                        font.pointSize: 14
                        font.bold: true
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
                        border.color: "#BDBDBD"
                        border.width: 1
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
                                thirdRectangle.border.color = "#3ABE00"
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
                        onClicked: readMessageInput.clear()
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
                    stackView.pop()
                }
            }
        }
    }
}
