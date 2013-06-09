#ifndef SYSINF_H
#define SYSINF_H

#include <QDeclarativeExtensionPlugin>

class SysInf : public QDeclarativeExtensionPlugin
{
    Q_OBJECT
#if QT_VERSION >= 0x050000
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")
#endif

public:
    void registerTypes(const char *uri);
};

#endif // SYSINF_H
