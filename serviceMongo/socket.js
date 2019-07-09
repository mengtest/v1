/*
 * @Author: Michael Zhang
 * @Date: 2019-07-05 13:44:54
 * @LastEditTime: 2019-07-08 18:23:16
 */
var ws = require("nodejs-websocket");
let proto = require('./lib/proto');

console.log("开始建立连接...");
var str1 = null, str2 = null, clientReady = false, serverReady = false;
var a = [];
var server = ws.createServer(function (conn) {
    conn.on('text', function (str) {
        
        let obj = JSON.parse(str);

        let base = proto.Hongzao.BaseProtocol.create(obj.base);
        base.ts = (new Date()).getTime();    
        
        let dicts = {
            heartbreak: proto.Hongzao.HeartBreak
        }
        let myClass = dicts[base.act];
        
        if( base.act == 'heartbreak' ){
           
            conn.sendText(JSON.stringify(myClass.create({
                base: base,
                username: obj.username
            })));

        }

        

        // if (!clientReady) {
        //     if (a[0] === str) {
        //         str1 = conn;
        //         clientReady = true;
        //         str1.sendText("欢迎你" + str);

        //     }
        // } else if (!serverReady) {
        //     if (str.indexOf('close') >= 0) {
        //         a.splice(2, 1);
        //         clientReady = false;
        //         str1 = null;
        //         return;
        //     }
        //     if (a[1] === str) {
        //         str2 = conn;
        //         serverReady = true;
        //         str2.sendText("欢迎你" + str);
        //         str1.sendText(str + "在线啦，你们可以聊天啦");
        //         return;
        //     }
        // } else if (clientReady && serverReady) {
        //     str2.sendText(str);
        //     str1.sendText(str);
        //     if (str.indexOf('close') >= 0) {
        //         a.splice(2, a.length);
        //         var len = a.length;
        //         for (var i = 0; i < len; i++) {
        //             // 定位该元素位置
        //             if (str.indexOf(a[i]) >= 0) {
        //                 a.splice(i, 1);
        //                 if (i == 0) {
        //                     str1 = str2;
        //                 }
        //                 serverReady = false;
        //                 str2 = null;
        //                 return;
        //             }

        //         }
        //     }
        // }


    })

    conn.on("close", function (code, reason) {
        console.log("关闭连接");
        clientReady = false;
        serverReady = false;
    })
    conn.on("error", function (code, reason) {
        console.log("异常关闭");
    });
}).listen(8082);
console.log("websocket连接完毕")