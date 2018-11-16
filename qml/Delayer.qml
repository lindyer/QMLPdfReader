/**
*   @ProjectName:       QMLPdfReader
*   @Brief：
*   @Author:            linjianpeng(lindyer)
*   @Date:              2018-11-16
*   @Note:              Copyright Reserved, Github: https://github.com/lindyer/
*/

import QtQuick 2.0

Timer {
    id: _root
    property var callback
    repeat: false

    function run(interval) {
        _root.interval = interval
        running = true
    }

    onTriggered: {
        callback()
    }
}
