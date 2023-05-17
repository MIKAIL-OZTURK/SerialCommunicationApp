#ifndef SOCKETCAN_H
#define SOCKETCAN_H

#include <QTimer>
#include <QCanBusFrame>
#include <QCanBusDevice>
#include <QCanBusDeviceInfo>

class SocketCan : public QObject
{
	Q_OBJECT
	Q_PROPERTY(CanBusDeviceState deviceState READ deviceState NOTIFY deviceStateChanged)
	Q_PROPERTY(CanBusStatus busStatus READ busStatus NOTIFY busStatusChanged)

public:
	explicit SocketCan(QObject *parent = nullptr);
	~SocketCan();

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

	bool isConnected() const;
	CanBusDeviceState deviceState() const;
	CanBusStatus busStatus() const;

signals:

signals:
	void dataReceived(QString ID, const QString& message);
	void deviceStateChanged();
	void busStatusChanged();

public slots:
	void connectSocket();
	void bindSocket();
	void readData();
	void sendData(const QString &ID, const QString &message);
	void disconnectSocket();

private:
	int m_canSocket;
	QTimer m_timer;
	bool m_socketCreated;
	CanBusDeviceState m_deviceState;
	CanBusStatus m_busStatus;
	QString lastID;
};

#endif // SOCKETCAN_H
