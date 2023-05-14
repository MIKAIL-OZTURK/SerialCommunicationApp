#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <QQuickItem>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QString>

class SerialPort : public QQuickItem {

	Q_OBJECT
	Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
	Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)
	Q_PROPERTY(int dataBits READ dataBits WRITE setDataBits NOTIFY dataBitsChanged)
	Q_PROPERTY(StopBits stopBits READ stopBits WRITE setStopBits NOTIFY stopBitsChanged)
	Q_PROPERTY(Parity parity READ parity WRITE setParity NOTIFY parityChanged)
	Q_PROPERTY(FlowControl flowControl READ flowControl WRITE setFlowControl NOTIFY flowControlChanged)

public:
	enum BaudRate {
		BaudRate9600 = QSerialPort::BaudRate::Baud9600,
		BaudRate115200 = QSerialPort::BaudRate::Baud115200
	};
	Q_ENUM(BaudRate)

	enum DataBits {
		DataBits5 = QSerialPort::DataBits::Data5,
		DataBits6 = QSerialPort::DataBits::Data6,
		DataBits7 = QSerialPort::DataBits::Data7,
		DataBits8 = QSerialPort::DataBits::Data8
	};
	Q_ENUM(DataBits)

	enum Parity {
		NoParity = QSerialPort::NoParity,
		EvenParity = QSerialPort::EvenParity,
		OddParity  = QSerialPort::OddParity,
		SpaceParity = QSerialPort::SpaceParity,
		MarkParity = QSerialPort::MarkParity
	};
	Q_ENUM(Parity)

	enum StopBits {
		OneStop = QSerialPort::OneStop,
		OneAndHalfStop = QSerialPort::OneAndHalfStop,
		TwoStop = QSerialPort::TwoStop
	};
	Q_ENUM(StopBits)

	enum FlowControl {
		NoFlowControl = QSerialPort::NoFlowControl,
		HardwareControl = QSerialPort::HardwareControl,
		SoftwareControl = QSerialPort::SoftwareControl
	};
	Q_ENUM(FlowControl)

	SerialPort(QQuickItem* parent = 0);
	virtual ~SerialPort() = default;

	QString portName()const {
		return portName_;
	}

	int baudRate()const {
		return baudRate_;
	}

	int dataBits()const {
		return dataBits_;
	}

	StopBits stopBits()const {
		return stopBits_;
	}

	FlowControl flowControl()const {
		return flowControl_;
	}

	Parity parity()const {
		return parity_;
	}

	void setPortName(QString portName);
	void setBaudRate(int baudRate);
	void setDataBits(int dataBits);
	void setFlowControl(FlowControl flowControl);
	void setParity(Parity parity);
	void setStopBits(StopBits stopBits);

signals:
	void portNameChanged();
	void baudRateChanged();
	void dataBitsChanged();
	void flowControlChanged();
	void parityChanged();
	void stopBitsChanged();
	void dataReceived(QString data);

public slots:
	void open();
	void close();
	void sendData(QString data);

private slots:
	void readyRead();

private:
	QString portName_;
	int baudRate_;
	int dataBits_;
	FlowControl flowControl_;
	Parity parity_;
	StopBits stopBits_;
	QSerialPort serialPort;
};

#endif // SERIALPORT_H
