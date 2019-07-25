// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var net = require("./net/net");
//***************** sproto 初始化模块 begin */
var Sproto = require("./net/sproto");
//var host
// var sender
// var session = 0
// function init_sproto(map){
//     console.log("init_sproto")
//     var s2c = Sproto.new(map['s2c']);
//     var c2s = Sproto.new(map['c2s']);
//     host = s2c.host("package");
//     sender = host.attach(c2s);
// }

// function getSpFiles(filename,config,callback){
//     var xhr = new XMLHttpRequest();
//     xhr.open('GET', filename, true);
//     xhr.responseType = 'arraybuffer';

//     xhr.onload = function(e) {
//         let buff = xhr.response;
//         let dataview = new DataView(buff);
//         let schema = new Array();
//         for (let i = 0; i < dataview.byteLength; i++) {
//             schema[i] = dataview.getUint8(i);
//         }
//         //alert(dataview.byteLength);
//         let head = "null";
//         if (dataview.byteLength == config.c2s) {
//             head = "c2s"
//         }
//         if (dataview.byteLength == config.s2c) {
//             head = "s2c"
//         }
//         console.log("%s len %d %s",filename,dataview.byteLength,head)
//         if (head != "null"){
//             callback(head,{buf:schema, sz:schema.length});
//         }

//     };
//     xhr.send();
// }

// var loadedMap = {len : 0};
// function loaded_callbac(filename,data) {
//     loadedMap.len ++;
//     var obj = {}
//     loadedMap[filename] = data
//     if(loadedMap.len == 2 ){
//         init_sproto(loadedMap);
//     }
// }

//***************** sproto 初始化模块 end */

// function sendMsg(name, msg, callback){
//     session = session + 1
//     let p = sender(name, msg, session)
//     let array = p.buf
//     let size = p.sz
//     array.unshift(size%256)
//     array.unshift(Math.floor(size/256))
//     let d = new Uint8Array(array).buffer;
//     net.sendMessage(d);
// }

// function request(name, res, resp){
//     console.log("request:",name,res,resp)
//     switch(name){
//         case "verify":
//                 let msg = {
//                     "token": res.token,
//                     "username": "test001",
//                     "password": "111111"
//                 }
//                 sendMsg("signin", msg)
//             break;
//         default:
//             break;
//     }
// }

// function response(session, name, res){
//     console.log("response:",session,name,res)
// }

