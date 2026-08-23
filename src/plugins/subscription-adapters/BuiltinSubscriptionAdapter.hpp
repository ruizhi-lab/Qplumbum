#pragma once

#include "QvPluginInterface.hpp"

#include <QObject>
#include <QtPlugin>

using namespace Qv2rayPlugin;

class InternalSubscriptionSupportPlugin
    : public QObject
    , public Qv2rayInterface
{
    Q_INTERFACES(Qv2rayPlugin::Qv2rayInterface)
    Q_PLUGIN_METADATA(IID Qv2rayInterface_IID)
    Q_OBJECT
  public:
    //
    // Basic metainfo of this plugin
    const QvPluginMetadata GetMetadata() const override
    {
        return { "Builtin Subscription Support",          //
                 "Qplumbum Core Workgroup",                 //
                 "builtin_subscription_support",          //
                 "Basic subscription support for Qplumbum", //
                 PLUMBUM_VERSION_STRING,                   //
                 "ruizhi-lab/Qplumbum",                     //
                 { COMPONENT_SUBSCRIPTION_ADAPTER },
                 UPDATE_NONE };
    }

    bool InitializePlugin(const QString &, const QJsonObject &) override;
    //
  signals:
    void PluginLog(const QString &) const override;
    void PluginErrorMessageBox(const QString &, const QString &) const override;
};
