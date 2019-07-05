/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 15:43:05
 * @LastEditTime: 2019-07-04 15:49:32
 */
window.Utils = {

    // 拷贝对象
    copy : function(src_obj, dst_obj) {

    },

    screenshot:function(file_name, callback) {
        if (!cc.sys.isNative) {
            cc.log("HTML-5 Not Support!")
            return
        }

        var size = cc.view.getVisibleSize();
        var renderTexture = cc.RenderTexture.create(size.width, size.height, cc.Texture2D.PIXEL_FORMAT_RGBA8888, gl.DEPTH24_STENCIL8_OES);
        renderTexture.begin();
        cc.director.getRunningScene().visit();
        renderTexture.end();

        var filename = file_name + ".png"
        renderTexture.saveToFile(filename, cc.ImageFormat.PNG, true, function (params) {
            if (callback) {
                callback(global.Utils.getStoragePath() + filename)
            }
        })
    },

    getIP : function (callback) {

        if (!callback) {
            return
        }

        if (!this.ip) {
            this.ip = "0.0.0.0"
        }

        var self = this
        this.isGetipCallback = false
        var url = "http://ip.taobao.com/service/getIpInfo.php?ip=myip";
        var xmlHttpRequest = new XMLHttpRequest();
        xmlHttpRequest.onreadystatechange = function(){
            if (xmlHttpRequest.readyState == 4 && (xmlHttpRequest.status >= 200 && xmlHttpRequest.status < 400)) {
                var response = JSON.parse(xmlHttpRequest.responseText)
                if (response.code == 0){

                    self.ip = response.data.ip
                    callback(self.ip)
                }
                else {
                    callback(self.ip)
                }

                self.isGetipCallback = true
            }
        }
        xmlHttpRequest.timeout = 3000

        xmlHttpRequest.ontimeout = function(){
            // 超时
            callback(self.ip)
            self.isGetipCallback = true
        }

        xmlHttpRequest.onerror = function(){
            callback(self.ip)
            self.isGetipCallback = true
        }
        xmlHttpRequest.open("GET",url,true);
        xmlHttpRequest.send();

        setTimeout(function () {

            if (self.isGetipCallback == false) {
                callback(self.ip)
                self.isGetipCallback = true
            }
        }, 3500)
    },

    // 获取文件数据
    getFileData : function(path) {
        var content = ""
        if (typeof(jsb) != "undefined") {
            if (jsb.fileUtils.isFileExist(path)) {
                var data = jsb.fileUtils.getStringFromFile(path)
                content = jsb.fileUtils.getStringFromFile(path)
            }
        }
        return content
    },

    //获取 MD5
    getMD5 : function(str) {
        return global.GMd5(str)
    },

    //获得可写路径
    getStoragePath : function (){
        return jsb.fileUtils.getWritablePath()    
    },

    createDirectory : function (path) {
        cc.log("path",path)
        var folders = path.split("/")
        cc.log(folders)
        if (!folders) {
            return
        }
        
        var dir = ""
        for (var index = 0; index < folders.length-1 ; index++) {
            dir = dir + folders[index] + "/"
            jsb.fileUtils.createDirectory(dir);
        }
    },

    // 获取设备ID
    getMobileId :function() {
        var udId = ""
        if(cc.sys.isNative && cc.sys.os == cc.sys.OS_ANDROID) {
            udId = jsb.reflection.callStaticMethod("org/cocos2dx/utils/NativeHelper", "getUDID","()Ljava/lang/String;")
        } else if(cc.sys.isNative&&cc.sys.os == cc.sys.OS_IOS) {
            udId = jsb.reflection.callStaticMethod("NativeHelper", "getUDID")
        } else {
            udId = "dadbx82387192" + (new Date()).getTime()
        }

        udId = global.Utils.getMD5(udId)

        return udId
    },

    //获取电池信息
    getBatteryStatus:function()
    {
        var mvalue;
        if (cc.sys.isNative && cc.sys.os == cc.sys.OS_ANDROID){
            mvalue= jsb.reflection.callStaticMethod("org/cocos2dx/utils/NativeHelper", "getBatteryStatus","()Ljava/lang/String;");
            mvalue=Number(mvalue)/100;

        } else if (cc.sys.isNative && cc.sys.os == cc.sys.OS_IOS) {//
            mvalue = jsb.reflection.callStaticMethod("Utils","getDianChiInfo")
        }else {
            mvalue = 1
        }
        return Number(mvalue);
    },

    // 获取地理位置
    getLocation : function (callbalk) {
        global.SDKMgr.getLocation(callbalk)
    },
    
    // 获取时间，以服务器为准
    getTime : function (format) {
        var mill = global.GameHallDataModel.getTimeDelta() + new Date().getTime()
        if(typeof format === "undefined") {
            return mill
        }
        var d = new Date(mill)
        return d.toString(format)
    },

    getLocalTime: function(format){
        var d = new Date()
        if(typeof format==="undefined")
        {
            return d.getTime()
        }
        return d.toString(format)
    },

    //转换成千分位数字
    getCommaNumber: function(number) {
        if( typeof(number) === "number" ) {
            return number.toString().replace(/(\d)(?=(?:\d{3})+$)/g, '$1,');
        } else {
            return "0";
        }
    },

    getTenThousands : function(number) {
        if(number >= 10000) {
            if(number >= 100000000) {
                var num = new Number(number / 100000000)
                return num.toFixed(2) + "亿"
            }
            var num = new Number(number / 10000)
            return num.toFixed(2) + "万"
        }
        return number + ""
    },

    getTenThousands1: function (number, decimals = 0) {
        if (number >= 10000) {
            if (number >= 100000000) {
                var num = new Number(number / 100000000)
                return num.toFixed(decimals) + "亿"
            }
            var num = new Number(number / 10000)
            return num.toFixed(decimals) + "万"
        }
        return number + "";
    },
    getHundredsOfMillions: function (number, decimals = 0) {
        if (number >= 100000000) {
            var num = new Number(number / 100000000)
            return num.toFixed(decimals) + "亿"
        }
        return number + "";
    },

    // 带千分位和万亿单位的字符串
    simplifiedNumber : function(value){
        var value_converted = global.Utils.getTenThousands(value)
        /*
        var value_str = new String(value_converted)
        var arr = value_str.split(".")
        var front_value
        var last_value
        if(arr.length == 1) {
            // 没有找到小数点，
            if(value_str.indexOf('万') >= 0){
                arr = value_str.split("万")
                front_value = global.Utils.getCommaNumber(parseInt(arr[0]))
                last_value = "万"
            } else if (value_str.indexOf('亿') >= 0) {
                arr = value_str.split("亿")
                front_value = global.Utils.getCommaNumber(parseInt(arr[0]))
                last_value = "亿"
            } else {
                // 不带万，亿等单位
                front_value = value_str
                last_value = ""
            }
        } else {
            // 有小数点的，把小数前用千分位隔开
            front_value = global.Utils.getCommaNumber(parseInt(arr[0]))
            last_value = "." + arr[1]
        }
*/
        // return front_value + last_value
        return value_converted
    },

    // 播放动画
    playAction : function(node, act_name = null, endCallback = null, is_reverse = null, is_loop = false) {
        var animation = node.getComponent(cc.Animation) 
        var onFinished = function() {
            animation.off('finished', onFinished, this);
            if(endCallback) {
                endCallback()
            }
        }

        if(animation) {
            animation.on('finished', onFinished, this);
            var animation_state
            if(!act_name) {
                animation_state = animation.play()
            } else {
                animation_state = animation.play(act_name)
            }

            if(is_reverse) {
                animation_state.wrapMode = cc.WrapMode.Reverse
            }
            
            if(is_reverse == false){
                animation_state.wrapMode = cc.WrapMode.Normal
            }
            
            if(is_loop){
                animation_state.wrapMode = cc.WrapMode.Loop
            }
        }
    },

    random : function(start_num, end_num, base = 10) {
        var number = Math.floor(Math.random() * base)
        while (number < start_num || number > end_num) {
            number = Math.floor(Math.random() * base)
        }
        cc.log(number)
        return number
    },

    sex : function(sex) {
        if(sex == global.enums.sex.MALE) {
            return "man"
        } else {
            return "woman"
        }
    },
    
    // 从中间往两边展开，offset为两个节点之间的间隔，父节点锚点0.5，0.5
    alignHerizontal : function(items, offset, align_type) {
        var parent = items[0].parent
        var len = items.length
        var active_arr = []
        var total_width = 0
        var all_width = 0
        for (var index = 0; index < len; index++) {
            if(items[index].active){
                active_arr.push(items[index])
                total_width += items[index].width
            }
            all_width += items[index].width
        }

        var act_len = active_arr.length
        total_width += (act_len - 1) * offset
        all_width += (len - 1) * offset

        for (var idx = 0; idx < act_len; idx++) {
            var item = active_arr[idx]
            if(global.enums.align_type.LEFT_TO_RIGHT == align_type) {
                var start_x = 0 - all_width / 2
                item.x = start_x + (item.width + offset) * idx + item.width / 2
            } else if(global.enums.align_type.RIGHT_TO_LEFT == align_type){
                var start_x = all_width / 2
                item.x = start_x - (item.width + offset) * idx + item.width / 2
            } else if(global.enums.align_type.CENTER_TO_LR == align_type){
                var start_x = 0 - total_width / 2
                item.x = start_x + (item.width + offset) * idx + item.width / 2
            }
        }
    },

    // 从中间往两边展开，offset为两个节点之间的间隔，父节点锚点0.5，0.5
    alignVertical : function(items, offset, align_type) {
        var parent = items[0].parent
        var len = items.length
        var active_arr = []
        var total_height = 0
        var all_height = 0
        for (var index = 0; index < len; index++) {
            if(items[index].active){
                active_arr.push(items[index])
                total_height += items[index].height
            }
            all_height += items[index].height
        }

        var act_len = active_arr.length
        total_height += (act_len - 1) * offset
        all_height += (len - 1) * offset
        
        for (var idx = 0; idx < act_len; idx++) {
            var item = active_arr[idx]
            if(global.enums.align_type.TOP_TO_BUTTOM == align_type) {
                var start_y = all_height / 2
                item.y = start_y - (item.height + offset) * idx - item.height / 2
            } else if(global.enums.align_type.BUTTOM_TO_TOP == align_type){
                var start_y = 0 - all_height / 2
                item.y = start_y + (item.height + offset) * (act_len-idx) + item.height / 2
            } else if(global.enums.align_type.CENTER_TO_TB == align_type){
                var start_y = 0 - total_height / 2
                item.y = start_y + (item.height + offset) * (act_len-idx) + item.height / 2
            }
            cc.log(item.y, offset, item.height)
        }
    },

    dateFormat : function(fmt,date)  { //author: meizz   
        var o = {   
            "M+" : date.getMonth()+1,                 //月份   
            "d+" : date.getDate(),                    //日   
            "h+" : date.getHours(),                   //小时   
            "m+" : date.getMinutes(),                 //分   
            "s+" : date.getSeconds(),                 //秒   
            "q+" : Math.floor((date.getMonth()+3)/3), //季度   
            "S"  : date.getMilliseconds()             //毫秒   
        };   
        if(/(y+)/.test(fmt))   
            fmt=fmt.replace(RegExp.$1, (date.getFullYear()+"").substr(4 - RegExp.$1.length));   
        for(var k in o)   
            if(new RegExp("("+ k +")").test(fmt))   
        fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));   
        return fmt;   
    },

    newNode:function(type)
    {
        var node = new cc.Node()
        if(type && global.core.isFunction(type)) {
            return node.addComponent(type)
        }
        return node
    },

    // 创建一个由精灵组成的数字
    newNumber : function (number, numType = 1, forcenum = 0, offsetX = 0, is_center = false) {
        //返回整数数字node，左对齐;,numType 图片种类
        // forcenum 补齐长度，如：123， 补齐为6， 则为：000123

        var numStr = "" + number
        var length = numStr.length
        // 补齐
        if( forcenum != 0 && length < forcenum) {
            for(var i = 0; i < forcenum - length; i++) {
                numStr = "0" + numStr
            }
            length = numStr.length
        }

        var node = this.newNode()
        node.setAnchorPoint(0.5,0.5)
        var width = 0
        var height = 0
        var total_width = 0
        for(var i = 0; i < length; i++) {
            var s = numStr.charAt(i)
            var sprite = this.newNode(cc.Sprite)
            var is_comma = false
            var name = "number/num_" + numType + "_" + s
            if(s === ','){
                name = "number/num_" + numType + "_comma"
                is_comma = true
            } else if( s === '.') {
                name = "number/num_" + numType + "_dot"
                is_comma = true
            } else if(s === '万') {
                name = "number/num_" + numType + "_wan"
            } else if(s === '亿') {
                name = "number/num_" + numType + "_yi"
            } else if (s === "/") {
                name = "number/num_" + numType + "_div"
            }
            sprite.spriteFrame = global.ResMgr.getSpriteFrame(name, true)

            sprite.node.setAnchorPoint(0,0.5)
            sprite.node.setPosition(width, 0)
            if(is_comma) {
                sprite.node.setPosition(width, 0)
            }
            
            sprite.node.parent = node
            sprite.node.tag = i
            var size = sprite.node.getContentSize()
            width = width + size.width + offsetX * 2
            var h = size.height
            if(height < h) {
                height = h
            }
            node.setContentSize(width,height)
            total_width += size.width + offsetX * 2
        }

        if(is_center) {
            var start_x = 0 - total_width / 2
            for (var index = 0; index < node.childrenCount; index++) {
                var child = node.children[index]
                child.x = start_x
                start_x += child.width + offsetX * 2
            }
        }

        node.setPosition(0, 0)
        return node
    },

    unicodeToUtf8: function(unicode) {
        var uchar;
        var utf8str = "";
        var i;
        for(i=0; i<unicode.length;i+=2){
            uchar = (unicode[i]<<8) | unicode[i+1];        //UNICODE为2字节编码，一次读入2个字节
            utf8str = utf8str + String.fromCharCode(uchar);  //使用String.fromCharCode强制转换
        }
        return utf8str;
    },
    
    stringSub: function (str, pattern, reps) {
        var index = str.indexOf( pattern );
        if ( index > -1 ) {
            return str.substring(0, index) + reps + str.substring(index + pattern.length, str.length);
        } else {
            return str;
        }
    },

    isFileExist: function ( fileName ) {
        if ( cc.sys.isNative ) {
            return jsb.fileUtils.isFileExist( fileName );
        } else {
            return false;
        }
    },

    isNumberString : function(str) {
        var num = Number(str)
        return !isNaN(num)
    },

    isUrlString : function (url) {
        var isInvalidUrl = !url || url.indexOf("http") != 0;
        return !isInvalidUrl;
    },

    dump:function (obj, str) {
        // if( !str ) str = "";
        // var value = global.Utils._dump(obj);
        // cc.log(str + value[0]);
    },

    httpRequest : function(address, filename, callback){
        var xhr = new XMLHttpRequest()
        var self = this
        xhr.onreadystatechange = function(){
            if (xhr.readyState == 4 && (xhr.status >= 200 && xhr.status < 400)) {
                if(callback) {
                    callback(xhr, filename)
                }
            } else {
                callback(null, filename)
            }
        }
        xhr.responseType = "arraybuffer"
        xhr.open("GET", address, true)
        xhr.send()
    },

    saveTemp : function(file_name, data){
        var storage_path = jsb.fileUtils ? jsb.fileUtils.getWritablePath() : '/'
        
        var update_temp_dir = storage_path + "temp/" + file_name
        var dir_path = update_temp_dir.substring(0, update_temp_dir.lastIndexOf("/"))
        if (!jsb.fileUtils.isDirectoryExist(dir_path)){
            jsb.fileUtils.createDirectory(dir_path)
        }

        return jsb.fileUtils.writeDataToFile(data, update_temp_dir)
    },   

    getTemp : function(file_name, callback){

        if (cc.sys.isBrowser) {
            callback("err", null)
            return
        }
        var storage_path = jsb.fileUtils ? jsb.fileUtils.getWritablePath() : '/'
        var update_temp_dir = storage_path + "temp/" + file_name
        cc.log("update_temp_dir", update_temp_dir)
        cc.loader.load(update_temp_dir, cc.Texture2D, function(err, asset){
            callback(err, asset)
        })
    },

    saveCreateGameSettingData : function (gameID, create_type, data) {
        var type = "Default"
        if (create_type == global.enums.CreateRoomType.Teahouse_coin) {
            type = "Teahouse_coin"
        } else if (create_type == global.enums.CreateRoomType.Teahouse_RoomCard) {
            type = "Teahouse_RoomCard"
        }

        cc.sys.localStorage.setItem("createGameSettingData" + type + gameID, JSON.stringify(data));
    },

    getCreateGameSettingData : function (gameID, create_type) {
        var type = "Default"
        if (create_type == global.enums.CreateRoomType.Teahouse_coin) {
            type = "Teahouse_coin"
        } else if (create_type == global.enums.CreateRoomType.Teahouse_RoomCard) {
            type = "Teahouse_RoomCard"
        }

        var string = cc.sys.localStorage.getItem("createGameSettingData" + type + gameID)
        if (string && string != "undefined") {
            return JSON.parse(string)
        }

        return null;
    },

    dowloadImage : function(url, callback){
        var name_arr = new String(url).split("/")
        var name = name_arr[name_arr.length - 1]
        global.Utils.getTemp(name, function(err, asset){
            if(!err) {
                callback(new cc.SpriteFrame( asset ))
            } else {
                global.Utils.httpRequest(url, name, function(xhr, name){
                    var tmp_data = new Uint8Array(xhr.response);
                    var res = global.Utils.saveTemp(name, tmp_data)
                    if(res){
                        global.Utils.getTemp(name, function(err, asset){
                            callback(new cc.SpriteFrame( asset ))
                        })
                    }
                })
            }  
        })
    },

    getNativeVersion : function () {

        var path = jsb.fileUtils.getSearchPaths()
        var path_head = jsb.fileUtils.getWritablePath()

        var native_path = []
        for (var index = 0; index < path.length; index++) {
            if(path[index].indexOf(path_head) < 0) {
                native_path.push(path[index])
            }
        }

        var native_version_file = null
        for (var key = 0; key < native_path.length; key++) {
            var file_name = native_path[key] + "version.manifest"

            if(jsb.fileUtils.isFileExist(file_name)){
                native_version_file = jsb.fileUtils.getStringFromFile(file_name)
                break
            }
        }

        var native_version = JSON.parse(native_version_file).version

        var native_version_str = JSON.stringify(native_version);
        return native_version_str;
    },

    cleanCache : function(){

        if (cc.sys.isNative == false) {
            return;
        }

        var is_need_clean = false
        var native_version = this.getNativeVersion()
        var cache_version = this.getCacheVersion()
        if(!native_version || !cache_version) {
            return
        }

        var native_version_str = JSON.stringify(native_version);
        var cache_version_str = JSON.stringify(cache_version);

        is_need_clean = this.compareVersion(native_version_str, cache_version_str) != -1

        if(is_need_clean) {
            var storage_path = jsb.fileUtils ? jsb.fileUtils.getWritablePath() : '/'
            jsb.fileUtils.removeDirectory(storage_path + "temp")
            jsb.fileUtils.removeDirectory(storage_path + "update")
            jsb.fileUtils.removeFile(storage_path + "version.manifest")
            jsb.fileUtils.removeFile(storage_path + "project.manifest")
            cc.game.restart()
        }
    },
    
    getNativeVersion : function (){
        var path = jsb.fileUtils.getSearchPaths()
        var path_head = jsb.fileUtils.getWritablePath()
        var native_path = []
        for (var index = 0; index < path.length; index++) {
            if(path[index].indexOf(path_head) < 0) {
                native_path.push(path[index])
            }
        }

        var native_version_file = null
        for (var key = 0; key < native_path.length; key++) {
            var file_name = native_path[key] + "version.manifest"

            if (jsb.fileUtils.isFileExist(file_name)) {
                native_version_file = jsb.fileUtils.getStringFromFile(file_name)
                break
            }
        }
        
        if(native_version_file) {
            return JSON.parse(native_version_file).version
        }
        
        return null
    },
    
    getCacheVersion : function () {
        var path = jsb.fileUtils.getWritablePath() + "version.manifest"
        var cache_version_file = null
        if(jsb.fileUtils.isFileExist(path)) {
            cache_version_file = jsb.fileUtils.getStringFromFile(path)
        }
        
        if(cache_version_file) {
            return JSON.parse(cache_version_file).version
        }
        
        return null
    },
    
    //版本号相同，返回0， version1版本号更高，返回1， version1版本更低，返回-1
    compareVersion : function (version1, version2) {
        if(!version1 || !version2) {
            return -1
        }
        if(version1 === version2) {
            return 0
        }
        
        var vs_list_1 = version1.split(".")
        var vs_list_2 = version2.split(".")
        cc.log("vs_list_1 : " , vs_list_1, "--vs_list_2", vs_list_2)

        var is_force_install = parseInt(vs_list_1[1]) > parseInt(vs_list_2[1])
        var is_script_update = parseInt(vs_list_1[2]) > parseInt(vs_list_2[2])
        var is_resources_update = parseInt(vs_list_1[3]) > parseInt(vs_list_2[3])

        if (is_force_install) {
            return 1
        }
        
        if(is_force_install &&  is_script_update && is_resources_update) {
            //所有版本号都更高
            return 1
        }
        
        if(parseInt(vs_list_1[1]) == parseInt(vs_list_2[1]) && is_script_update && is_resources_update) {
             //不强更，资源和脚本版本号都更高
            return 1
        }
        
        if(parseInt(vs_list_1[1]) == parseInt(vs_list_2[1]) && parseInt(vs_list_1[2]) == parseInt(vs_list_2[2]) && is_resources_update){
            //不强更，资源版本相同，脚本版本号更高
            return 1
        }
        
        return -1
    },
    
    goCharge: function (){
        global.ServerCfgMgr.updateChargeCfg();
        var pay_h5 = global.PlayerDataModel.getH5OpenState()
        // 此部分将作为后面IOSweb充值代码
        if(pay_h5 && cc.sys.os == cc.sys.OS_IOS && global.isChecked == false){
            // 根据cfg里面取
            var cfg = global.ServerCfgMgr.getFile("commoncfg")
            if (cfg.web_shop_url.length > 4) {
                // 跳转网页
                var rid = global.PlayerDataModel.getRid()
                var name = global.PlayerDataModel.getName()
                var url = cfg.web_shop_url + "?name=" + encodeURI(name) + "&gid=" + rid
                global.SDKMgr.openURL(url)
                return 
            }
        }

        global.ViewMgr.open("Charge")
        global.ViewMgr.pushMsg("Charge", {key : "shop_type", data : global.enums.shop_type.GOLD })
    },

    // 计算两经纬度之间的距离
    getLocLatLength : function (lat1, lat2, lng1, lng2) {
        if (lat1 == 0 || lat2 == 0 || lng1 == 0|| lng2 == 0) {
            return 1000
        }
        var radLat1 = rad(lat1);
        var radLat2 = rad(lat2);
        var a = radLat1 - radLat2;
        var b = rad(lng1) - rad(lng2);
        var s = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin(a / 2), 2) + Math.cos(radLat1) * Math.cos(radLat2) * Math.pow(Math.sin(b / 2), 2)));
        s = s * 6378.137;
        // EARTH_RADIUS;
        s = Math.round(s * 10000) / 10000;
    },

    getReviewStatus : function (callback) {
        global.isChecked = false
        callback(false)
        return

        var getReviewStatusInfo = function () {
            var self = this
            global.Utils.httpRequest("http://down.17dkg.com/info.json", "info", function (xhr, filename) {
                if(!xhr){
                    callback(true)
                } else {
                    var service_list = xhr.response.Service_List
                    cc.log(JSON.stringify(service_list))
                    var data = cc.sys.os == cc.sys.OS_ANDROID ? service_list.android : service_list.ios
                    var version = global.Utils.getNativeVersion();
                    cc.log("本地版本：" + version)
                    var status = 0
                    for(var index = 0; index < data.length; index++) {
                        if(data[index].version == version) {
                            status = data[index].judge
                            break
                        }
                    }
                    cc.sys.localStorage.setItem(version, JSON.stringify({"version" : version, "status" : status}));
                    global.isChecked = status == 1 ? true : false
                    callback(global.isChecked)
                }
            })
        }

        global.isChecked = true

        if(cc.sys.os == cc.sys.OS_IOS) {
            var version = global.VersionMgr.getLocalVersion()
            var info = JSON.parse(cc.sys.localStorage.getItem(version)) || null

            cc.log("ttlbanbenhao" + (info ? JSON.stringify(info) : "meiyou"))
            if(info && info.varsion == version && info.status == 1) {
                //ios下，正在审核中，移除旧有的，并获取最新的状态
                cc.sys.localStorage.removeItem(version)
                getReviewStatusInfo()
            } else if(info == null) {
                //本地没有保存任何数据，所以目前正在审核中，获取最新的状态
                getReviewStatusInfo()
            } else if(info && info.version == version && info.status == 0) {
                //审核结束，开始连接
                global.isChecked = false
                callback(false)
            } else {
                getReviewStatusInfo()
            }
        } else {
            global.isChecked = false
            callback(false)
        }
    },

    //数组去重 by zw
    getUniqueArr:function(arr)
    {
        var hash=[];
        for (var i = 0; i < arr.length; i++) {
            if(hash.indexOf(arr[i])==-1){
                hash.push(arr[i]);
            }
        }
        return hash;
    },

    getNumbersByChars:function(chars)
    {
        var charArr=chars.split("");
        var tempChar="";
        for(var i=0;i<charArr.length;i++)
        {
          tempChar+=  this.getNumberByChar(charArr[i]);
          cc.log("zw_getNumbersByChars: "+tempChar);
        }

        return tempChar;
    },
    getNumberByChar:function(mchar)
    {

        switch (mchar)
        {
            case "A":
                return "0";
            case "B":
                return "1";
            case "C":
                return "2";
            case "D":
                return "3";
            case "E":
                return "4";
            case "F":
                return "5";
            case "G":
                return "6";
            case "H":
                return "7";
            case "I":
                return "8";
            case "J":
                return "9";
            default:return"-1"
        }

    },
    getShareWechatDes : function (game_id, gameInfo1) {
        var des = ""
        var gameInfo = gameInfo1["gameinfo" + game_id]["gamecfg"]
        if (game_id == global.enums.game_id.MAHJONG_DKG){
            var type = gameInfo1.room_type == global.enums.room_type.GOLD ? "金币场;" : "钻石场;"
            des += type
            des += "底分:" + gameInfo.base_score + "分;"
            var fan = gameInfo.max_fan_cnt + "番封顶;"
            des += fan
            var zimo = gameInfo.is_zimo_jiafan ? "自摸加翻;" : "自摸加底;"
            des += zimo
            var qh = gameInfo.is_qdd_hudd ? "请多大胡多大;" : ""
            des += qh
            var shaitaiyang = gameInfo.is_shaitaiyang ? "杠牌晒太阳;" : ""
            des += shaitaiyang
            var xiaohu = gameInfo.is_yifan_hupai ? "" : "小胡不算叫;"
        } else if (game_id == global.enums.game_id.MAHJONG_SCXZ){
            var type = gameInfo1.room_type == global.enums.room_type.GOLD ? "金币场;" : "钻石场;"
            des += type
            des += "底分:" + gameInfo.base_score + "分;"
            var fan = gameInfo.max_fan_cnt + "番封顶;"
            des += fan
            var zimo = gameInfo.is_zimo_jiafan ? "自摸加翻;" : "自摸加底;"
            des += zimo
            var qh = gameInfo.is_huansanzhang ? "换三张;" : ""
            des += qh
            var shaitaiyang = gameInfo.is_hujiao_zhuanyi ? "呼叫转移;" : ""
            des += shaitaiyang
            var xiaohu = gameInfo.is_dianganghua_zimo ? "点杠花当自摸;" : "点杠花当点炮;"
        } else if (game_id == global.enums.game_id.NIUNIU) {
            var type = gameInfo1.room_type == global.enums.room_type.GOLD ? "金币场;" : "钻石场;"
            des += type
            des += "底分:" + gameInfo.base_score + "分;"
            var pattern = ""
            if (gameInfo.pattern == 2) {
                pattern += "通比拼十;"
            } else if (gameInfo.pattern == 3) {
                pattern += "抢庄拼十;"
            } else {
                pattern += "固定庄家;"
            }
            des += pattern
        }
        return des += "快来加入吧..."
    },

    getPokerSortWithCards : function (cards) {

        var result = []
        var self = this
        cards.forEach(function (value) {
            var card = {}
            card.count = self.onPokerCount(value)
            card.type = self.onPokerType(value)
            result.push(card)
        })
        result.sort(function (a, b) {
            return a.type < b.type
        })
        result.sort(function (a, b) {
            return a.count < b.count
        })

        var cardNames = []
        result.forEach(function (value) {
            var count = value.count
            if (count == 10) {
                count = "A"
            } else if (count == 11) {
                count = "B"
            } else if (count == 12) {
                count = "C"
            } else if (count == 13){
                count = "D"
            } else if (count == 14) {
                count = 1
            }
            cardNames.push("poker_0x" + value.type + count)
        })
        return cardNames
    },

    //扑克点数转换
    onPokerCount : function (data) {
        var count = data % 16
        if (count == 1) {
            count = 14
        } else if (count == 2) {
            count = 15
        }
        return count
    },
    //扑克类型转换
    onPokerType : function (data) {
        var type = data / 16
        return parseInt(type)
    },

    /**
     * 数字转大写
     */
    strrev:function (num) {
        var ary = []
        for (var i = num.length; i >= 0; i--) {
            ary.push(num[i])
        }
        return ary.join("");
    },

    DX : function (num){
        if (num == "1000000000") {
            return "壹拾億"
        }else if(num == "100000000"){
            return "壹億"
        }else {
            var ary0 =["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌","玖"]
            var ary1 =["", "拾", "佰", "仟"]
            var ary2 = ["", "萬", "億", "兆"]

            var ary = this.strrev(num);
            var zero = ""
            var newary = ""
            var i4 = -1

            for (var i = 0; i < ary.length; i++) {
                if (i % 4 == 0) {
                    i4++;
                    newary = ary2[i4] + newary;
                    zero = "";

                }

                if (ary[i] == '0') {
                    switch (i % 4) {
                        case 0:
                            break;

                        case 1:
                        case 2:
                        case 3:
                            if (ary[i - 1] != '0') {
                                zero = "零"
                            }
                            ;
                            break;

                    }

                    newary = zero + newary;
                    zero = '';
                }
                else {
                    newary = ary0[parseInt(ary[i])] + ary1[i % 4] + newary;
                }

            }
            if (newary.indexOf("零") == 0) {
                newary = newary.substr(1)
            }
            return newary;
        }
    },

}