var netManager = {}
netManager.init = function(initCallBack){
    this.initCallBack = initCallBack;
    this.sessionIdMap = {};
    if(this.heartNode){
        cc.game.removePersistRootNode(this.heartNode);
    }
    this.heartNode = new cc.Node("heartNode");
    cc.game.addPersistRootNode(this.heartNode);
    net.init(util.handler(this.onConnectState,this),util.handler(this.onRecvMsg,this));
    this.loadProto();
};
netManager.loadProto = function(){
    this.host = null;
    this.sender = null;
    this.sessionId = 0;
    var self = this;
    function initProto(map){
        var s2c = Sproto.new(map['s2c']);
        var c2s = Sproto.new(map['c2s']);
        self.host = s2c.host("package");
        self.sender = self.host.attach(c2s);
        if(self.initCallBack){
            self.initCallBack();
        }
    }
    var loadedMap = {len : 0};
    function loadFileBack(filename,data) {
        loadedMap.len ++;
        loadedMap[filename] = data
        if(loadedMap.len == 2 ){
            initProto(loadedMap);
        }
    }
    function loadFiles(filename,config,callback){
        var xhr = new XMLHttpRequest();
        xhr.open('GET', filename, true);
        xhr.responseType = 'arraybuffer';
    
        xhr.onload = function(e) {
            let buff = xhr.response;
            let dataview = new DataView(buff);
            let schema = new Array();
            for (let i = 0; i < dataview.byteLength; i++) {
                schema[i] = dataview.getUint8(i);
            }
            //alert(dataview.byteLength);
            let head = "null";
            if (dataview.byteLength == config.c2s) {
                head = "c2s"
            }
            if (dataview.byteLength == config.s2c) {
                head = "s2c"
            }
            console.log("%s len %d %s",filename,dataview.byteLength,head)
            if (head != "null"){
                callback(head,{buf:schema, sz:schema.length});
            }
    
        };
        xhr.send();
    }
    cc.loader.loadRes('sproto/config', function(err,jsondata){
        cc.loader.loadRes("sproto/c2s", function(err,filedata){
            if(CC_JSB){
                var config = jsondata.json;
                var schema = jsb.fileUtils.getDataFromFile(filedata.nativeUrl);
                // cc.log("buff");
                // cc.log(buff);
                // var dataview = new DataView(buff);
                // var schema = new Array();
                // for (let i = 0; i < dataview.byteLength; i++) {
                //     schema[i] = dataview.getUint8(i);
                // }
                let head = "null";
                if (schema.length == config.c2s) {
                    head = "c2s"
                }
                if (schema.length == config.s2c) {
                    head = "s2c"
                }
                cc.log("buff");
                cc.log(schema);
                if (head != "null"){
                    loadFileBack(head,{buf:schema, sz:schema.length});
                }
            }
            // cc.loader.load(filedata.nativeUrl, function(err, text){
            //     var config = jsondata.json;
            //     function stringToUint8Array(str){
            //         var arr = [];
            //         for (var i = 0, j = str.length; i < j; ++i) {
            //           arr.push(str.charCodeAt(i));
            //           if(i == 6){
            //               cc.log("6 cha:",str.charCodeAt(i));
            //           }
            //         }
            //         var tmpUint8Array = new Uint8Array(arr);
            //         return tmpUint8Array
            //     }
            //     var schema = stringToUint8Array(text);
            //     cc.log(schema);
            //     let head = "null";
            //     if (schema.length == config.c2s) {
            //         head = "c2s"
            //     }
            //     if (schema.length == config.s2c) {
            //         head = "s2c"
            //     }
            //     //cc.log("%s len %d %s",filename,dataview.byteLength,head)
            //     if (head != "null"){
            //         loadFileBack(head,{buf:schema, sz:schema.length});
            //     }
            // });
        })        
        cc.loader.loadRes("sproto/s2c", function(err,filedata){
            if(CC_JSB){
                var config = jsondata.json;
                var schema = jsb.fileUtils.getDataFromFile(filedata.nativeUrl);
                let head = "null";
                if (schema.length == config.c2s) {
                    head = "c2s"
                }
                if (schema.length == config.s2c) {
                    head = "s2c"
                }
                cc.log("buff");
                cc.log(schema);
                if (head != "null"){
                    loadFileBack(head,{buf:schema, sz:schema.length});
                }
            }
        })
        cc.loader.addDownloadHandlers({
            "sp":function(item,callback) {
                loadFiles(item.rawUrl, jsondata.json, loadFileBack)
            }
        })        
    })

}
netManager.onConnectState = function(state){
    if(state == net.netState.CONNECTED){
        if(this.connectBack)
        {
            this.connectBack(true);
        }
        //this.startHeart();
    }else if(state == net.netState.COLSED){
        eventManager.dispatchEvent("GLOBAL_NETCLOSED_EVENT");
        //this.stopHeart();
    }
};
netManager.connect = function(ip,port,connectBack){
    this.connectBack = connectBack;
    net.connect(ip,port);
};
//推送消息
netManager.onPushData = function(name, res, resp){
    console.log("onPushData:",name,res,resp);
    eventManager.dispatchEvent("NET_"+name+"_EVENT",res);
}
//请求返回消息
netManager.onReponseData = function(sessionId, name, res){
    console.log("onReponseData:",sessionId,name,res);
    var msgName = this.sessionIdMap[sessionId];
    cc.log(msgName);
    if(msgName){
        eventManager.dispatchEvent("NET_"+msgName+"_EVENT",res);
        this.sessionIdMap[sessionId] = null;
    }
}
netManager.onRecvMsg = function(recvBuff){
    let array = Array.prototype.slice.call(new Uint8Array(recvBuff));
    let psize = array[0]*256+array[1];
    array.splice(0, 2);
    let asize = array.length;
    console.log("onRecvMsg size, pack[%d] array[%d]",psize, asize);
    var data = {buf:array, sz:asize};
    this.host.dispatch(data,util.handler3(this.onPushData,this),util.handler3(this.onReponseData,this));
};
netManager.sendMsg = function(msgName,msg){
    cc.log("sendMsg:",msgName,msg);
    if(this.sender){
        this.sessionId = this.sessionId + 1;
        this.sessionIdMap[this.sessionId] = msgName;
        var obj = this.sender(msgName, msg, this.sessionId);
        var buf = obj.buf;
        var size = obj.sz;
        buf.unshift(size%256)
        buf.unshift(Math.floor(size/256))
        var sendBuf = new Uint8Array(buf).buffer;
        net.sendMessage(sendBuf);
    }
};
netManager.sendHeart = function(){
    //this.sendMsg(115,{dwTime:new Date().getTime()});
}
netManager.startHeart = function(){
    var action = cc.sequence(cc.delayTime(5),cc.callFunc(util.handler(this.sendHeart,this)));
    this.heartNode.runAction(cc.repeatForever(action));
}
netManager.stopHeart = function(){
    this.heartNode.stopAllActions();
}
netManager.closeSocket = function(){
    net.close();
}
module.exports = netManager;
