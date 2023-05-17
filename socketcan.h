#ifndef SOCKETCAN_H
#define SOCKETCAN_H

#include <QTimer>
#include <QCanBusFrame>
#include <QCanBusDevice>

class SocketCan : public QObject
{
	Q_OBJECT
	Q_PROPERTY(CanBusDeviceState deviceState READ deviceState NOTIFY deviceStateChanged)
	Q_PROPERTY(CanBusStatus busStatus READ busStatus NOTIFY busStatusChanged)

public:
	explicit SocketCan(QObject *parent = nullptr);
	~SocketCan();

	enum BitRates {
		BitRates125KBits = 125000,
		BitRates250KBits = 250000,
		BitRates500KBits = 500000,
		BitRates1000Bits = 1000000
	};
	Q_ENUM(BitRates)

	enum CanBusDeviceState {
		UnconnectedState,
		ConnectingState,
		ConnectedState,
		ClosingState
	};
	Q_ENUM(CanBusDeviceState)

	enum CanBusStatus {
		Unknown,
		Good,
		Warning,
		Error,
		BusOff
	};
	Q_ENUM(CanBusStatus)

	CanBusDeviceState deviceState() const;
	CanBusStatus busStatus() const;

signals:
	void dataReceived(QString ID, const QString& message);
	void deviceStateChanged();
	void busStatusChanged();

public slots:
	void connectSocket();
	void bindSocket(const QString &can, const QString &bitRate);
	void readData();
	void sendData(const QString &ID, const QString &message);
	void disconnectSocket();

private:
	int m_canSocket;
	QTimer m_timer;
	bool m_socketCreated;
	CanBusDeviceState m_deviceState;
	CanBusStatus m_busStatus;
	QString m_bitRate;
};

#endif // SOCKETCAN_H
