#include "socketcan.h"
#include <fcntl.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <net/if.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <cerrno>

SocketCan::SocketCan(QObject *parent)
    : QObject{parent}
{
    connect(&m_timer, &QTimer::timeout, this, &SocketCan::readData);
}

SocketCan::~SocketCan()
{
    disconnectSocket();
}


// Getter and setter for CAN ID
int SocketCan::canId() const
{
    return m_canId;
}

void SocketCan::setCanId(int id)
{
    if (m_canId != id) {
        m_canId = id;
        emit canIdChanged();
    }
}


// Check if socket is connected
bool SocketCan::isConnected() const
{
    return m_canSocket >= 0;
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

    bindSocket();
}

void SocketCan::bindSocket()
{
    if (m_canSocket == -1) {
        qWarning("Socket not created");
        return;
    }

    // Set up interface
    struct ifreq ifr{};
    strncpy(ifr.ifr_name, "vcan0", IFNAMSIZ - 1);
    if (ioctl(m_canSocket, SIOCGIFINDEX, &ifr) == -1) {
        qWarning("Interface setup failed: %s", strerror(errno));
        close(m_canSocket);
        m_canSocket = -1;
        return;
    }

    // Bind Socket
    struct sockaddr_can addr{};
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
    m_timer.start(50);
}


// Read data from the socket
void SocketCan::readData()
{
    if (m_canSocket == -1) {
        qWarning("Socket not created");
        return;
    }

    // Read data from the socket into a CAN frame struct
    struct can_frame frame;
    const ssize_t nbytes = read(m_canSocket, &frame, sizeof(frame));

    // If no data was read, or an error occurred, return
    if (nbytes <= 0) {
        if (nbytes < 0 && errno != EAGAIN) {
            qWarning("Error reading CAN data");
        }
        return;
    }

    // Convert the data in the CAN frame to a QString for display
    QString message;
    for (const auto &data : frame.data) {
        message.append(QString("%1 ").arg(data, 2, 16, QLatin1Char('0')));
    }

    // Emit a signal with the received data
    emit dataReceived(message.trimmed());
}



// Send data to the socket
void SocketCan::sendData(const QString &message)
{
    if (m_canSocket == -1) {
        qWarning("Socket not created");
        return;
    }

    // Create CAN frame
    struct can_frame frame;
    frame.can_id = m_canId; // use the ID property
    frame.can_dlc = 8;

    if(frame.can_dlc > 8) {
        qWarning("Payload size cannot be greater than 8!");
        return;
    }

    // Convert message string to data bytes
    QStringList parts = message.split(" ");
    for (int i = 0; i < frame.can_dlc && i < parts.size(); ++i) {
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
}


// Disconnect the Socket
void SocketCan::disconnectSocket()
{
    if (m_canSocket != -1) {
        close(m_canSocket);
        m_canSocket = -1;
        m_timer.stop();
    }
}
