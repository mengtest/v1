/*
 * @Author: Michael Zhang
 * @Date: 2019-07-16 17:34:48
 * @LastEditTime: 2019-07-22 13:41:24
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
cc.Class({
    extends: cc.Component,

    properties: {

        types: {
            default: [],
            type: [cc.SpriteFrame],
        },

        type: {
            default: null,
            type: cc.Sprite,
        },

        scrollView: {
            default: null,
            type: cc.ScrollView,
        },

        rankItem: {
            default: null,
            type: cc.Prefab,
        },

        mineIndex: {
            default: null,
            type: cc.Label
        },
        mineNickname: {
            default: null,
            type: cc.Label
        },
        mineDetail: {
            default: null,
            type: cc.Label
        },

    },

    // LIFE-CYCLE CALLBACKS:

    onLoad () {

       this.navChanged(0)

    },

    start () {

    },

    onDisable() {

    },

    navChanged ( selectedIndex ) {

        this.type.spriteFrame = this.types[selectedIndex];
        
        this.scrollView.content.removeAllChildren(true);

        var obj = {
            0:[{
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },
            {
                nickname:"fafa",
                detail:"gfsfsa"
            },],
            1:[{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },{
                nickname:"fafa43",
                detail:"gfsfs31232a"
            },],
            2:[{
                nickname:"65653",
                detail:"hgjg"
            },
            {
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },{
                nickname:"65653",
                detail:"hgjg"
            },],
        } 

        for (let index = 0; index < obj[selectedIndex].length; index++) {

            let rankItem = cc.instantiate( this.rankItem );

            rankItem.getComponent( require('./rankItem') ).setData( index , obj[selectedIndex][index])

            this.scrollView.content.addChild( rankItem );
            
        }

        this.mineIndex.string = 99 + selectedIndex
        this.mineNickname.string = "瓜娃子" + selectedIndex
        this.mineDetail.string = '农名' + selectedIndex

    }

    // update (dt) {},
});
