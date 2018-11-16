/**
*   @ProjectName:       QMLPdfReader
*   @Brief：
*   @Author:            linjianpeng(lindyer)
*   @Date:              2018-11-16
*   @Note:              Copyright Reserved, Github: https://github.com/lindyer/
*/

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

Rectangle {
    id: _root
    color: "gray"
    //property string fileName: "C:/Users/C24/Desktop/1.pdf"
    signal updateImageNotify(string path)
    clip: true
    property string fnOpen: "open"
    property string fnUndo: "undo"
    property string fnPreviousPage: "previousPage"
    property string fnNextPage: "nextPage"
    property string fnZoomIn: "zoomIn"
    property string fnZoomReset: "zoomReset"
    property string fnZoomOut: "zoomOut"
    property string fnRotationLeft: "rotationLeft"
    property string fnRotationRight: "rotationRight"
    property string fnAddText: "addText"
    property string fnAddLine: "addLine"
    property string fnSwitchEncrypt: "switchEncrypt"
    property var hiddenActionIndex: []
    property alias fileTitleListView: _fileTitleListView
    property bool editStatus: false
    signal exitEdit

    Keys.onEscapePressed: {
        editStatus = false
        if(_pdfReaderContainer.count == 0){
            return
        }
        _pdfReaderContainer.currentItem.editType = "NONE"
        if(!Array.isArray(_pdfReaderContainer.currentItem.editControl) && _pdfReaderContainer.currentItem.editControl !== null) { //非数组形式
            _pdfReaderContainer.currentItem.editControl.destroy()
        }
        _pdfReaderContainer.currentItem.editControl = null
        emit: exitEdit()
    }

    FileDialog {
        id: _fileDialog
        title: "请选择您的PDF文档"
        folder: shortcuts.home
        nameFilters: ["PDF文件 (*.pdf)"]
        selectMultiple: true
        onAccepted: {
            loadFiles(_fileDialog.fileUrls,true)
        }
    }

    Component.onCompleted: {
//        print("#2")
//        loadFiles(["file:///C:/Users/C24/Desktop/pdf/1.pdf"],false,true)
    }

    function loadFile(fileUrl,pathVisible,showRecords){
        var path,basename
        pathVisible = pathVisible || true
        path = global.urlPath(fileUrl)
        if(existOpenedPath(path)){
            pdfUtil.setShowRecords(path,showRecords)
            emit: updateImageNotify(path)
            return
        }
        basename = global.urlBaseName(fileUrl)
        if(pathVisible){
            _fileTitleListView.model.append({"basename":basename,"path": path })
        }else{
            _fileTitleListView.model.append({"basename":basename,"path": "预览文件，路径不可见" })
        }
        _pdfReader.createObject(_pdfReaderContainer,{ path: path,showRecords: showRecords })
        _fileTitleListView.currentIndex = _fileTitleListView.count - 1
        _pdfReaderContainer.setCurrentIndex(_fileTitleListView.currentIndex)
    }

    function loadFiles(fileUrls,pathVisible,showRecords) {
        var url,path,basename
        pathVisible = pathVisible || true
        for(var i = 0;i < fileUrls.length; i++){
            url = fileUrls[i]
            path = global.urlPath(url)
            if(existOpenedPath(path)){
                pdfUtil.setShowRecords(path,showRecords)
                emit: updateImageNotify(path)
                continue
            }
            basename = global.urlBaseName(url)
            if(pathVisible){
                _fileTitleListView.model.append({"basename":basename,"path": path })
            }else{
                _fileTitleListView.model.append({"basename":basename,"path": "预览文件，路径不可见" })
            }
            _pdfReader.createObject(_pdfReaderContainer,{ path: path,showRecords: showRecords })
        }
        _fileTitleListView.currentIndex = _fileTitleListView.count - 1
        _pdfReaderContainer.setCurrentIndex(_fileTitleListView.currentIndex)
    }

    Connections {
        target: pdfUtil
        onEnterPasswordNotify: {
            showTipLayer("VerifyPassword","访问限制")
        }
        onChangeCountChanged: {
            if(path === _pdfReaderContainer.currentItem.path){
                if(count > 0){
                    setToolbarEnableItems([fnUndo])
                }else{
                    setToolbarDisableItems([fnUndo])
                }
            }
        }
    }

    function showTipLayer(type,title){
        _pdfReaderContainer.currentItem.tipLayer.visible = true
        _pdfReaderContainer.currentItem.tipLayer.tipType = type
        _pdfReaderContainer.currentItem.tipLayer.tipTitle = title
    }

    function existOpenedPath(path){
        for(var i = 0;i < _fileTitleListView.model.count; i++){
            if(_fileTitleListView.model.get(i)["path"] === path){
                return true
            }
        }
        return false
    }

    function open() {
        _fileDialog.open()
    }

    function close() {
        removeFileByIndex(_fileTitleListView.currentIndex)
    }

    function save() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        pdfUtil.saveChange(currentPdfView()["path"])
    }

    function currentPdfView() {
        return _pdfReaderContainer.currentItem["listView"]
    }

    function previousPage() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        currentPdfView()["currentIndex"]--
    }

    function nextPage() {
        if(_pdfReaderContainer.count == 0){
            return
        }

        currentPdfView()["currentIndex"]++
    }

    function zoomIn() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        _pdfReaderContainer.currentItem.zoomRatio += 0.1
        pdfUtil.setZoomRatio(_pdfReaderContainer.currentItem.path,_pdfReaderContainer.currentItem.zoomRatio)
        updateImageNotify(_pdfReaderContainer.currentItem.path)
    }

    function zoomReset() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        _pdfReaderContainer.currentItem.zoomRatio = 1
        pdfUtil.setZoomRatio(_pdfReaderContainer.currentItem.path,_pdfReaderContainer.currentItem.zoomRatio)
        updateImageNotify(_pdfReaderContainer.currentItem.path)
    }

    function zoomOut() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        _pdfReaderContainer.currentItem.zoomRatio -= 0.1
        pdfUtil.setZoomRatio(_pdfReaderContainer.currentItem.path,_pdfReaderContainer.currentItem.zoomRatio)
        updateImageNotify(_pdfReaderContainer.currentItem.path)
    }

    function rotationLeft() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        pdfUtil.rotation(_pdfReaderContainer.currentItem.path,false)
        updateImageNotify(_pdfReaderContainer.currentItem.path)
    }

    function rotationRight() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        pdfUtil.rotation(_pdfReaderContainer.currentItem.path,true)
        updateImageNotify(_pdfReaderContainer.currentItem.path)
    }

    function undo() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        pdfUtil.undo(_pdfReaderContainer.currentItem.path)
    }

    function addText() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        if(_pdfReaderContainer.currentItem.editType === "TEXT"){
            editStatus = false
            _pdfReaderContainer.currentItem.editType = "NONE"
            if(!Array.isArray(_pdfReaderContainer.currentItem.editControl) && _pdfReaderContainer.currentItem.editControl !== null){
                _pdfReaderContainer.currentItem.editControl.destroy()
            }
            _pdfReaderContainer.currentItem.editControl = null
        } else {
            editStatus = true
            _pdfReaderContainer.currentItem.editType = "TEXT"
            if(_pdfReaderContainer.currentItem.editControl !== null){
                _pdfReaderContainer.currentItem.editControl = null
            }
        }
    }

    function addImage() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        if(_pdfReaderContainer.currentItem.editType === "IMAGE"){
            editStatus = false
            _pdfReaderContainer.currentItem.editType = "NONE"
            _pdfReaderContainer.currentItem.editControl = null
        } else {
            editStatus = true
            _pdfReaderContainer.currentItem.editType = "IMAGE"
            if(!_pdfReaderContainer.currentItem.editControl){
                _pdfReaderContainer.currentItem.editControl = null
            }
        }
    }

    function addLine() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        if(_pdfReaderContainer.currentItem.editType === "LINE"){
            editStatus = false
            _pdfReaderContainer.currentItem.editType = "NONE"
            _pdfReaderContainer.currentItem.editControl = null
        } else {
            editStatus = true
            _pdfReaderContainer.currentItem.editType = "LINE"
            if(!_pdfReaderContainer.currentItem.editControl){
                _pdfReaderContainer.currentItem.editControl = null
            }
        }
        //pdfUtil.addLine(_pdfReaderContainer.currentItem.path,_pdfReaderContainer.currentItem.editPageIndex,Qt.point(50,50),Qt.point(200,200))
    }

    function switchEncrypt() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        var havePassword = pdfUtil.havePassword(_pdfReaderContainer.currentItem.path)
        if(_pdfReaderContainer.currentItem.tipLayer.tipType === "None"){
            if(!havePassword){
                showTipLayer("NewPassword","新建密码")
            }else{
                pdfUtil.cancelPassword(_pdfReaderContainer.currentItem.path)
                updateEncryptState()
            }
        } else if(_pdfReaderContainer.currentItem.tipLayer.tipType === "NewPassword"){
            _pdfReaderContainer.currentItem.tipLayer.visible = false
            _pdfReaderContainer.currentItem.tipLayer.tipType = "None"
        }
    }

    function removeFileByIndex(index){
        pdfUtil.deleteFile(_fileTitleListView.currentItem.path)
        _fileTitleListView.model.remove(index)
        var item = _pdfReaderContainer.itemAt(index)
        _pdfReaderContainer.removeItem(index)
        if(_fileTitleListView.count > 0) {
            if(index === 0){
                _fileTitleListView.currentIndex = 0
            }else{
                _fileTitleListView.currentIndex = index - 1
            }
            _pdfReaderContainer.currentIndex = _fileTitleListView.currentIndex
            //            _pdfReaderContainer.setCurrentIndex(_fileTitleListView.currentIndex)
        } else {
            _fileTitleListView.currentIndex = -1
            setToolbarDisableExceptItems([0])
        }
        item.destroy()
//        print(_fileTitleListView.currentIndex,_pdfReaderContainer.count)
    }

    function updateEncryptState() {
        if(_pdfReaderContainer.count == 0){
            return
        }
        var havePassword = pdfUtil.havePassword(_pdfReaderContainer.currentItem.path)
        for(var i = 0;i < _toolRepeater.model.count; i++) {
            if(_toolRepeater.model.get(i)["fn"] === "switchEncrypt"){
                if(havePassword ){
                    if(_pdfReaderContainer.currentItem.tipLayer.tipType === "VerifyPassword"){
                        _toolRepeater.model.get(i)["tip"] = "已加密，请验证密码"
                    }else if(_pdfReaderContainer.currentItem.tipLayer.tipType === "NewPassword"){
                        _toolRepeater.model.get(i)["tip"] = "退出密码设定"
                    }else {
                        _toolRepeater.model.get(i)["tip"] = "已加密，点击取消加密"
                    }
                } else {
                    _toolRepeater.model.get(i)["tip"] = "未加密，点击加密"
                }
                break;
            }
        }
    }

    //设置工具栏上多个item为enable，比较属性为fn，其他不变
    function setToolbarEnableItems(enableItems){
        for(var i = 0;i < _toolRepeater.model.count; i++){
            for(var j = 0;j < enableItems.length; j++){
                if(_toolRepeater.model.get(i)["fn"] === enableItems[j]){
                    _toolRepeater.model.get(i)["disable"] = false
                    break
                }
            }
        }
    }

    //设置工具栏上多个item为disable，比较属性为fn，其他不变
    function setToolbarDisableItems(disableItems){
        for(var i = 0;i < _toolRepeater.model.count; i++){
            for(var j = 0;j < disableItems.length; j++){
                if(_toolRepeater.model.get(i)["fn"] === disableItems[j]){
                    _toolRepeater.model.get(i)["disable"] = true
                    break
                }
            }
        }
    }

    //设置工具栏除了exceptItems使能，其他为disable
    function setToolbarEnableExceptItems(exceptItems) {
        for(var i = 0;i < _toolRepeater.model.count; i++){
            var exist = false
            for(var j = 0;j < exceptItems.length; j++){
                if(_toolRepeater.model.get(i)["fn"] === exceptItems[j]){
                    exist = true
                    break
                }
            }
            _toolRepeater.model.get(i)["disable"] = exist
        }
    }

    function setToolbarDisableExceptItems(exceptItems) {
        for(var i = 0;i < _toolRepeater.model.count; i++){
            var exist = true
            for(var j = 0;j < exceptItems.length; j++){
                if(_toolRepeater.model.get(i)["fn"] === exceptItems[j]){
                    exist = false
                    break
                }
            }
            _toolRepeater.model.get(i)["disable"] = exist
        }
    }

    Rectangle {
        id: _toolbar
        height: rh(30)
        width: parent.width
        Row {
            Repeater {
                id: _toolRepeater
                model: ListModel {
                    ListElement {
                        icon: "qrc:/images/open.ico"
                        fn: "open"
                        tip: "打开新文档"
                        disable: false
                    }
                    //                    ListElement {
                    //                        icon: "qrc:/images/close.ico"
                    //                        fn: "close"
                    //                        tip: "关闭当前文档"
                    //                    }
                    //                    ListElement {
                    //                        icon: "qrc:/images/save.png"
                    //                        fn: "save"
                    //                        tip: "保存文档"
                    //                    }
                    ListElement {
                        icon: "qrc:/images/undo.png"
                        fn: "undo"
                        tip: "撤销"
                        disable: true
                    }

                    ListElement {
                        icon: "qrc:/images/previouspage.ico"
                        fn: "previousPage"
                        tip: "上一页"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/nextpage.ico"
                        fn: "nextPage"
                        tip: "下一页"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/rotationleft.png"
                        fn: "rotationLeft"
                        tip: "逆时针旋转视图\n注意：此功能为查看页面，不作修改文档"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/rotationright.png"
                        fn: "rotationRight"
                        tip: "顺时针旋转视图\n注意：此功能为查看页面，不作修改文档"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/zoom_in.ico"
                        fn: "zoomIn"
                        tip: "放大"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/zoom_reset.ico"
                        fn: "zoomReset"
                        tip: "重置放大倍数"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/zoom_out.ico"
                        fn: "zoomOut"
                        tip: "缩小"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/text.png"
                        fn: "addText"
                        tip: "添加标注"
                        disable: true
                    }
                    //                    ListElement {
                    //                        icon: "qrc:/images/image.png"
                    //                        fn: "addimage"
                    //                        tip: "添加图片"
                    //                    }
                    ListElement {
                        icon: "qrc:/images/line.png"
                        fn: "addLine"
                        tip: "添加横线"
                        disable: true
                    }
                    ListElement {
                        icon: "qrc:/images/docencrypt.png"
                        fn: "switchEncrypt"
                        tip: "切换加密状态" // 加密状态 <-> 公开状态
                        disable: true
                    }
                }
                delegate: Button {
                    id: _buttonDelegate
                    width: _toolbar.height * 6 / 5
                    height: _toolbar.height
                    enabled: !disable
                    function hidden(){
                        for(var i = 0;i < hiddenActionIndex.length; i++){
                            if(hiddenActionIndex[i] === index){
                                return true
                            }
                        }
                        return false
                    }
                    visible: !hidden()

                    background: Item {
                        id: _iconContainer
                        anchors.fill: parent
                        enabled: disable
                        property var colorObj: null
                        property var disableFlag: disable
                        onDisableFlagChanged: {
                            if(disable) {
                                colorObj = _colorOverlay.createObject(_iconContainer,{"anchors.fill":_iconImage,"source":_iconImage})
                                _iconImage.visible = false
                            }else{
                                if(colorObj !== null){
                                    colorObj.destroy()
                                    colorObj = null
                                }
                                _iconImage.visible = true
                            }
                        }

                        onEnabledChanged: {

                        }
                        Image {
                            id: _iconImage
                            anchors.centerIn: parent
                            sourceSize: Qt.size(parent.width * 0.7,parent.height * 0.7)
                            source: icon
                            smooth: true
                        }
                        Component {
                            id: _colorOverlay
                            ColorOverlay {
                                enabled: index == 0 || _fileTitleListView.model.count > 0
                                color: "#909090"
                            }
                        }
                    }
                    ToolTip.text: tip
                    ToolTip.visible: hovered
                    onClicked: {
                        _root[fn]()
                    }
                }
            }
        }
    }

    Rectangle {
        id: _fileTitleBottomLayer
        anchors.top: _toolbar.bottom
        width: parent.width
        height: (_fileTitleListView.count == 0 || !_fileTitleListView.visible) ? 0 : rh(26)
    }

    ListView {
        id: _fileTitleListView
        anchors {
            top: _toolbar.bottom
        }
        onCountChanged: {
            if(count > 0) {
                setToolbarEnableExceptItems([fnUndo])
            }else{
                setToolbarEnableExceptItems([fnOpen])
            }
        }

        width: parent.width
        height: count == 0 ? 0 : rh(26)
        model: ListModel {
        }
        orientation: ListView.Horizontal
        delegate: Rectangle {
            width: rw(120)
            height: rh(26)
            clip: true
            color: index == _fileTitleListView.currentIndex ? "#B0BEC5" : "white"
            MouseArea {
                id: _mouseArea
                hoverEnabled: true
                anchors.fill: parent
                onClicked: {
                    _fileTitleListView.currentIndex = index
                    _pdfReaderContainer.setCurrentIndex(index)
                }
            }

            Rectangle {
                id: _tagRect
                width: rw(3)
                height: parent.height
                color: index == _fileTitleListView.currentIndex ? "#009688" : "#EEEEEE"
            }

            Text {
                anchors {
                    left: parent.left
                    leftMargin: rw(6)
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: rw(20)
                }
                text: basename
            }
            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: rw(20)
                height: parent.height
                background: Image {
                    source: "qrc:/images/close.png"
                    scale: 0.5
                }
                ToolTip.text: "关闭"
                ToolTip.visible: hovered
                ToolTip.delay: 250
                onClicked: {
                    removeFileByIndex(index)
                }
            }
            ToolTip.visible: _mouseArea.containsMouse
            ToolTip.text: path
            ToolTip.delay: 500
        }
    }

    SwipeView {
        id: _pdfReaderContainer
        anchors.fill: parent
        visible: true
        anchors.topMargin: _toolbar.height + _fileTitleBottomLayer.height
        onCurrentItemChanged: {
            _updateDelayer.run(400)
        }
        Delayer {
            id: _updateDelayer
            callback: function() {
                if(_pdfReaderContainer.count > 0){
                    updateEncryptState()
                }
                if(_pdfReaderContainer.currentIndex != -1 && pdfUtil.existChangeItem(_pdfReaderContainer.currentItem.path)){
                    setToolbarEnableItems([fnUndo])
                }else{
                    setToolbarDisableItems([fnUndo])
                }
            }
        }
    }

    Component {
        id: _textComponent
        FocusScope {
            focus: true
            TextField {
                id: _textField
                objectName: "NewTextField"
                width: rw(160)
                height: rh(35)
                selectByMouse: true
                font.pixelSize: rfs(16)
                focus: true
                focusReason: Qt.OtherFocusReason
                background: Rectangle {
                    radius: rw(3)
                    border.width: rw(1)
                    border.color: "black"
                }
                onEditingFinished: {
                    pdfUtil.addText(_pdfReaderContainer.currentItem.path,_pdfReaderContainer.currentItem.editPageIndex,_pdfReaderContainer.currentItem.editPosition,text)
                    _pdfReaderContainer.currentItem.editControl.destroy()
                    _pdfReaderContainer.currentItem.editControl = null
                }
            }
        }
    }


    Component {
        id: _pdfReader
        Rectangle {
            id: _listViewContainer
            color: "gray"
            clip: true
            property string path
            property bool showRecords: true
            property real zoomRatio: 1.0  //缩放系数
            property int maxPageWidth
            property string editType: "NONE"  //NONE、TEXT、IMAGE
            property var editControl //数组形式或控件
            property int editPageIndex
            property point editPosition
            property alias listView: _listView
            property alias tipLayer: _tipLayer
            Connections{
                target: pdfUtil
                onMaxPageWidthChangedNotify: {
                    //print("onMaxPageWidthChangedNotify" ,_listViewContainer.path, path,width , _root.width)
                    if(_listViewContainer.path == path){
                        _listViewContainer.maxPageWidth = width
                        if(width < _root.width){
                            _horizontalBar.policy = ScrollBar.AlwaysOff
                        }else{
                            _horizontalBar.policy = ScrollBar.AlwaysOn
                        }
                    }
                }
            }
            ListView {
                id: _listView
                anchors.fill: parent
                model: ListModel{}
                spacing: rh(8)
                clip: true
                focus: true
                Component.onCompleted: {
                    pdfUtil.addFile(_listViewContainer.path,_listViewContainer.showRecords)
                }

                Connections {
                    target: pdfUtil
                    onLoadFinishNotify: {
                        if(path == _listViewContainer.path){
                            for(var i = 0;i < pageCount;i++){
                                var url = "image://PdfScreenshot/"+path+"#"+i
                                _listView.model.append({"imgUrl": url })
                            }
                        }
                    }
                }
                delegate: Item {
                    id: _delegateRect
                    height: _image.sourceSize.height
                    focus: true

                    MouseArea {
                        anchors.fill: parent
                        onWheel: {
                            if (wheel.modifiers & Qt.ControlModifier) {
                                if( wheel.angleDelta.y > 0 ){
                                    zoomIn()
                                }else{
                                    zoomOut()
                                }
                                wheel.accepted = true
                                return
                            }
                            wheel.accepted = false
                        }

                        onClicked: {
                            _listView.currentIndex = index
                        }
                    }
                    width: {
                        var zoomWidth = _image.sourceSize.width
                        if(zoomWidth < _root.width){
                            _image.anchors.horizontalCenter = _delegateRect.horizontalCenter
                            return _root.width
                        }else{
                            _image.anchors.horizontalCenter = undefined
                            return zoomWidth
                        }
                    }
                    //rotation: pageRotation
                    Image {
                        id: _image
                        source: imgUrl
                        height: _image.sourceSize.height
                        width: _image.sourceSize.width
                        x: -_horizontalBar.position * width
                        cache: false

                        //自绘层
                        Canvas {
                            id: _canvas
                            anchors.fill: parent
                            antialiasing: true
                            smooth: true
                            property point tempPoint: Qt.point(-1,-1)
                            visible: true
                            onPaint: {
                                if(_listViewContainer.editType == "LINE"){
                                    var ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.lineWidth = 3
                                    ctx.strokeStyle = "#ff0000"
                                    if(Array.isArray(_listViewContainer.editControl) && tempPoint.x !== -1){
                                        if(_listViewContainer.editControl.length === 1){
                                            var startPos = _listViewContainer.editControl[0]
                                            ctx.moveTo(startPos.x,startPos.y)
                                            //修正横线
                                            if(Math.abs(startPos.x - tempPoint.x) <= 5){
                                                tempPoint.x = startPos.x;
                                            }
                                            if(Math.abs(startPos.y - tempPoint.y) <= 5){
                                                tempPoint.y = startPos.y
                                            }
                                            ctx.lineTo(tempPoint.x,tempPoint.y)
                                            ctx.stroke()
                                        }
                                    }
                                    tempPoint.x = -1
                                }else {
                                    ctx = getContext("2d")
                                    ctx.clearRect(0,0,width,height)
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: false
                            enabled: _listViewContainer.editType != "NONE"
                            cursorShape: _listViewContainer.editType != "NONE" ? Qt.CrossCursor : Qt.ArrowCursor
                            onClicked: {
                                _listViewContainer.editPageIndex = index
                                if(!_listViewContainer.editControl && _listViewContainer.editType == "TEXT"){
                                    _listViewContainer.editControl = _textComponent.createObject(_image)
                                    Qt.callLater(function(){
                                        _listViewContainer.editControl.focus = true
                                    })
                                    _listViewContainer.editPosition = Qt.point(mouseX,mouseY)
                                    if(_listViewContainer.editControl){
                                        _listViewContainer.editControl.x = mouseX
                                        _listViewContainer.editControl.y = mouseY
                                    }
                                }else if(_listViewContainer.editType == "IMAGE"){
                                    // pdfUtil.addImage(_listViewContainer.path,index,Qt.point(mouseX,mouseY))
                                } else if(_listViewContainer.editType == "LINE") {
                                    if(!Array.isArray(_listViewContainer.editControl) || _listViewContainer.editControl.length === 2) {
                                        _listViewContainer.editControl = [Qt.point(mouseX,mouseY)]
                                        hoverEnabled = true   //起始点启用
                                    }else if(_listViewContainer.editControl.length === 1){
                                        _listViewContainer.editControl.push(Qt.point(mouseX,mouseY))
                                        pdfUtil.addLine(_listViewContainer.path,index,_listViewContainer.editControl[0],Qt.point(mouseX,mouseY))
                                        hoverEnabled = false  //已经获得第二个点，不需要了
                                    }
                                    _canvas.requestPaint()
                                }
                            }
                            onPositionChanged: {
                                if(_listViewContainer.editType == "LINE") {
                                    _canvas.tempPoint = Qt.point(mouseX,mouseY)
                                    _canvas.requestPaint()
                                }
                            }
                        }
                    }

                    function updateImage() { //requestImage
                        var tmp = imgUrl
                        imgUrl = ""
                        imgUrl = tmp
                    }

                    Connections {
                        target: _root
                        onUpdateImageNotify: {
                            if(path === _listViewContainer.path) {
                                _delegateRect.updateImage()
                            }
                        }
                        onExitEdit: {
                            _listViewContainer.editType = "NONE"
                            _listViewContainer.editControl = null
                            _canvas.requestPaint()
                        }
                    }

                    Connections {
                        target: pdfUtil
                        onUpdatePage: {
                            if(path === _listViewContainer.path && pageNum === index){
                                _delegateRect.updateImage()
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }

                ScrollBar {
                    id: _horizontalBar
                    hoverEnabled: true
                    active: hovered || pressed
                    orientation: Qt.Horizontal
                    size: _root.width / maxPageWidth
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                }
            }

            Rectangle {
                id: _tipLayer
                color: "#eee"
                anchors.fill: parent
                visible: false
                property string tipType: "None"  // None / VerifyPassword / NewPassword
                property alias tipTitle: _tipTitle.text
                Image {
                    id: _limitAccessImage
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -rh(50)
                    width: rw(128)
                    height: rh(128)
                    source: "qrc:/images/limitaccess.png"
                }

                Text {
                    id: _tipTitle
                    anchors.top: _limitAccessImage.bottom
                    anchors.topMargin: rh(15)
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "访问限制"
                    color: "#707070"
                    font.pixelSize: rfs(30)
                }

                Delayer {
                    id: _delayer
                }

                TextField {
                    id: _passwordInput
                    anchors {
                        top: _tipTitle.bottom
                        topMargin: rh(15)
                        horizontalCenter: parent.horizontalCenter
                    }
                    placeholderText: "请输入你的密码"
                    selectByMouse: true

                    background: Rectangle {
                        id: _passwordBg
                        implicitWidth: 160
                        implicitHeight: 30
                        color: "transparent"
                        border.color: _passwordInput.enabled ? "#707070" : "transparent"
                        radius: rw(4)
                    }

                    Keys.onReturnPressed: {
                        if(_tipLayer.tipType == "VerifyPassword"){
                            if(pdfUtil.matchPassword(_listViewContainer.path,text)) {
                                _tipTitle.text = "匹配成功"
                                _delayer.callback = function() {
                                    _tipLayer.visible = false
                                    _tipLayer.tipType = "None"
                                    updateEncryptState()
                                }
                                _delayer.run(1500)
                            }else{
                                _passwordBg.border.color = "red"
                            }
                        }else if(_tipLayer.tipType == "NewPassword"){
                            if(pdfUtil.setPassword(_listViewContainer.path,text)) {
                                _tipTitle.text = "设置成功"
                                _delayer.callback = function() {
                                    _tipLayer.visible = false
                                    _tipLayer.tipType = "None"
                                    updateEncryptState()
                                }
                                _delayer.run(1500)
                            }else{
                                _tipTitle.text = "设置失败"
                            }
                        }
                    }
                }
            }
        }
    }
}
