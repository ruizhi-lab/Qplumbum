#include "PlumbumWidgetApplication.hpp"

#include "base/PlumbumBase.hpp"
#include "components/translations/QvTranslator.hpp"
#include "core/settings/SettingsBackend.hpp"
#include "ui/widgets/styles/StyleManager.hpp"
#include "ui/widgets/windows/w_MainWindow.hpp"
#include "utils/QvHelpers.hpp"

#include <QApplication>
#include <QDesktopServices>
#include <QMessageBox>
#include <QUrl>
#include <QUrlQuery>

#define QV_MODULE_NAME "WidgetApplication"

constexpr auto PLUMBUM_WIDGETUI_STATE_FILENAME = "UIState.json";

PlumbumWidgetApplication::PlumbumWidgetApplication(int &argc, char *argv[]) : PlumbumPlatformApplication(argc, argv)
{
}

QStringList PlumbumWidgetApplication::checkPrerequisitesInternal()
{
    return {};
}

void PlumbumWidgetApplication::terminateUIInternal()
{
    delete mainWindow;
    delete hTray;
    delete StyleManager;
    StringToFile(JsonToString(UIStates), PLUMBUM_CONFIG_DIR + PLUMBUM_WIDGETUI_STATE_FILENAME);
}

#ifndef PLUMBUM_NO_SINGLEAPPLICATON
void PlumbumWidgetApplication::onMessageReceived(quint32 clientId, QByteArray _msg)
{
    // Sometimes SingleApplication will send message with clientId == 0, ignore them.
    if (clientId == instanceId())
        return;

    if (!isInitialized)
        return;

    const auto msg = PlumbumStartupArguments::fromJson(JsonFromString(_msg));
    LOG("Client ID:", clientId, ", message received, version:", msg.buildVersion);
    DEBUG(_msg);
    //
    if (msg.buildVersion > PLUMBUM_VERSION_BUILD)
    {
        const auto newPath = msg.fullArgs.first();
        QString message;
        message += tr("A new version of Qplumbum is starting:") + NEWLINE;
        message += NEWLINE;
        message += tr("New version information: ") + NEWLINE;
        message += tr("Version: %1:%2").arg(msg.version).arg(msg.buildVersion) + NEWLINE;
        message += tr("Path: %1").arg(newPath) + NEWLINE;
        message += NEWLINE;
        message += tr("Do you want to exit and launch that new version?");

        const auto result = QvMessageBoxAsk(nullptr, tr("New version detected"), message);
        if (result == Yes)
        {
            StartupArguments._qvNewVersionPath = newPath;
            SetExitReason(EXIT_NEW_VERSION_TRIGGER);
            QCoreApplication::quit();
        }
    }

    for (const auto &argument : msg.arguments)
    {
        switch (argument)
        {
            case PlumbumStartupArguments::EXIT:
            {
                SetExitReason(EXIT_NORMAL);
                quit();
                break;
            }
            case PlumbumStartupArguments::NORMAL:
            {
                mainWindow->show();
                mainWindow->raise();
                mainWindow->activateWindow();
                break;
            }
            case PlumbumStartupArguments::RECONNECT:
            {
                ConnectionManager->RestartConnection();
                break;
            }
            case PlumbumStartupArguments::DISCONNECT:
            {
                ConnectionManager->StopConnection();
                break;
            }
            case PlumbumStartupArguments::PLUMBUM_LINK:
            {
                for (const auto &link : msg.links)
                {
                    const auto url = QUrl::fromUserInput(link);
                    const auto command = url.host();
                    auto subcommands = url.path().split("/");
                    subcommands.removeAll("");
                    QMap<QString, QString> args;
                    for (const auto &kvp : QUrlQuery(url).queryItems())
                    {
                        args.insert(kvp.first, kvp.second);
                    }
                    if (command == "open")
                    {
                        emit mainWindow->ProcessCommand(command, subcommands, args);
                    }
                }
                break;
            }
        }
    }
}
#endif

PlumbumExitReason PlumbumWidgetApplication::runPlumbumInternal()
{
    setQuitOnLastWindowClosed(false);
    hTray = new QSystemTrayIcon();
    StyleManager = new QvStyleManager();
    StyleManager->ApplyStyle(GlobalConfig.uiConfig.theme);
    // Show MainWindow
    UIStates = JsonFromString(StringFromFile(PLUMBUM_CONFIG_DIR + PLUMBUM_WIDGETUI_STATE_FILENAME));
    mainWindow = new MainWindow();
    if (StartupArguments.arguments.contains(PlumbumStartupArguments::PLUMBUM_LINK))
    {
        for (const auto &link : StartupArguments.links)
        {
            const auto url = QUrl::fromUserInput(link);
            const auto command = url.host();
            auto subcommands = url.path().split("/");
            subcommands.removeAll("");
            QMap<QString, QString> args;
            for (const auto &kvp : QUrlQuery(url).queryItems())
            {
                args.insert(kvp.first, kvp.second);
            }
            if (command == "open")
            {
                emit mainWindow->ProcessCommand(command, subcommands, args);
            }
        }
    }
    isInitialized = true;
    return (PlumbumExitReason) exec();
}

void PlumbumWidgetApplication::OpenURL(const QString &url)
{
    QDesktopServices::openUrl(url);
}

void PlumbumWidgetApplication::MessageBoxWarn(QWidget *parent, const QString &title, const QString &text)
{
    QMessageBox::warning(parent, title, text, QMessageBox::Ok);
}

void PlumbumWidgetApplication::MessageBoxInfo(QWidget *parent, const QString &title, const QString &text)
{
    QMessageBox::information(parent, title, text, QMessageBox::Ok);
}

MessageOpt PlumbumWidgetApplication::MessageBoxAsk(QWidget *parent, const QString &title, const QString &text, const QList<MessageOpt> &buttons)
{
    QFlags<QMessageBox::StandardButton> btns;
    for (const auto &b : buttons)
    {
        btns.setFlag(MessageBoxButtonMap[b]);
    }
    return MessageBoxButtonMap.key(QMessageBox::question(parent, title, text, btns));
}

void PlumbumWidgetApplication::ShowTrayMessage(const QString &m, int msecs)
{
    hTray->showMessage("Qplumbum", m, QIcon(":/assets/icons/plumbum.png"), msecs);
}
