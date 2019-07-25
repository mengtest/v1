/*
 * @Author: Michael Zhang
 * @Date: 2019-07-19 14:02:41
 * @LastEditTime: 2019-07-24 17:24:32
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
var panelManager = require("../common/panelManager")
var panelCfg = require("../common/panelCfg")
cc.Class({
    extends: cc.Component,

    properties: {

        titles:{
            default:[],
            type:[cc.SpriteFrame],
            tooltip: "经典 0，不洗牌 1，癞子玩法 2"
        },

        config: cc.JsonAsset,


        title: {
            default: null,
            type: cc.Sprite,
            tooltip:"标题"
        },
        
        returnlobbyBtn:{
            type:cc.Sprite,
            default:null,
            tooltip:"返回按钮"
        },
        roomList:{
            default:null,
            type:cc.Node,
            tooltip:"房间列表"
        },


        _typeIndex: 0,
        _roomIndex: 0,

    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},
    addEvents(){
        eventManager.addEvent("NET_"+msgNameDefine.enterGame+"_EVENT",util.handler(this.recEnterGameMsg,this),"entergame1");
    },

    recEnterGameMsg( msg ) {
        cc.log( msg )

        if( msg.e == 0 ) {

             // 1 新手场 2 普通场 3 精英场 4 大师场
            globalControl.changeScence( "room" , this._roomIndex)
            
        } else {

            globalControl.showTip( "加入房间失败" )
            cc.log( "加入房间失败" )
        }
    },

    start () {

        this.addEvents()

        var room = this.roomList.children;
        var k = 0;
        for(var i  in room)
        {
            k++;
            var selectroombtn = this.roomList.getChildByName(k.toString()).addComponent(cc.Button);  
            util.addClickEvent(selectroombtn.node,this.node,"roomselectControl","goGameplay");
        }

        if( sceneManager.sceneParams.has( cc.director.getScene().name ) ){ // 场景跳转参数处理

            let params = sceneManager.sceneParams.get( cc.director.getScene().name )[0]

            // 0 经典 1 癞子 3 不洗牌 2 快速开始
            this.setRoomSelectInfo( params == 0 ? params : ( params == 1 ? 2 : ( params == 3 ? 1 : params ) ) )

        }

    },

    /**
     * 0 经典 1 癞子 3 不洗牌 2 快速开始
     * @param {*} type 
     */
    setRoomSelectInfo ( typeIndex ) {

        this._typeIndex = typeIndex

        this.title.spriteFrame = this.titles[ typeIndex ]

        for (let index = 0; index < this.roomList.children.length; index++) {
            
            let element = this.roomList.getChildByName( (index + 1) + '')

            element.getChildByName('limt').getComponent(cc.Label).string = "准入：" + this.config.json[index].value1
            element.getChildByName('difen').getComponent(cc.Label).string = "底分：" + this.config.json[index].value2
        } 

    },


    returnLobby:function()
    {
        cc.director.loadScene("lobby");
    },
    goGameplay:function(e, obj)
    {
        cc.log(obj.name)
        
        netManager.sendMsg(msgNameDefine.enterGame,{"gameid":"ddz", "roomid":1});

        this._roomIndex = obj.name
       
    },
    onBtnClick(){
        audioManager.playAudio("common/audio/click")
    },

    setting() {
        panelManager.createPanel( panelCfg.SetPanel, ( err, panel )=>{ }, this.onde )
    },
    help() {
        panelManager.createPanel( panelCfg.basePanel, ( err, panel )=>{ }, this.onde )
    },

    quickStart () {

    },

    // update (dt) {},

    onDestroy() {
        this.removeEvents()
    },

    removeEvents(){
        eventManager.removeEvent("NET_"+msgNameDefine.enterGame+"_EVENT","entergame1");
    }
});
