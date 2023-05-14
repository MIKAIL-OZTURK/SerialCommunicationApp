#ifndef SOCKETCAN_H
#define SOCKETCAN_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QCanBusFrame>

class SocketCan : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int canId READ canId WRITE setCanId MEMBER m_canId NOTIFY canIdChanged)

public:
    explicit SocketCan(QObject *parent = nullptr);
    ~SocketCan();

    enum FrameType {
        DataFrame = QCanBusFrame::DataFrame,
        ErrorFrame = QCanBusFrame::ErrorFrame,
        RemoteRequestFrame = QCanBusFrame::RemoteRequestFrame
    };
    Q_ENUM(FrameType)

    int canId()const;
    void setCanId(int id);
    bool isConnected() const;

signals:
    void dataReceived(const QString& message);
    void canIdChanged();

public slots:
    void connectSocket();
    void bindSocket();
    void readData();
    void sendData(const QString &message);
    void disconnectSocket();

private:
    int m_canId{ 555 };
    int m_canSocket{ -1 };
    QTimer m_timer;
    bool m_socketCreated{ false };
};

#endif // SOCKETCAN_H
