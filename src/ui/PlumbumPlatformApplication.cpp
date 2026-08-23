#include "PlumbumPlatformApplication.hpp"

#include "core/settings/SettingsBackend.hpp"

#include <QSslSocket>
#define QV_MODULE_NAME "PlatformApplication"

#ifdef QT_DEBUG
const static inline QString PLUMBUM_URL_SCHEME = "plumbum-debug";
#else
const static inline QString PLUMBUM_URL_SCHEME = "plumbum";
#endif

QStringList PlumbumPlatformApplication::CheckPrerequisites()
{
    QStringList errors;
    if (!QSslSocket::supportsSsl())
    {
        // Check OpenSSL version for auto-update and subscriptions
        const auto osslReqVersion = QSslSocket::sslLibraryBuildVersionString();
        const auto osslCurVersion = QSslSocket::sslLibraryVersionString();
        LOG("Current OpenSSL version: " + osslCurVersion);
        LOG("Required OpenSSL version: " + osslReqVersion);
        errors << "Qplumbum cannot run without OpenSSL.";
        errors << "This is usually caused by using the wrong version of OpenSSL";
        errors << "Required=" + osslReqVersion + "Current=" + osslCurVersion;
    }
    return errors + checkPrerequisitesInternal();
}

bool PlumbumPlatformApplication::Initialize()
{
    QString errorMessage;
    bool canContinue;
    const auto hasError = parseCommandLine(&errorMessage, &canContinue);
    if (hasError)
    {
        LOG("Command line:" QVLOG_A(errorMessage));
        if (!canContinue)
        {
            LOG("Fatal, Qplumbum cannot continue.");
            return false;
        }
        else
        {
            LOG("Non-fatal error, continue starting up.");
        }
    }

    connect(this, &PlumbumPlatformApplication::aboutToQuit, this, &PlumbumPlatformApplication::quitInternal);
#ifndef PLUMBUM_NO_SINGLEAPPLICATON
    connect(this, &SingleApplication::receivedMessage, this, &PlumbumPlatformApplication::onMessageReceived, Qt::QueuedConnection);
    if (isSecondary())
    {
        StartupArguments.version = PLUMBUM_VERSION_STRING;
        StartupArguments.buildVersion = PLUMBUM_VERSION_BUILD;
        StartupArguments.fullArgs = arguments();
        if (StartupArguments.arguments.isEmpty())
            StartupArguments.arguments << PlumbumStartupArguments::NORMAL;
        bool status = sendMessage(JsonToString(StartupArguments.toJson(), QJsonDocument::Compact).toUtf8());
        if (!status)
            LOG("Cannot send message.");
        SetExitReason(EXIT_SECONDARY_INSTANCE);
        return false;
    }
#endif

#ifdef PLUMBUM_GUI
    connect(this, &QGuiApplication::commitDataRequest, [] {
        RouteManager->SaveRoutes();
        ConnectionManager->SaveConnectionConfig();
        PluginHost->SavePluginSettings();
        SaveGlobalSettings();
    });
#endif

    // Install a default translater. From the OS/DE
    PlumbumTranslator = std::make_unique<QvTranslator>();
    const auto osLanguage = QLocale::system().name();
    PlumbumTranslator->InstallTranslation(osLanguage);
    const auto allTranslations = PlumbumTranslator->GetAvailableLanguages();
    //
    LocateConfiguration();
    const auto configuredLanguage = GlobalConfig.uiConfig.language;
    const auto followsSystem = configuredLanguage.isEmpty() || configuredLanguage == "system";
    auto language = followsSystem ? osLanguage : configuredLanguage;
    if (!allTranslations.contains(language))
    {
        const auto languagePrefix = QLocale(language).name().section('_', 0, 0);
        const auto matchingLanguage = std::find_if(allTranslations.cbegin(), allTranslations.cend(), [&](const auto &available) {
            return available.startsWith(languagePrefix + "_");
        });
        if (matchingLanguage != allTranslations.cend())
            language = *matchingLanguage;
        else if (!allTranslations.isEmpty())
            language = allTranslations.first();
    }

    if (!PlumbumTranslator->InstallTranslation(language))
    {
        // Silently fall back to English when no translation file is available.
        // (e.g. a fresh build without generated .qm files)
        PlumbumTranslator->InstallTranslation("en_US");
    }

    return true;
}

