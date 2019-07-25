// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var lobbyManager = require("./lobbyManager")
var lobbyControl = {}
lobbyControl.init = function(){
    this.addEvents();
}
lobbyControl.addEvents = function(){
}
lobbyControl.removeEvents = function(){
}
lobbyControl.reqRankList = function(type){
}
lobbyControl.recvRankListMsg = function(msg){
    cc.log(msg);
    lobbyManager.setRankList(msg);
},
lobbyControl.onDestroy = function(){
    this.removeEvents();
}
module.exports = lobbyControl;
