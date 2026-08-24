#pragma once

#include "core/handler/ConfigHandler.hpp"
#include "utils/QvHelpers.hpp"

#include <QAbstractListModel>
#include <QClipboard>
#include <QGuiApplication>
#include <QObject>
#include <QQmlEngine>
#include <QVariant>

// =================================================================================
// Connection List Model
// Exposes connections of the currently selected group to QML.
// =================================================================================
class ConnectionListModel : public QAbstractListModel
{
    Q_OBJECT
  public:
    enum Roles
    {
        ConnectionIdRole = Qt::UserRole + 1,
        DisplayNameRole,
        ProtocolRole,
        AddressRole,
        PortRole,
        LatencyTextRole,
        IsConnectedRole,
        IsRunningRole,
        UpTotalRole,
        DownTotalRole,
        LastConnectedRole,
        InCurrentGroupRole
    };

    explicit ConnectionListModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setGroup(const GroupId &groupId);
    GroupId currentGroup() const { return _groupId; }
    void refresh();

  private:
    GroupId _groupId;
    QList<ConnectionId> _connections;
};

// =================================================================================
// Group List Model
// Exposes all connection groups to QML.
// =================================================================================
class GroupListModel : public QAbstractListModel
{
    Q_OBJECT
  public:
    enum Roles
    {
        GroupIdRole = Qt::UserRole + 1,
        DisplayNameRole,
        IsSubscriptionRole,
        ConnectionCountRole,
        SubscriptionAddressRole,
        SubscriptionIntervalRole,
        SubscriptionLastUpdatedRole
    };

    explicit GroupListModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void refresh();

  private:
    QList<GroupId> _groups;
};

