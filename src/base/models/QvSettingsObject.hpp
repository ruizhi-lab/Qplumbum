#pragma once
#include "base/models/QvConfigIdentifier.hpp"
#include "base/models/QvCoreSettings.hpp"
#include "base/models/QvSafeType.hpp"

#include <chrono>

constexpr int PLUMBUM_CONFIG_VERSION = 14;

namespace Plumbum::base::config
{
    struct QvGraphPenConfig
    {
        int R = 150, G = 150, B = 150;
        float width = 1.5f;
        Qt::PenStyle style = Qt::SolidLine;
        QvGraphPenConfig(){};
        QvGraphPenConfig(int R, int G, int B, float w, Qt::PenStyle s)
        {
            this->R = R;
            this->G = G;
            this->B = B;
            this->width = w;
            this->style = s;
        };
        friend bool operator==(const QvGraphPenConfig &one, const QvGraphPenConfig &another)
        {
            return one.R == another.R && one.G == another.G && one.B == another.B && one.width == another.width && one.style == another.style;
        }
        JSONSTRUCT_REGISTER(QvGraphPenConfig, F(R, G, B, width, style))
    };

    struct PlumbumConfig_Graph
    {
        bool useOutboundStats = true;
        bool hasDirectStats = true;
        safetype::QvEnumMap<StatisticsType, safetype::QvPair<QvGraphPenConfig>> colorConfig;
        JSONSTRUCT_COMPARE(PlumbumConfig_Graph, useOutboundStats, hasDirectStats, colorConfig)
        JSONSTRUCT_REGISTER(PlumbumConfig_Graph, F(useOutboundStats, hasDirectStats, colorConfig))
        const static inline QvPair<QvGraphPenConfig> DefaultPen{ { 134, 196, 63, 1.5f, Qt::SolidLine }, { 50, 153, 255, 1.5f, Qt::SolidLine } };
        const static inline QvPair<QvGraphPenConfig> DirectPen{ { 0, 210, 240, 1.5f, Qt::DotLine }, { 235, 220, 42, 1.5f, Qt::DotLine } };
    };

    struct PlumbumConfig_UI
    {
        QString theme = "Fusion";
        // Keep the system locale as the default; an explicit language can be
        // selected from the UI and is stored as its locale code.
        QString language = "system";
        QList<ConnectionGroupPair> recentConnections;
        PlumbumConfig_Graph graphConfig;
        bool quietMode = false;
        bool useDarkTheme = false;
        // Theme mode: 0=follow system, 1=light, 2=dark
        int themeMode = 0;
        bool useGlyphTrayIcon = true;
        bool useDarkTrayIcon = false;
        int maximumLogLines = 500;
        int maxJumpListCount = 20;
        bool useOldShareLinkFormat = false;
        bool startMinimized = true;
        bool exitByCloseEvent = false;
        JSONSTRUCT_COMPARE(PlumbumConfig_UI, theme, language, quietMode, graphConfig, useDarkTheme, themeMode, useDarkTrayIcon, useGlyphTrayIcon,
                           maximumLogLines, maxJumpListCount, recentConnections, useOldShareLinkFormat, startMinimized, exitByCloseEvent)
        JSONSTRUCT_REGISTER(PlumbumConfig_UI, F(theme, language, quietMode, graphConfig, useDarkTheme, themeMode, useDarkTrayIcon, useGlyphTrayIcon,
                                               maximumLogLines, maxJumpListCount, recentConnections, useOldShareLinkFormat, startMinimized, exitByCloseEvent))
    };

    struct PlumbumConfig_Plugin
    {
        QMap<QString, bool> pluginStates;
        bool v2rayIntegration = true;
        int portAllocationStart = 15000;
        JSONSTRUCT_COMPARE(PlumbumConfig_Plugin, pluginStates, v2rayIntegration, portAllocationStart)
        JSONSTRUCT_REGISTER(PlumbumConfig_Plugin, F(pluginStates, v2rayIntegration, portAllocationStart))
    };

    struct PlumbumConfig_Kernel
    {
        bool enableAPI = true;
        int statsPort = 15490;
        //
        QString v2CorePath_linux;
        QString v2AssetsPath_linux;
#define _VARNAME_VCOREPATH_ v2CorePath_linux
#define _VARNAME_VASSETSPATH_ v2AssetsPath_linux

        inline const QString KernelPath(const QString &path = "")
        {
            return path.isEmpty() ? _VARNAME_VCOREPATH_ : _VARNAME_VCOREPATH_ = path;
        }
        inline const QString AssetsPath(const QString &path = "")
        {
            return path.isEmpty() ? _VARNAME_VASSETSPATH_ : _VARNAME_VASSETSPATH_ = path;
        }

#undef _VARNAME_VCOREPATH_
#undef _VARNAME_VASSETSPATH_

