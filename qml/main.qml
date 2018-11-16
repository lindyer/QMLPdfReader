/**
*   @ProjectName:       QMLPdfReader
*   @Brief：
*   @Author:            linjianpeng(lindyer)
*   @Date:              2018-11-16
*   @Note:              Copyright Reserved, Github: https://github.com/lindyer/
*/

import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("PDF查看器")


    PdfViewer {
        id: _pdfViewer
        anchors.fill: parent
    }

    function rw(value) {
        return value;
    }

    function rh(value) {
        return value;
    }

    function rfs(value) {
        return value;
    }
}
