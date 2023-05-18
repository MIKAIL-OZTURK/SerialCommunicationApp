#include "socketcan.h"
#include <fcntl.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <linux/can/netlink.h>
#include <net/if.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <cerrno>
#include <libsocketcan.h>

SocketCan::SocketCan(QObject *parent)
	: QObject(parent),
	  m_canSocket(-1),
	  m_timer(this),
	  m_socketCreated(false),
	  m_deviceState(UnconnectedState),
	  m_busStatus(BusOff)
{
	connect(&m_timer, &QTimer::timeout, this, &SocketCan::readData);
}

SocketCan::~SocketCan()
{
	disconnectSocket();
}

// Create and bind socket
void SocketCan::connectSocket()
{
	if (m_canSocket != -1) {
		qWarning("Socket already created");
		return;
	}

	// Create Socket
	m_canSocket = socket(PF_CAN, SOCK_RAW, CAN_RAW);
	if (m_canSocket == -1) {
		qWarning("Socket creation failed: %s", strerror(errno));
		return;
	}

	// Set flag to indicate socket has been created
	m_socketCreated = true;
	m_deviceState = CanBusDeviceState::ConnectingState;
	m_busStatus = CanBusStatus::Good;
}


void SocketCan::bindSocket(const QString &can, const QString &bitRate)
{
	if (m_canSocket == -1) {
		qWarning("Socket not created");
		return;
	}

	// Set up interface
	struct ifreq ifr{};
	QByteArray canArray = can.toUtf8();

	if( can_do_stop("can0") != 0 )
	{
		qWarning("Could not set the interface down.");
	}

	const uint32_t bitrate = bitRate.toInt() * 1000;
	if( can_set_bitrate(canArray.constData(), bitrate) != 0 )
	{
		qWarning("Could not set bitrate to %d %s", bitrate, bitRate.constData());
	}

	if( can_do_start("can0") != 0 )
	{
		qWarning("Could not set the interface up.");
	}

	strncpy(ifr.ifr_name, canArray.constData(), IFNAMSIZ - 1);
	if (ioctl(m_canSocket, SIOCGIFINDEX, &ifr) == -1) {
		qWarning("Interface setup failed: %s", strerror(errno));
		close(m_canSocket);
		m_canSocket = -1;
		return;
	}

	// Bind Socket
	struct sockaddr_can addr{};
	memset(&addr, 0, sizeof(addr));
	addr.can_family = AF_CAN;
	addr.can_ifindex = ifr.ifr_ifindex;
	if (bind(m_canSocket, reinterpret_cast<struct sockaddr *>(&addr), sizeof(addr)) == -1) {
		qWarning("Socket binding failed: %s", strerror(errno));
		close(m_canSocket);
		m_canSocket = -1;
		return;
	}

	// Set non-blocking mode
	const int flags = fcntl(m_canSocket, F_GETFL, 0);
	fcntl(m_canSocket, F_SETFL, flags | O_NONBLOCK);

	// Start timer
	m_bitRate = bitRate;
	m_timer.start(50);
	m_deviceState = CanBusDeviceState::ConnectedState;
}


// Read data from the socket
void SocketCan::readData()
{
	if (m_canSocket == -1) {
		qWarning("Socket not created");
		return;
	}

	struct can_frame frame;
	QString message;

	if (m_deviceState == CanBusDeviceState::ConnectedState) {
		const ssize_t nbytes = read(m_canSocket, &frame, sizeof(frame));

		// Convert the data in the CAN frame to a QString for display
		for (int i = 0; i < frame.can_dlc; i++) {
			if (frame.data[i] != 0) {
				message.append(QString("%1 ").arg(frame.data[i], 2, 16, QLatin1Char('0')));
			}
		}

		if (nbytes <= 0) {
			if (nbytes < 0 && errno != EAGAIN) {
				perror("Error reading CAN data");
			}
			return;
		}

		if (frame.can_id & CAN_ERR_FLAG) {
			m_busStatus = CanBusStatus::Error;
		}
		else {
			m_busStatus = CanBusStatus::Good;
		}

		// Emit a signal with the received data
		emit dataReceived(QString::number(frame.can_id), message.trimmed());
		emit busStatusChanged();
	}
}



// Send data to the socket
void SocketCan::sendData(const QString &ID, const QString &message)
{
	if (m_canSocket == -1) {
		qWarning("Socket not created");
		return;
	}

	if (m_deviceState == CanBusDeviceState::ConnectedState) {
		// Create CAN frame
		struct can_frame frame;
		frame.can_id = ID.toInt(nullptr, 16);

		// Initialize the frame data with zeros
		memset(frame.data, 0, sizeof(frame.data));

		// Convert message string to data bytes
		QStringList parts = message.split(" ");
		frame.can_dlc = parts.size() > 8 ? 8: parts.size();
		for (int i = 0; i < frame.can_dlc; ++i) {
			bool ok = false;
			frame.data[i] = static_cast<unsigned char>(parts[i].toUInt(&ok, 16));
			if (!ok) {
				qWarning("Invalid hex number: %s", qPrintable(parts[i]));
				return;
			}
		}

		// Send the CAN frame to the socket
		const ssize_t nbytes = write(m_canSocket, &frame, sizeof(frame));
		if (nbytes != sizeof(frame)) {
			qWarning("Error sending CAN data");
		}
		emit dataReceived(QString::number(frame.can_id, 16), message.trimmed());
	}
}


// Disconnect the Socket
void SocketCan::disconnectSocket()
{
	if (m_canSocket != -1) {
		close(m_canSocket);
		m_canSocket = -1;
		m_timer.stop();
		m_deviceState = CanBusDeviceState::ClosingState;
		m_busStatus = CanBusStatus::BusOff;
	}
}

//Getter for deviceState and busStatus
SocketCan::CanBusDeviceState SocketCan::deviceState() const
{
	return m_deviceState;
}

SocketCan::CanBusStatus SocketCan::busStatus() const
{
	return m_busStatus;
}
