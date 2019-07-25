/*
 * @Author: Michael Zhang
 * @Date: 2019-07-24 10:59:17
 * @LastEditTime: 2019-07-24 18:02:58
 */
// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var globalControl = {}
globalControl.init = function(initOverBack){
    function initOver(){
        if(initOverBack){
            initOverBack();
        }
    }
    globalManager.init();
    audioManager.init();
    netManager.init(util.handler(initOver,this));
    eventManager.init();
    tipManager.init();
    this.addEvents();

    cc.debug.setDisplayStats(false)
}
globalControl.addEvents = function(){
    eventManager.addEvent("NET_"+msgNameDefine.playerInfo+"_EVENT",util.handler(this.recvPlayerInfoMsg,this),"globalControl1");
};
globalControl.recvPlayerInfoMsg = function(msg){
    cc.log(msg);
    globalManager.setPlayerInfo(msg);
}
globalControl.changeScence = function(sceneName, ...agrs){
    //cc.director.loadScene("resources/"+sceneName+"/"+sceneName);
    panelManager.createPanel( panelCfg.loadingPanel, ( status, panel )=>{
        if( status ){
            sceneManager.loadScene( sceneName, (completedCount, totalCount, item)=>{ 

                if( completedCount/totalCount <= 1 ){
                    
                    panel.getChildByName('bg').getChildByName('num').getComponent(cc.Label).string = (completedCount/totalCount*100).toFixed(2) + "%"
                }

                if( completedCount/totalCount >= 1 ){
                    
                    panel.destroy();
                }
    
            }, ( )=>{

            } , ...agrs );

        }
        
    } )
}

globalControl.changeToLogin = function(){
    this.changeScence("login");
}
globalControl.changeToLobby = function(){
    this.changeScence("lobby");
}
globalControl.changeToRoom = function(gameId){
    this.changeScence("room");
}

globalControl.changeAccount = function(){
    this.isChangeAccount = true;
    netManager.closeSocket();
}

globalControl.showTip = function( text ){
    tipManager.showTip(text)
}

module.exports = globalControl