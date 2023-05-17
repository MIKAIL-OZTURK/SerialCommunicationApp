#ifndef SOCKETCAN_H
#define SOCKETCAN_H

#include <QObject>
#include <QCanBus>
#include <QTimer>
#include <memory>

class SocketCAN : public QObject
{
	Q_OBJECT
public:
	explicit SocketCAN(QObject* parent = nullptr) noexcept;
	SocketCAN(const SocketCAN&) = delete;
	SocketCAN& operator=(const SocketCAN&) = delete;

signals:
	void messageReceived(const QString& id, const QString& payload);
	void connectionError(const QString& errorString);

public slots:
	void connectCanDevice(const QString& can, int bitRate);
	void disconnectCanDevice();
	void readFrame();
	void sendMessage(const QString& id, const QString& payload) const;
	void handleDeviceError(QCanBusDevice::CanBusError error);

private:
	std::unique_ptr<QCanBusDevice> device_;
	std::unique_ptr<QTimer> timer_;
};

#endif // SOCKETCAN_H
