#include "PlumbumBaseApplication.hpp"

#include "components/translations/QvTranslator.hpp"
#include "core/settings/SettingsBackend.hpp"
#include "utils/QvHelpers.hpp"

#define QV_MODULE_NAME "BaseApplication"
inline QString makeAbs(const QString &p)
{
    return QDir(p).absolutePath();
}

PlumbumApplicationInterface::PlumbumApplicationInterface()
{
    ConfigObject = new PlumbumConfigObject;
    QvCoreApplication = this;
    LOG("Qplumbum", PLUMBUM_VERSION_STRING, "on", QSysInfo::prettyProductName(), QSysInfo::currentCpuArchitecture());
    DEBUG("Qplumbum Start Time: ", QTime::currentTime().msecsSinceStartOfDay());
    DEBUG("PLUMBUM_BUILD_INFO", PLUMBUM_BUILD_INFO);
    DEBUG("PLUMBUM_BUILD_EXTRA_INFO", PLUMBUM_BUILD_EXTRA_INFO);
    DEBUG("PLUMBUM_BUILD_NUMBER", QSTRN(PLUMBUM_VERSION_BUILD));
    QStringList licenseList;
    licenseList << "This program comes with ABSOLUTELY NO WARRANTY.";
    licenseList << "This is free software, and you are welcome to redistribute it";
    licenseList << "under certain conditions.";
    licenseList << "Copyright (c) 2019-2021 Qplumbum Development Group.";
    licenseList << "Third-party libraries that have been used in this program can be found in the About page.";
    LOG(licenseList.join(NEWLINE));
}

PlumbumApplicationInterface::~PlumbumApplicationInterface()
{
    delete ConfigObject;
    QvCoreApplication = nullptr;
}

QStringList PlumbumApplicationInterface::GetAssetsPaths(const QString &dirName) const
{
    // Configuration Path
    QStringList list;

    if (qEnvironmentVariableIsSet("PLUMBUM_RESOURCES_PATH"))
        list << makeAbs(qEnvironmentVariable("PLUMBUM_RESOURCES_PATH") + "/" + dirName);

    // Standard application-local resources.
    list << makeAbs(QCoreApplication::applicationDirPath() + "/" + dirName);
    list << makeAbs(PLUMBUM_CONFIG_DIR + dirName);
    list << ":/" + dirName;

    list << QStandardPaths::locateAll(QStandardPaths::AppDataLocation, dirName, QStandardPaths::LocateDirectory);
    list << QStandardPaths::locateAll(QStandardPaths::AppConfigLocation, dirName, QStandardPaths::LocateDirectory);

    // Standard local installs place the executable in bin/ and translations
    // in ../share/plumbum/lang. APPIMAGE uses the same layout, so this path
    // must not be restricted to the APPIMAGE environment variable.
    list << makeAbs(QCoreApplication::applicationDirPath() + "/../share/plumbum/" + dirName);

    if (qEnvironmentVariableIsSet("SNAP"))
        list << makeAbs(qEnvironmentVariable("SNAP") + "/usr/share/plumbum/" + dirName);

    if (qEnvironmentVariableIsSet("XDG_DATA_DIRS"))
        list << makeAbs(qEnvironmentVariable("XDG_DATA_DIRS") + "/" + dirName);

    list << makeAbs("/usr/local/share/plumbum/" + dirName);
    list << makeAbs("/usr/local/lib/plumbum/" + dirName);
    list << makeAbs("/usr/share/plumbum/" + dirName);
    list << makeAbs("/usr/lib/plumbum/" + dirName);
    list << makeAbs("/lib/plumbum/" + dirName);

    list.removeDuplicates();
    return list;
}
