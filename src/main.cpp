#include <QtGlobal>

#ifdef PLUMBUM_CLI
#include "ui/cli/PlumbumCliApplication.hpp"
#endif

#ifdef PLUMBUM_GUI_QWIDGETS
#include "ui/widgets/PlumbumWidgetApplication.hpp"
#endif

#ifdef PLUMBUM_GUI_QML
#include "ui/qml/PlumbumQMLApplication.hpp"
#endif

#include "utils/QvHelpers.hpp"

#include <csignal>

#include <unistd.h>

#define QV_MODULE_NAME "Init"

int globalArgc;
char **globalArgv;

void BootstrapMessageBox(const QString &title, const QString &text)
{
#ifdef PLUMBUM_GUI
    if (qApp)
    {
        QMessageBox::warning(nullptr, title, text);
    }
    else
    {
        QApplication p(globalArgc, globalArgv);
        QMessageBox::warning(nullptr, title, text);
    }
#else
    std::cout << title.toStdString() << NEWLINE << text.toStdString() << std::endl;
#endif
}

const QString SayLastWords() noexcept
{
    QStringList msg;
    msg << "------- BEGIN PLUMBUM CRASH REPORT -------";

    if (KernelInstance)
    {
        msg << "Active Kernel Instances:";
        const auto kernels = KernelInstance->GetActiveKernelProtocols();
        msg << JsonToString(JsonStructHelper::Serialize(static_cast<QList<QString>>(kernels)).toArray(), QJsonDocument::Compact);
        msg << "Current Connection:";
        //
        const auto currentConnection = KernelInstance->CurrentConnection();
        msg << JsonToString(currentConnection.toJson(), QJsonDocument::Compact);
        msg << NEWLINE;
        //
        if (ConnectionManager && !currentConnection.isEmpty())
        {
            msg << "Active Connection Settings:";
            const auto connection = ConnectionManager->GetConnectionMetaObject(currentConnection.connectionId);
            auto group = ConnectionManager->GetGroupMetaObject(currentConnection.groupId);
            //
            // Do not collect private data.
            // msg << NEWLINE;
            // msg << JsonToString(ConnectionManager->GetConnectionRoot(currentConnection.connectionId));
            group.subscriptionOption.address = "HIDDEN";
            //
            msg << JsonToString(connection.toJson(), QJsonDocument::Compact);
            msg << NEWLINE;
            msg << "Group:";
            msg << JsonToString(group.toJson(), QJsonDocument::Compact);
            msg << NEWLINE;
        }
    }

    if (PluginHost)
    {
        msg << "Plugins:";
        const auto plugins = PluginHost->AllPlugins();
        for (const auto &plugin : plugins)
        {
            const auto data = PluginHost->GetPlugin(plugin)->metadata;
            QList<QString> dataList;
            dataList << data.Name;
            dataList << data.Author;
            dataList << data.InternalName;
            dataList << data.Description;
            msg << JsonToString(JsonStructHelper::Serialize(dataList).toArray(), QJsonDocument::Compact);
        }
        msg << NEWLINE;
    }

    if (QvCoreApplication)
    {
        msg << "GlobalConfig:";
        msg << JsonToString(GlobalConfig.toJson(), QJsonDocument::Compact);
    }

    msg << "------- END OF PLUMBUM CRASH REPORT -------";
    return msg.join(NEWLINE);
}

void signalHandler(int signum)
{
    if (signum == SIGTRAP)
    {
        exit(-99);
        return;
    }
    std::cout << "Qplumbum: Interrupt signal (" << signum << ") received." << std::endl;

    if (signum == SIGTERM)
    {
        if (qApp)
            qApp->exit();
        return;
    }
    std::cout << "Collecting StackTrace" << std::endl;
    const auto msg = "Signal: " + QSTRN(signum) + NEWLINE + SayLastWords();
    std::cout << msg.toStdString() << std::endl;

    if (qApp && QvCoreApplication)
    {
        QDir().mkpath(PLUMBUM_CONFIG_DIR + "bugreport/");
        const auto filePath = PLUMBUM_CONFIG_DIR + "bugreport/QvBugReport_" + QSTRN(system_clock::to_time_t(system_clock::now())) + ".stacktrace";
        StringToFile(msg, filePath);
        std::cout << "Backtrace saved in: " + filePath.toStdString() << std::endl;
        const auto message = QObject::tr("Qplumbum has encountered an uncaught exception: ") + NEWLINE +              //
                             QObject::tr("Please report a bug via Github with the file located here: ") + NEWLINE + //
                             NEWLINE + filePath;
        BootstrapMessageBox("UNCAUGHT EXCEPTION", message);
    }

#ifdef QT_DEBUG
    exit(-99);
#else
    kill(getpid(), SIGTRAP);
#endif
}

int main(int argc, char *argv[])
{
    globalArgc = argc;
    globalArgv = argv;
    // Register signal handlers.
    signal(SIGABRT, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGTERM, signalHandler);
    signal(SIGHUP, signalHandler);
    signal(SIGKILL, signalHandler);
    //
    // This line must be called before any other ones, since we are using these
    // values to identify instances.
    QCoreApplication::setApplicationVersion(PLUMBUM_VERSION_STRING);

#ifdef QT_DEBUG
    QCoreApplication::setApplicationName("plumbum_debug");
#else
    QCoreApplication::setApplicationName("plumbum");
#endif

#ifdef PLUMBUM_GUI
    QApplication::setApplicationDisplayName("Qplumbum");
#endif

#ifdef QT_DEBUG
    std::cerr << "WARNING: ================ This is a debug build, many features are not stable enough. ================" << std::endl;
#endif

    if (qEnvironmentVariableIsSet("PLUMBUM_NO_SCALE_FACTORS"))
    {
        LOG("Force set QT_SCALE_FACTOR to 1.");
        DEBUG("UI", "Original QT_SCALE_FACTOR was:", qEnvironmentVariable("QT_SCALE_FACTOR"));
        qputenv("QT_SCALE_FACTOR", "1");
    }
    else
    {
        DEBUG("High DPI scaling is enabled.");
#ifdef PLUMBUM_GUI
        QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
#endif
    }

    PlumbumApplication app(argc, argv);
    if (const auto list = app.CheckPrerequisites(); !list.isEmpty())
    {
        BootstrapMessageBox("Qplumbum Prerequisites Check Failed", list.join(NEWLINE));
        return PlumbumExitReason::EXIT_PRECONDITION_FAILED;
    }

    if (!app.Initialize())
    {
        const auto reason = app.GetExitReason();
        if (reason == EXIT_INITIALIZATION_FAILED)
        {
            BootstrapMessageBox("Qplumbum Initialization Failed", "PreInitialization Failed." NEWLINE "For more information, please see the log.");
            LOG("Qplumbum initialization failed:", reason);
        }
        return reason;
    }

    signal(SIGUSR1, [](int) { ConnectionManager->RestartConnection(); });
    signal(SIGUSR2, [](int) { ConnectionManager->StopConnection(); });

    app.RunPlumbum();
    const auto reason = app.GetExitReason();
    if (reason == EXIT_NEW_VERSION_TRIGGER)
    {
        LOG("Starting new version of Qplumbum: " + app.StartupArguments._qvNewVersionPath);
        QProcess::startDetached(app.StartupArguments._qvNewVersionPath, {});
    }
    return reason;
}