PlumbumExitReason PlumbumPlatformApplication::RunPlumbum()
{
    PluginHost = new QvPluginHost();
    RouteManager = new RouteHandler();
    ConnectionManager = new QvConfigHandler();
    return runPlumbumInternal();
}

void PlumbumPlatformApplication::quitInternal()
{
    // Do not change the order.
    ConnectionManager->StopConnection();
    RouteManager->SaveRoutes();
    ConnectionManager->SaveConnectionConfig();
    PluginHost->SavePluginSettings();
    SaveGlobalSettings();
    terminateUIInternal();
    delete ConnectionManager;
    delete RouteManager;
    delete PluginHost;
    ConnectionManager = nullptr;
    RouteManager = nullptr;
    PluginHost = nullptr;
}

bool PlumbumPlatformApplication::parseCommandLine(QString *errorMessage, bool *canContinue)
{
    *canContinue = true;
    QStringList filteredArgs;
    for (const auto &arg : arguments())
    {
        filteredArgs << arg;
    }
    QCommandLineParser parser;
    //
    QCommandLineOption noAPIOption("noAPI", QObject::tr("Disable gRPC API subsystem"));
    QCommandLineOption noPluginsOption("noPlugin", QObject::tr("Disable plugins feature"));
    QCommandLineOption debugLogOption("debug", QObject::tr("Enable debug output"));
    QCommandLineOption noAutoConnectionOption("noAutoConnection", QObject::tr("Do not automatically connect"));
    QCommandLineOption disconnectOption("disconnect", QObject::tr("Stop current connection"));
    QCommandLineOption reconnectOption("reconnect", QObject::tr("Reconnect last connection"));
    QCommandLineOption exitOption("exit", QObject::tr("Exit Qplumbum"));
    //
    parser.setApplicationDescription(QObject::tr("Qplumbum - A Linux Qt6 frontend for V2Ray."));
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);
    //
    parser.addOption(noAPIOption);
    parser.addOption(noPluginsOption);
    parser.addOption(debugLogOption);
    parser.addOption(noAutoConnectionOption);
    parser.addOption(disconnectOption);
    parser.addOption(reconnectOption);
    parser.addOption(exitOption);
    //
    const auto helpOption = parser.addHelpOption();
    const auto versionOption = parser.addVersionOption();

    if (!parser.parse(filteredArgs))
    {
        *canContinue = true;
        *errorMessage = parser.errorText();
        return false;
    }

    if (parser.isSet(versionOption))
    {
        parser.showVersion();
        return true;
    }

    if (parser.isSet(helpOption))
    {
        parser.showHelp();
        return true;
    }

    for (const auto &arg : parser.positionalArguments())
    {
        if (arg.startsWith(PLUMBUM_URL_SCHEME + "://"))
        {
            StartupArguments.arguments << PlumbumStartupArguments::PLUMBUM_LINK;
            StartupArguments.links << arg;
        }
    }

    if (parser.isSet(exitOption))
    {
        DEBUG("disconnectOption is set.");
        StartupArguments.arguments << PlumbumStartupArguments::EXIT;
    }

    if (parser.isSet(disconnectOption))
    {
        DEBUG("disconnectOption is set.");
        StartupArguments.arguments << PlumbumStartupArguments::DISCONNECT;
    }

    if (parser.isSet(reconnectOption))
    {
        DEBUG("reconnectOption is set.");
        StartupArguments.arguments << PlumbumStartupArguments::RECONNECT;
    }

#define ProcessExtraStartupOptions(option)                                                                                                           \
    DEBUG("Startup Options:" QVLOG_A(parser.isSet(option##Option)));                                                                                 \
    StartupArguments.option = parser.isSet(option##Option);

    ProcessExtraStartupOptions(noAPI);
    ProcessExtraStartupOptions(debugLog);
    ProcessExtraStartupOptions(noAutoConnection);
    ProcessExtraStartupOptions(noPlugins);
    return true;
}
