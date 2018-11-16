/**
*   @ProjectName:       QMLPdfReader
*   @Brief：
*   @Author:            linjianpeng(lindyer)
*   @Date:              2018-11-16
*   @Note:              Copyright Reserved, Github: https://github.com/lindyer/
*/

#include "cpp/pdfscreenshotprovider.h"
#include "cpp/global.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    PdfScreenshotProvider *pdfScreenShotProvider = new PdfScreenshotProvider();
    engine.addImageProvider("PdfScreenshot",pdfScreenShotProvider);
    engine.rootContext()->setContextProperty("pdfUtil",pdfScreenShotProvider);
    engine.rootContext()->setContextProperty("global",Global::instance());
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
