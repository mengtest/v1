// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var util = require("../util");
var netState = cc.Enum({
    DISCONNECT:0,
    CONNECTING:1,
    CONNECTED:2,
    COLSED:3,
    COLSING:4,
});
var net = {}
net.init = function(connectBack,onRecvMsgBack){
    this.currState = netState.DISCONNECT;
    this.connectBack = connectBack;
    this.onRecvMsgBack = onRecvMsgBack;
    this.netState = netState; 
};
net.connect = function(ip,port){
if(port == undefined || port == null)
{
    this.ws = new WebSocket("ws://"+ip);
}
else
{
    this.ws = new WebSocket("ws://"+ip+":"+port);
}
this.ws.onopen = util.handler(this.onOpen,this);
this.ws.onmessage = util.handler(this.onMessage,this);
this.ws.onerror = util.handler(this.onError,this);
this.ws.onclose = util.handler(this.onClose,this);
this.changeState(netState.CONNECTING);
};
net.sendMessage = function(data){
    if(this.currState == netState.CONNECTED){
        this.ws.send(data)
    }
}
net.close = function(){
    cc.log("net close");
    this.ws.close();
    this.changeState(netState.COLSING);
}
net.onOpen = function(event){
    console.log("Send Text WS was opened.");
    this.ws.binaryType = 'arraybuffer';
    this.changeState(netState.CONNECTED);
};
net.onMessage = function (event) {
    console.log("response text msg: " + event.data);
    if(this.onRecvMsgBack)
    {
        this.onRecvMsgBack(event.data);
    }
};
net.onError = function (event) {
    console.log("Send Text fired an error");
};
net.onClose = function (event) {
    console.log("WebSocket instance closed.");
    this.changeState(netState.COLSED);
};
net.changeState = function(state){
    if(state == this.currState)
    {
        return;
    }
    this.currState = state;
    if(this.connectBack){
        this.connectBack(this.currState);
    }
};
module.exports= net;