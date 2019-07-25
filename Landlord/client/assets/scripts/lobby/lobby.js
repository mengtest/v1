/*
 * @Author: Michael Zhang
 * @Date: 2019-07-02 15:58:37
 * @LastEditTime: 2019-07-17 11:42:19
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
var lobbyControl = require("./lobbyControl")
var lobbyManager = require("./lobbyManager")
cc.Class({
    extends: cc.Component,

    properties: {

    },

    // LIFE-CYCLE CALLBACKS:

    onLoad () {
        lobbyControl.init();
        lobbyManager.init();
        
    },
    start () {
    
    },
    onRuleClick(){
        panelManager.createPanel( panelCfg.TaskPanel, ( err, panel )=>{ }, this.onde )
    },
    onEMailClick(){
        panelManager.createPanel( panelCfg.EamilPanel, ( err, panel )=>{ }, this.onde )
    },
    onSettingClick(){
        
        panelManager.createPanel( panelCfg.SetPanel, ( err, panel )=>{ }, this.onde )
    },
    onSignInClick(){
        panelManager.createPanel( panelCfg.signPanel, ( err, panel )=>{ }, this.onde )
    },
    onNoticeClick(){
        panelManager.createPanel( panelCfg.basePanel, ( err, panel )=>{ }, this.onde )
    },
    onKnapsackClick(){
        panelManager.createPanel( panelCfg.knapsackPanel, ( err, panel )=>{ }, this.onde )
    },
    onRankListClick(){
        panelManager.createPanel( panelCfg.rankListPanel, ( err, panel )=>{ }, this.onde )
    },
    onQuickStartClick(){
        panelManager.createPanel( panelCfg.basePanel, ( err, panel )=>{ }, this.onde )
    },
    onheadClick(){
        panelManager.createPanel( panelCfg.GameInfoPanel, ( err, panel )=>
        {
           // panel.getComponent("gameinfo").showToggle(2);
         }, this.onde )
    },
    onBtnClick(){
        audioManager.playAudio("common/audio/click")
    },
    updateGameInfo:function()
    {
        cc.log("刷新大厅数据")
    },
    onDestroy(){
        lobbyControl.onDestroy();
        lobbyManager.onDestroy();
    },
    // update (dt) {},
});