        JSONSTRUCT_COMPARE(PlumbumConfig_Kernel, enableAPI, statsPort, //
                           v2CorePath_linux, v2AssetsPath_linux)
        JSONSTRUCT_REGISTER(PlumbumConfig_Kernel,
                            F(enableAPI, statsPort),
                            F(v2CorePath_linux, v2AssetsPath_linux))
    };

    struct PlumbumConfig_Update
    {
        enum UpdateChannel
        {
            CHANNEL_STABLE = 0,
            CHANNEL_TESTING = 1
        };
        UpdateChannel updateChannel = CHANNEL_STABLE;
        QString ignoredVersion;
        JSONSTRUCT_COMPARE(PlumbumConfig_Update, updateChannel, ignoredVersion)
        JSONSTRUCT_REGISTER(PlumbumConfig_Update, F(ignoredVersion, updateChannel))
    };

    struct PlumbumConfig_Advanced
    {
        bool testLatencyPeriodically = false;
        bool disableSystemRoot = false;
        bool testLatencyOnConnected = false;
        JSONSTRUCT_COMPARE(PlumbumConfig_Advanced, testLatencyPeriodically, disableSystemRoot, testLatencyOnConnected)
        JSONSTRUCT_REGISTER(PlumbumConfig_Advanced, F(testLatencyPeriodically, disableSystemRoot, testLatencyOnConnected))
    };

    enum PlumbumLatencyTestingMethod
    {
        TCPING = 0,
        ICMPING = 1,
        REALPING = 2
    };

    struct PlumbumConfig_Network
    {
        enum PlumbumProxyType
        {
            QVPROXY_NONE = 0,
            QVPROXY_SYSTEM = 1,
            QVPROXY_CUSTOM = 2
        };

        PlumbumLatencyTestingMethod latencyTestingMethod = TCPING;
        QString latencyRealPingTestURL = "https://www.google.com";
        PlumbumProxyType proxyType = QVPROXY_NONE;
        QString address = "127.0.0.1";
        QString type = "http";
        int port = 8000;
        QString userAgent = "Qplumbum/$VERSION WebRequestHelper";
        JSONSTRUCT_COMPARE(PlumbumConfig_Network, latencyTestingMethod, latencyRealPingTestURL, proxyType, type, address, port, userAgent)
        JSONSTRUCT_REGISTER(PlumbumConfig_Network, F(latencyTestingMethod, latencyRealPingTestURL, proxyType, type, address, port, userAgent))
    };

    enum PlumbumAutoConnectionBehavior
    {
        AUTO_CONNECTION_NONE = 0,
        AUTO_CONNECTION_FIXED = 1,
        AUTO_CONNECTION_LAST_CONNECTED = 2
    };

    struct PlumbumConfigObject
    {
        int config_version;
        int logLevel = 0;
        //
        ConnectionGroupPair autoStartId;
        ConnectionGroupPair lastConnectedId;
        PlumbumAutoConnectionBehavior autoStartBehavior = AUTO_CONNECTION_NONE;
        //
        PlumbumConfig_UI uiConfig;
        PlumbumConfig_Plugin pluginConfig;
        PlumbumConfig_Kernel kernelConfig;
        PlumbumConfig_Update updateConfig;
        PlumbumConfig_Network networkConfig;
        QvConfig_Inbounds inboundConfig;
        QvConfig_Outbounds outboundConfig;
        PlumbumConfig_Advanced advancedConfig;
        GroupRoutingConfig defaultRouteConfig;

        explicit PlumbumConfigObject()
        {
            config_version = PLUMBUM_CONFIG_VERSION;
        }
        Q_DISABLE_COPY_MOVE(PlumbumConfigObject);
        JSONSTRUCT_COMPARE(PlumbumConfigObject, config_version, logLevel, autoStartId, lastConnectedId, autoStartBehavior, uiConfig, pluginConfig,
                           kernelConfig, updateConfig, networkConfig, inboundConfig, outboundConfig, advancedConfig, defaultRouteConfig)
        JSONSTRUCT_REGISTER_NOCOPYMOVE(PlumbumConfigObject,                                                                   //
                                       A(config_version, autoStartId, lastConnectedId, autoStartBehavior, logLevel),         //
                                       A(uiConfig, advancedConfig, pluginConfig, updateConfig, kernelConfig, networkConfig), //
                                       A(inboundConfig, outboundConfig, defaultRouteConfig))
    };
} // namespace Plumbum::base::config