// =================================================================================
// QML Property Bridge
// Exposed to QML as the `plumbum` context property.
// =================================================================================
class PlumbumQMLProperty : public QObject
{
    Q_OBJECT
    Q_PROPERTY(ConnectionListModel *connectionModel READ connectionModel CONSTANT)
    Q_PROPERTY(GroupListModel *groupModel READ groupModel CONSTANT)
    Q_PROPERTY(QString currentGroupId READ currentGroupId WRITE setCurrentGroupId NOTIFY currentGroupIdChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectivityChanged)
    Q_PROPERTY(QString connectedConnectionId READ connectedConnectionId NOTIFY connectivityChanged)
    Q_PROPERTY(QString connectedName READ connectedName NOTIFY connectivityChanged)
    Q_PROPERTY(QString upSpeedText READ upSpeedText NOTIFY statsChanged)
    Q_PROPERTY(QString downSpeedText READ downSpeedText NOTIFY statsChanged)
    Q_PROPERTY(QString upTotalText READ upTotalText NOTIFY statsChanged)
    Q_PROPERTY(QString downTotalText READ downTotalText NOTIFY statsChanged)
    Q_PROPERTY(QString kernelStatusText READ kernelStatusText NOTIFY kernelStatusChanged)
    Q_PROPERTY(QString v2rayCorePath READ v2rayCorePath WRITE setV2rayCorePath NOTIFY settingsChanged)
    Q_PROPERTY(QString v2rayAssetsPath READ v2rayAssetsPath WRITE setV2rayAssetsPath NOTIFY settingsChanged)
    Q_PROPERTY(bool kernelApiEnabled READ kernelApiEnabled WRITE setKernelApiEnabled NOTIFY settingsChanged)
    Q_PROPERTY(int statsPort READ statsPort WRITE setStatsPort NOTIFY settingsChanged)
    Q_PROPERTY(int pacMode READ pacMode WRITE setPacMode NOTIFY pacModeChanged)
    Q_PROPERTY(bool tunEnabled READ tunEnabled WRITE setTunEnabled NOTIFY settingsChanged)
    Q_PROPERTY(QString tunIpv4 READ tunIpv4 WRITE setTunIpv4 NOTIFY settingsChanged)
    Q_PROPERTY(int tunMtu READ tunMtu WRITE setTunMtu NOTIFY settingsChanged)
    Q_PROPERTY(bool tunAvailable READ tunAvailable NOTIFY settingsChanged)
    Q_PROPERTY(QString inboundListenAddress READ inboundListenAddress NOTIFY settingsChanged)
    Q_PROPERTY(bool socksInboundEnabled READ socksInboundEnabled NOTIFY settingsChanged)
    Q_PROPERTY(QString socksListenAddress READ socksListenAddress NOTIFY settingsChanged)
    Q_PROPERTY(int socksPort READ socksPort NOTIFY settingsChanged)
    Q_PROPERTY(bool socksUdpEnabled READ socksUdpEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool socksAuthEnabled READ socksAuthEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool httpInboundEnabled READ httpInboundEnabled NOTIFY settingsChanged)
    Q_PROPERTY(int httpPort READ httpPort NOTIFY settingsChanged)
    Q_PROPERTY(bool httpAuthEnabled READ httpAuthEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool tproxyInboundEnabled READ tproxyInboundEnabled NOTIFY settingsChanged)
    Q_PROPERTY(QString tproxyListenAddress READ tproxyListenAddress NOTIFY settingsChanged)
    Q_PROPERTY(QString tproxyListenAddressV6 READ tproxyListenAddressV6 NOTIFY settingsChanged)
    Q_PROPERTY(int tproxyPort READ tproxyPort NOTIFY settingsChanged)
    Q_PROPERTY(bool tproxyTcpEnabled READ tproxyTcpEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool tproxyUdpEnabled READ tproxyUdpEnabled NOTIFY settingsChanged)
    Q_PROPERTY(bool systemProxyEnabled READ systemProxyEnabled NOTIFY settingsChanged)
    Q_PROPERTY(QString browserForwarderAddress READ browserForwarderAddress NOTIFY settingsChanged)
    Q_PROPERTY(int browserForwarderPort READ browserForwarderPort NOTIFY settingsChanged)
    Q_PROPERTY(QString tunIpv6 READ tunIpv6 NOTIFY settingsChanged)
    Q_PROPERTY(bool tunAutoRoute READ tunAutoRoute NOTIFY settingsChanged)
    Q_PROPERTY(bool tunStrictRoute READ tunStrictRoute NOTIFY settingsChanged)
    Q_PROPERTY(bool tunSniffing READ tunSniffing NOTIFY settingsChanged)
    Q_PROPERTY(bool bypassCN READ bypassCN NOTIFY settingsChanged)
    Q_PROPERTY(bool bypassLAN READ bypassLAN NOTIFY settingsChanged)
    Q_PROPERTY(bool bypassBT READ bypassBT NOTIFY settingsChanged)
    Q_PROPERTY(bool forceDirect READ forceDirect NOTIFY settingsChanged)
    Q_PROPERTY(bool v2rayFreedomDNS READ v2rayFreedomDNS NOTIFY settingsChanged)
    Q_PROPERTY(bool dnsIntercept READ dnsIntercept NOTIFY settingsChanged)
    Q_PROPERTY(QString dnsServers READ dnsServers NOTIFY settingsChanged)
    Q_PROPERTY(QString domainStrategy READ domainStrategy NOTIFY settingsChanged)
    Q_PROPERTY(QString domainMatcher READ domainMatcher NOTIFY settingsChanged)
    Q_PROPERTY(QString domainDirectRules READ domainDirectRules NOTIFY settingsChanged)
    Q_PROPERTY(QString domainBlockRules READ domainBlockRules NOTIFY settingsChanged)
    Q_PROPERTY(QString domainProxyRules READ domainProxyRules NOTIFY settingsChanged)
    Q_PROPERTY(QString ipDirectRules READ ipDirectRules NOTIFY settingsChanged)
    Q_PROPERTY(QString ipBlockRules READ ipBlockRules NOTIFY settingsChanged)
    Q_PROPERTY(QString ipProxyRules READ ipProxyRules NOTIFY settingsChanged)
    Q_PROPERTY(bool groupRouteOverride READ groupRouteOverride NOTIFY settingsChanged)
    Q_PROPERTY(bool groupDnsOverride READ groupDnsOverride NOTIFY settingsChanged)
    Q_PROPERTY(bool groupConnectionOverride READ groupConnectionOverride NOTIFY settingsChanged)
    Q_PROPERTY(bool groupForwardProxyOverride READ groupForwardProxyOverride NOTIFY settingsChanged)
    Q_PROPERTY(QString fakeDnsIpPool READ fakeDnsIpPool NOTIFY settingsChanged)
    Q_PROPERTY(int fakeDnsPoolSize READ fakeDnsPoolSize NOTIFY settingsChanged)
    Q_PROPERTY(bool forwardProxyEnabled READ forwardProxyEnabled NOTIFY settingsChanged)
    Q_PROPERTY(QString forwardProxyType READ forwardProxyType NOTIFY settingsChanged)
    Q_PROPERTY(QString forwardProxyAddress READ forwardProxyAddress NOTIFY settingsChanged)
    Q_PROPERTY(int forwardProxyPort READ forwardProxyPort NOTIFY settingsChanged)
    Q_PROPERTY(bool forwardProxyAuth READ forwardProxyAuth NOTIFY settingsChanged)
    Q_PROPERTY(QString forwardProxyUsername READ forwardProxyUsername NOTIFY settingsChanged)
    Q_PROPERTY(QString forwardProxyPassword READ forwardProxyPassword NOTIFY settingsChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY settingsChanged)
    Q_PROPERTY(int themeMode READ themeMode WRITE setThemeMode NOTIFY themeModeChanged)
    Q_PROPERTY(bool systemDark READ systemDark NOTIFY systemThemeChanged)
    Q_PROPERTY(bool autoStartEnabled READ autoStartEnabled WRITE setAutoStartEnabled NOTIFY settingsChanged)
    Q_PROPERTY(QString versionString READ versionString CONSTANT)

