// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var globalManager = {}
globalManager.init = function(){
    this.roomId = 0;
    this.isReconnect = 0;
    this.serverTime = 0;
    if(this.updateNode){
        cc.game.removePersistRootNode(this.updateNode);
    }
    this.updateNode = new cc.Node("updateNode");
    cc.game.addPersistRootNode(this.updateNode);
    var action = cc.sequence(cc.delayTime(0.1),cc.callFunc(util.handler(this.updateTime,this)));
    this.updateNode.runAction(cc.repeatForever(action));
    this.mails = {};
}
globalManager.updateTime = function(){
    this.serverTime += 100;
}
globalManager.setRoomId = function(roomId){
    this.roomId = roomId;
}
globalManager.getRoomId = function(){
    return this.roomId;
}
globalManager.setIsReconnect = function(isReconnect){
    this.isReconnect = isReconnect;
}
globalManager.getIsReconnect = function(){
    return this.isReconnect;
}
globalManager.setPlayerInfo = function(playerInfo){
    this.playerInfo = playerInfo;
}
globalManager.getPlayerInfo = function(){
    return this.playerInfo;
}
globalManager.getPlayerId = function(){
    return this.playerInfo.rid;
}
globalManager.setPlayerMoney = function(money){
    this.playerInfo.money1 = money;
}
globalManager.setServerTime = function(serverTime){
    this.serverTime = serverTime;
}
globalManager.getServerTime = function(){
    return this.serverTime;
}
module.exports = globalManager;
