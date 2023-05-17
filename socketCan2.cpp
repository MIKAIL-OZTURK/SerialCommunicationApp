#include "socketcan.h"
#include <QDebug>
#include <QTimer>

SocketCAN::SocketCAN(QObject* parent) noexcept
	: QObject(parent),
	  device_(nullptr),
	  timer_(nullptr)
{
	timer_ = std::make_unique<QTimer>(this);
	connect(timer_.get(), &QTimer::timeout, this, &SocketCAN::readFrame);
}

void SocketCAN::connectCanDevice(const QString& can, int bitRate)
{
	QByteArray canArray = can.toUtf8();
	QString errorString;

	device_ = std::unique_ptr<QCanBusDevice>(
		QCanBus::instance()->createDevice("socketcan", canArray.constData(), nullptr)
	);
	device_->setConfigurationParameter(QCanBusDevice::BitRateKey, bitRate);

	if (!device_) {
		qCritical() << "Failed to create socketcan device: " << errorString;
		return;
	}

	connect(device_.get(), &QCanBusDevice::errorOccurred, this, &SocketCAN::handleDeviceError);

	if (!device_->connectDevice()) {
		QTimer::singleShot(0, this, [this]() {
			emit connectionError("Failed to connect socketcan device");
		});
		return;
	}

	timer_->start(100);
}

void SocketCAN::disconnectCanDevice()
{
	if (device_) {
		device_->disconnectDevice();
		device_.reset();
	} else {
		qCritical() << "Device is not connected!";
	}
}

void SocketCAN::sendMessage(const QString& id, const QString& payload) const
{
	if (!device_) {
		qWarning() << "Device is not connected!";
		return;
	}

	bool ok = false;
	quint32 canID = id.toUInt(&ok, 16);
	if (!ok) {
		qCritical() << "Invalid message ID: " << id;
		return;
	}

	QByteArray payloadData = QByteArray::fromHex(payload.toUtf8());
	QCanBusFrame frame(canID, payloadData);

	if (!device_->writeFrame(frame)) {
		qWarning() << "Failed to send message: " << device_->errorString();
	}
}

void SocketCAN::readFrame()
{
	if (!device_) {
		qWarning() << "Device not initialized!";
		return;
	}

	const QVector<QCanBusFrame> frames = device_->readAllFrames();
	for (const QCanBusFrame& frame : frames) {
		if (frame.isValid()) {
			const QString id = QString::number(frame.frameId(), 16);
			const QString payload = QString(frame.payload().toHex());
			emit messageReceived(id, payload);
		}
	}
}

void SocketCAN::handleDeviceError(QCanBusDevice::CanBusError /*error*/)
{
	const QString errorString = device_->errorString();
	emit connectionError(errorString);
}