  public:
    explicit PlumbumQMLProperty(QObject *parent = nullptr);
    ~PlumbumQMLProperty();

    ConnectionListModel *connectionModel() { return &_connectionModel; }
    GroupListModel *groupModel() { return &_groupModel; }

    QString currentGroupId() const { return _currentGroupId.toString(); }
    void setCurrentGroupId(const QString &id);

    bool connected() const { return _connected; }
    QString connectedConnectionId() const { return _connectedConnectionId.toString(); }
    QString connectedName() const { return _connectedName; }
    QString upSpeedText() const { return _upSpeedText; }
    QString downSpeedText() const { return _downSpeedText; }
    QString upTotalText() const { return _upTotalText; }
    QString downTotalText() const { return _downTotalText; }
    QString kernelStatusText() const { return _kernelStatusText; }

    // Settings (GlobalConfig)
    QString v2rayCorePath() const { return GlobalConfig.kernelConfig.KernelPath(); }
    Q_INVOKABLE void setV2rayCorePath(const QString &path);
    QString v2rayAssetsPath() const { return GlobalConfig.kernelConfig.AssetsPath(); }
    Q_INVOKABLE void setV2rayAssetsPath(const QString &path);
    bool kernelApiEnabled() const { return GlobalConfig.kernelConfig.enableAPI; }
    Q_INVOKABLE void setKernelApiEnabled(bool enabled);
    int statsPort() const { return GlobalConfig.kernelConfig.statsPort; }
    Q_INVOKABLE void setStatsPort(int port);
    // PAC routing mode (0=whitelist, 1=blacklist, 2=global)
    int pacMode() const { return GlobalConfig.defaultRouteConfig.connectionConfig.pacMode; }
    Q_INVOKABLE void setPacMode(int mode);
    // TUN system-level proxy
    bool tunEnabled() const { return GlobalConfig.inboundConfig.tunSettings.enabled; }
    Q_INVOKABLE void setTunEnabled(bool enabled);
    QString tunIpv4() const { return GlobalConfig.inboundConfig.tunSettings.ipv4; }
    Q_INVOKABLE void setTunIpv4(const QString &ip);
    int tunMtu() const { return GlobalConfig.inboundConfig.tunSettings.mtu; }
    Q_INVOKABLE void setTunMtu(int mtu);
    QString inboundListenAddress() const { return GlobalConfig.inboundConfig.listenip; }
    bool socksInboundEnabled() const { return GlobalConfig.inboundConfig.useSocks; }
    QString socksListenAddress() const { return GlobalConfig.inboundConfig.socksSettings.localIP; }
    int socksPort() const { return GlobalConfig.inboundConfig.socksSettings.port; }
    bool socksUdpEnabled() const { return GlobalConfig.inboundConfig.socksSettings.enableUDP; }
    bool socksAuthEnabled() const { return GlobalConfig.inboundConfig.socksSettings.useAuth; }
    bool httpInboundEnabled() const { return GlobalConfig.inboundConfig.useHTTP; }
    int httpPort() const { return GlobalConfig.inboundConfig.httpSettings.port; }
    bool httpAuthEnabled() const { return GlobalConfig.inboundConfig.httpSettings.useAuth; }
    bool tproxyInboundEnabled() const { return GlobalConfig.inboundConfig.useTPROXY; }
    QString tproxyListenAddress() const { return GlobalConfig.inboundConfig.tProxySettings.tProxyIP; }
    QString tproxyListenAddressV6() const { return GlobalConfig.inboundConfig.tProxySettings.tProxyV6IP; }
    int tproxyPort() const { return GlobalConfig.inboundConfig.tProxySettings.port; }
    bool tproxyTcpEnabled() const { return GlobalConfig.inboundConfig.tProxySettings.hasTCP; }
    bool tproxyUdpEnabled() const { return GlobalConfig.inboundConfig.tProxySettings.hasUDP; }
    bool systemProxyEnabled() const { return GlobalConfig.inboundConfig.systemProxySettings.setSystemProxy; }
    QString browserForwarderAddress() const { return GlobalConfig.inboundConfig.browserForwarderSettings.address; }
    int browserForwarderPort() const { return GlobalConfig.inboundConfig.browserForwarderSettings.port; }
    QString tunIpv6() const { return GlobalConfig.inboundConfig.tunSettings.ipv6; }
    bool tunAutoRoute() const { return GlobalConfig.inboundConfig.tunSettings.autoRoute; }
    bool tunStrictRoute() const { return GlobalConfig.inboundConfig.tunSettings.strictRoute; }
    bool tunSniffing() const { return GlobalConfig.inboundConfig.tunSettings.sniffing; }
    Q_INVOKABLE void setInboundListenAddress(const QString &value);
    Q_INVOKABLE void setSocksInboundEnabled(bool value);
    Q_INVOKABLE void setSocksListenAddress(const QString &value);
    Q_INVOKABLE void setSocksPort(int value);
    Q_INVOKABLE void setSocksUdpEnabled(bool value);
    Q_INVOKABLE void setSocksAuthEnabled(bool value);
    Q_INVOKABLE void setHttpInboundEnabled(bool value);
    Q_INVOKABLE void setHttpPort(int value);
    Q_INVOKABLE void setHttpAuthEnabled(bool value);
    Q_INVOKABLE void setTproxyInboundEnabled(bool value);
    Q_INVOKABLE void setTproxyListenAddress(const QString &value);
    Q_INVOKABLE void setTproxyListenAddressV6(const QString &value);
    Q_INVOKABLE void setTproxyPort(int value);
    Q_INVOKABLE void setTproxyTcpEnabled(bool value);
    Q_INVOKABLE void setTproxyUdpEnabled(bool value);
    Q_INVOKABLE void setSystemProxyEnabled(bool value);
    Q_INVOKABLE void setBrowserForwarderAddress(const QString &value);
    Q_INVOKABLE void setBrowserForwarderPort(int value);
    Q_INVOKABLE void setTunIpv6(const QString &value);
    Q_INVOKABLE void setTunAutoRoute(bool value);
    Q_INVOKABLE void setTunStrictRoute(bool value);
    Q_INVOKABLE void setTunSniffing(bool value);
    bool bypassCN() const { return GlobalConfig.defaultRouteConfig.connectionConfig.bypassCN; }
    bool bypassLAN() const { return GlobalConfig.defaultRouteConfig.connectionConfig.bypassLAN; }
    bool bypassBT() const { return GlobalConfig.defaultRouteConfig.connectionConfig.bypassBT; }
    bool forceDirect() const { return !GlobalConfig.defaultRouteConfig.connectionConfig.enableProxy; }
    bool v2rayFreedomDNS() const { return GlobalConfig.defaultRouteConfig.connectionConfig.v2rayFreedomDNS; }
    bool dnsIntercept() const { return GlobalConfig.defaultRouteConfig.connectionConfig.dnsIntercept; }
    QString dnsServers() const;
    QString domainStrategy() const { return GlobalConfig.defaultRouteConfig.routeConfig.domainStrategy; }
    QString domainMatcher() const { return GlobalConfig.defaultRouteConfig.routeConfig.domainMatcher; }
    QString domainDirectRules() const { return QStringList(GlobalConfig.defaultRouteConfig.routeConfig.domains.direct).join('\n'); }
    QString domainBlockRules() const { return QStringList(GlobalConfig.defaultRouteConfig.routeConfig.domains.block).join('\n'); }
    QString domainProxyRules() const { return QStringList(GlobalConfig.defaultRouteConfig.routeConfig.domains.proxy).join('\n'); }
    QString ipDirectRules() const { return QStringList(GlobalConfig.defaultRouteConfig.routeConfig.ips.direct).join('\n'); }
    QString ipBlockRules() const { return QStringList(GlobalConfig.defaultRouteConfig.routeConfig.ips.block).join('\n'); }
    QString ipProxyRules() const { return QStringList(GlobalConfig.defaultRouteConfig.routeConfig.ips.proxy).join('\n'); }
    bool groupRouteOverride() const;
    bool groupDnsOverride() const;
    bool groupConnectionOverride() const;
    bool groupForwardProxyOverride() const;
    QString fakeDnsIpPool() const { return GlobalConfig.defaultRouteConfig.fakeDNSConfig.ipPool; }
    int fakeDnsPoolSize() const { return GlobalConfig.defaultRouteConfig.fakeDNSConfig.poolSize; }
    bool forwardProxyEnabled() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.enableForwardProxy; }
    QString forwardProxyType() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.type; }
    QString forwardProxyAddress() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.serverAddress; }
    int forwardProxyPort() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.port; }
    bool forwardProxyAuth() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.useAuth; }
    QString forwardProxyUsername() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.username; }
    QString forwardProxyPassword() const { return GlobalConfig.defaultRouteConfig.forwardProxyConfig.password; }
    Q_INVOKABLE void setBypassCN(bool value);
    Q_INVOKABLE void setBypassLAN(bool value);
    Q_INVOKABLE void setBypassBT(bool value);
    Q_INVOKABLE void setForceDirect(bool value);
    Q_INVOKABLE void setV2rayFreedomDNS(bool value);
    Q_INVOKABLE void setDnsIntercept(bool value);
    Q_INVOKABLE void setDnsServers(const QString &value);
    Q_INVOKABLE void setDomainStrategy(const QString &value);
    Q_INVOKABLE void setDomainMatcher(const QString &value);
    Q_INVOKABLE void setDomainDirectRules(const QString &value);
    Q_INVOKABLE void setDomainBlockRules(const QString &value);
    Q_INVOKABLE void setDomainProxyRules(const QString &value);
    Q_INVOKABLE void setIpDirectRules(const QString &value);
    Q_INVOKABLE void setIpBlockRules(const QString &value);
    Q_INVOKABLE void setIpProxyRules(const QString &value);
    Q_INVOKABLE void setGroupRouteOverride(bool value);
    Q_INVOKABLE void setGroupDnsOverride(bool value);
    Q_INVOKABLE void setGroupConnectionOverride(bool value);
    Q_INVOKABLE void setGroupForwardProxyOverride(bool value);
    Q_INVOKABLE void setFakeDnsIpPool(const QString &value);
    Q_INVOKABLE void setFakeDnsPoolSize(int value);
    Q_INVOKABLE void setForwardProxyEnabled(bool value);
    Q_INVOKABLE void setForwardProxyType(const QString &value);
    Q_INVOKABLE void setForwardProxyAddress(const QString &value);
    Q_INVOKABLE void setForwardProxyPort(int value);
    Q_INVOKABLE void setForwardProxyAuth(bool value);
    Q_INVOKABLE void setForwardProxyUsername(const QString &value);
    Q_INVOKABLE void setForwardProxyPassword(const QString &value);
    // Whether the current process can create TUN interfaces (root / CAP_NET_ADMIN).
    bool tunAvailable() const;
    // Theme: 0=follow system, 1=light, 2=dark
    int themeMode() const { return GlobalConfig.uiConfig.themeMode; }
    Q_INVOKABLE void setThemeMode(int mode);
    // Whether the OS is currently in dark mode.
    bool systemDark() const;
    bool autoStartEnabled() const;
    Q_INVOKABLE void setAutoStartEnabled(bool enabled);
    // Real version from build (makespec/VERSION), e.g. 1.0.0
    QString versionString() const { return QString(PLUMBUM_VERSION_STRING); }
    // Language (locale code, e.g. en_US, zh_CN, zh_TW, ru_RU)
    QString language() const { return GlobalConfig.uiConfig.language; }
    Q_INVOKABLE void setLanguage(const QString &code);
    QStringList availableLanguages() const;

  public:
    // Call this once, after ConnectionManager has been created.
    void initialize();

  public slots:
    // Connectivity
    void connectConnection(const QString &connectionId);
    void disconnectConnection();
    void restartConnection();
    void startLatencyTest();
    void startLatencyTestFor(const QString &connectionId);

    // Import & Create
    bool importFromClipboard();
    bool importFromLink(const QString &link);
    bool importFromFile(const QString &filePath, bool importComplex, const QString &namePrefix);
    bool createConnection(const QString &displayName,
                          const QString &protocol,
                          const QString &address,
                          int port,
                          const QString &credential,
                          const QString &method,
                          const QString &transport,
                          bool tls,
                          const QString &serverName,
                          const QString &path);
    QString createGroup(const QString &name);
    void deleteGroup(const QString &groupId);
    void renameGroup(const QString &groupId, const QString &newName);
    void deleteConnection(const QString &connectionId);
    void moveConnectionToGroup(const QString &connectionId, const QString &groupId);
    QString connectionJson(const QString &connectionId) const;
    bool updateConnectionJson(const QString &connectionId, const QString &json);

    // Subscriptions
    void updateSubscription(const QString &groupId);
    void updateAllSubscriptions();
    void setSubscriptionInterval(const QString &groupId, double days);
    QString createSubscription(const QString &name, const QString &url);

    // Misc
    QString groupDisplayName(const QString &groupId) const;
    QString connectionDisplayName(const QString &connectionId) const;
    QString connectionProtocol(const QString &connectionId) const;
    QString connectionAddress(const QString &connectionId) const;
    int connectionPort(const QString &connectionId) const;
    void clearConnectionUsage(const QString &connectionId);
    void clearGroupUsage(const QString &groupId);
    void copyConnectionLink(const QString &connectionId);

  signals:
    void currentGroupIdChanged();
    void connectivityChanged();
    void statsChanged();
    void kernelStatusChanged();
    void settingsChanged();
    void pacModeChanged();
    void themeModeChanged();
    void systemThemeChanged();
    void toastMessage(const QString &message);
    void logMessage(const QString &message);

  private slots:
    void onConnectionCreated(const ConnectionGroupPair &id, const QString &displayName);
    void onConnectionModified(const ConnectionId &id);
    void onConnectionRenamed(const ConnectionId &id, const QString &originalName, const QString &newName);
    void onConnectionRemovedFromGroup(const ConnectionGroupPair &pairId);
    void onConnectionLinkedWithGroup(const ConnectionGroupPair &newPair);
    void onGroupCreated(const GroupId &id, const QString &displayName);
    void onGroupRenamed(const GroupId &id, const QString &oldName, const QString &newName);
    void onGroupDeleted(const GroupId &id, const QList<ConnectionId> &connections);
    void onLatencyTestFinished(const ConnectionId &id, const int average);
    void onConnected(const ConnectionGroupPair &id);
    void onDisconnected(const ConnectionGroupPair &id);
    void onKernelCrashed(const ConnectionGroupPair &id, const QString &errMessage);
    void onStatsAvailable(const ConnectionGroupPair &id, const QMap<StatisticsType, QvStatsSpeedData> &data);
    void onKernelLog(const ConnectionGroupPair &id, const QString &log);
    void onSubscriptionUpdated(const GroupId &id, bool success);

  private:
    void refreshAll();
    void updateConnectivityState();

    ConnectionListModel _connectionModel;
    GroupListModel _groupModel;
    GroupId _currentGroupId;
    bool _connected = false;
    ConnectionGroupPair _connectedPair;
    ConnectionId _connectedConnectionId;
    QString _connectedName;
    //
    QString _upSpeedText;
    QString _downSpeedText;
    QString _upTotalText;
    QString _downTotalText;
    QString _kernelStatusText;
};
