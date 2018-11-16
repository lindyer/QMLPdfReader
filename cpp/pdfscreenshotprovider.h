#ifndef PDFSCREENSHOTPROVIDER_H
#define PDFSCREENSHOTPROVIDER_H

/**
*   @ProjectName:       QMLPdfReader
*   @Brief：
*   @Author:            linjianpeng(lindyer)
*   @Date:              2018-11-15
*   @Note:              Copyright Reserved, Github: https://github.com/lindyer/
*/

#include "poppler-qt5.h"
#include "global.h"
#include "utils/qaesencryption.h"

#include <QObject>
#include <QQuickImageProvider>
#include <QHash>
#include <functional>
#include <QFile>
#include <QImage>
#include <QCryptographicHash>
#include <functional>


//提供PDF快照
class PdfScreenshotProvider: public QObject , public QQuickImageProvider
{
    Q_OBJECT
public:
    explicit PdfScreenshotProvider(QObject *parent = nullptr);

    enum Status {  //文件状态
        StatusInit,
        LoadFileFail,
        LoadFileSuccess,
        VerifyPassword,
        VerifySuccess,
        WriteText,
    };

    enum ChangeType {  //修改类型
        TypeText,
        TypeImage,
        TypeLine
    };

    struct ChangeItem {  //修改具体位置
        qint64 timestamp;
        ChangeType type;
        QPoint pos;
        int pageNum = -1;
        QVariant change;
    };

    struct FileProperties {
        QString path;
        Status status = StatusInit;
        QByteArray data;
        QString password;
        Poppler::Document *document;
        Poppler::Page::Rotation rotation = Poppler::Page::Rotate0;
        float zoomRatio = 1.0;
        bool showRecords = true;         //是否显示记录
        QList<ChangeItem*> changeList;   //未应用的改变
        QList<ChangeItem*> recordList;   //已保存的改变
    };

signals:
    void changeCountChanged(const QString &path,int count);
    void enterPasswordNotify(const QString &path);
    void loadFinishNotify(const QString &path,int pageCount);
    void maxPageWidthChangedNotify(const QString &path,int width);
    void updatePage(const QString &path,int pageNum);

public slots:
    /**
     * @brief addFile
     * @param path
     */
    void addFile(const QString &path,bool showRecords = true);
    /**
     * @brief deleteFile
     * @param path
     */
    void deleteFile(const QString &path);
    /** @discard
     * @brief onVerifyPasswordSuccess
     * @param path
     */
    //void onVerifyPasswordSuccess(const QString &path);
    /**
     * @brief fileBaseName
     * @param path
     * @return
     */
    QString fileBaseName(const QString &path);
    /**
     * @brief pageCount
     * @param path
     * @return
     */
    int pageCount(const QString &path);
    /**
     * @brief setZoomRatio
     * @param path
     * @param ratio
     */
    void setZoomRatio(const QString &path,float ratio);
    /**
     * @brief rotation
     * @param path
     * @param toRight
     */
    void rotation(const QString &path, bool toRight);
    /**
     * @brief addText 添加文本
     * @param path pdf路径
     * @param pageNum 页码
     * @param pos 位置
     * @param text 内容
     */
    void addText(const QString &path,int pageNum,const QPoint &pos,const QString &text);
    /**
     * @brief addImage 添加图像
     * @param path
     * @param pageNum
     * @param pos
     * @param image
     */
    void addImage(const QString &path,int pageNum,const QPoint &pos,const QImage &image);

    /** @discard
     * @brief addTextAnnotation
     * @param path
     * @param pageNum
     * @param pos
     * @param text
     */
    void addLine(const QString &path,int pageNum,const QPoint &startPos,const QPoint &endPos);

    /** @discard
    void addTextAnnotation(const QString &path,int pageNum,const QPoint &pos,const QString &text);
    */

    /** @discard
     * @brief haveUnsavedChange
     * @param path
     * @return
     */
    //bool haveUnsavedChange(const QString &path);
    /** @discard
     * @brief saveChange
     * @param path
     */
    //void saveChange(const QString &path);
    /**
     * @brief undo
     * @param path
     */
    void undo(const QString &path);
    /**
     * @brief initBaseForm
     * @param file
     * @return
     */
    QByteArray initBaseForm(QFile *file);  //写入基础的表单结构
    /**
     * @brief addRecord
     * @param path
     * @param ci
     */
    void addRecord(const QString &path, ChangeItem *ci);

    void removeRecord(const QString &path, ChangeItem *ci);
    /**
     * @brief readAllChangeItem
     * @param path
     * @param encrypt
     * @return
     */
    void readRecordFile(const QString &path);
    QByteArray aesEncode(const QByteArray &text);
    QByteArray aesDecode(const QByteArray &data);
    bool matchPassword(const QString &path, const QString &password);
    bool setPassword(const QString &path,const QString &password);
    bool cancelPassword(const QString &path);
    bool havePassword(const QString &path);
    bool existChangeItem(const QString &path);
    void setShowRecords(const QString &path,bool showRecords);


    // QQuickImageProvider interface
protected:
    //id： 文件名#页码
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

private:
    void loadData(const QByteArray &data,const QString &path);
    FileProperties* findFilePropertiesItem(std::function<bool (FileProperties*)> cond);
    FileProperties *findFilePropertiesItemByPath(const QString &path);
    QFont defaultFont(float ratio = 1.0);
    Poppler::Annotation::Style defaultAnnotationStyle();
    int resolution() const ; //不同设备的分辨率
    void writePageChangeToPainter(QPainter *painter,FileProperties *fp,int pageNum,bool ignoreZoomRatio = false );
    ChangeItem *createChangeItem(const QString &path,int pageNum,const QPoint &pos);
    void checkDocumentMaxWidth(FileProperties* fp);

private:
    QList<FileProperties*> _fileList;
    bool _recordEncrypt = false;
};

#endif // PDFSCREENSHOTPROVIDER_H
