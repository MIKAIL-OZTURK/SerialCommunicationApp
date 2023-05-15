#ifndef SOCKETCAN_H
#define SOCKETCAN_H

//#include <QObject>
#include <QTimer>
#include <QCanBusFrame>
#include <QCanBusDevice>
#include <QCanBusDeviceInfo>

class SocketCan : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int canId READ canId WRITE setCanId MEMBER m_canId NOTIFY canIdChanged)
	Q_PROPERTY(CanBusDeviceState deviceState READ deviceState NOTIFY deviceStateChanged)
	Q_PROPERTY(CanBusStatus busStatus READ busStatus NOTIFY busStatusChanged)

public:
	explicit SocketCan(QObject *parent = nullptr);
	~SocketCan();

	enum FrameType {
		DataFrame = QCanBusFrame::DataFrame,
		ErrorFrame = QCanBusFrame::ErrorFrame,
		RemoteRequestFrame = QCanBusFrame::RemoteRequestFrame
	};
	Q_ENUM(FrameType)

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

	int canId()const;
	void setCanId(int id);
	bool isConnected() const;
	CanBusDeviceState deviceState() const;
	CanBusStatus busStatus() const;

signals:
	void dataReceived(const QString& message);
	void canIdChanged();
	void deviceStateChanged();
	void busStatusChanged();

public slots:
	void connectSocket();
	void bindSocket();
	void readData();
	void sendData(const QString &message);
	void disconnectSocket();

private:
	int m_canId;
	int m_canSocket;
	QTimer m_timer;
	bool m_socketCreated;
	CanBusDeviceState m_deviceState;
	CanBusStatus m_busStatus;
};

#endif // SOCKETCAN_H
