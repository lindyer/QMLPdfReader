/**
*   @ProjectName:       QMLPdfReader
*   @Brief：
*   @Author:            linjianpeng(lindyer)
*   @Date:              2018-11-16
*   @Note:              Copyright Reserved, Github: https://github.com/lindyer/
*/
#include "global.h"

Global *Global::global = nullptr;
Global::Global()
{
}

Global *Global::instance()
{
    if(!global) {
        global = new Global();
    }
    return global;
}

QString Global::urlBaseName(const QUrl &url)
{
    QUrl u(url);
    QString fn = u.fileName();
    QStringList sl = fn.split(".");
    if(sl.isEmpty()){
        return QString();
    }
    return sl.first();
}

QString Global::urlPath(const QUrl &url)
{
    QString path = url.path();
    if(path.isEmpty()){
        return QString();
    }
    return path.remove(0,1);
}

float Global::fontSizeRatio()
{
    return json->getDouble("fontSizeRatio");
}

void Global::loadConfig()
{
    if(json) {
        delete json;
    }
    json = new Json(configFile,true);
}
