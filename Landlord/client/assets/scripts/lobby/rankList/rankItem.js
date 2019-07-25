/*
 * @Author: Michael Zhang
 * @Date: 2019-07-16 17:51:13
 * @LastEditTime: 2019-07-17 11:29:20
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

        pics: {

            default: [],
            type: [cc.SpriteFrame]

        },

        pic: {
            default: null,
            type: cc.Sprite
        },
        index: {
            default: null,
            type: cc.Label
        },
        nickname: {
            default: null,
            type: cc.Label
        },
        detail: {
            default: null,
            type: cc.Label
        },

        _ptop2: cc.v2(0,0),
        _pBottom2: cc.v2(0,0)

    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {

        let pP = this.node.parent.parent.getPosition()
        let pS = this.node.parent.parent.getContentSize()
        let ptop =  cc.v2( pP.x , pP.y - pS.height/2 )
        let pBottom = cc.v2( pP.x , pP.y + pS.height/2 )

        this._ptop2 = this.node.parent.parent.parent.convertToWorldSpaceAR( ptop );
        this._pBottom2 = this.node.parent.parent.parent.convertToWorldSpaceAR( pBottom );
        
    },

    update (dt) { 

        let pP = this.node.getPosition()
        let pS = this.node.getContentSize()
        let ptop =  cc.v2( pP.x , pP.y - pS.height/2 )
        let pBottom = cc.v2( pP.x , pP.y + pS.height/2 )

        let ptop3 = this.node.parent.convertToWorldSpaceAR( ptop );
        let pBottom3 = this.node.parent.convertToWorldSpaceAR( pBottom );
    
        if( ptop3.y >= this._pBottom2.y || pBottom3.y <= this._ptop2.y ) {
            
            if( !this.detail.node.active ) return
            this.index.node.active = this.nickname.node.active = this.detail.node.active = false

        } else {
                        
            if( this.detail.node.active ) return
            this.index.node.active = this.nickname.node.active = this.detail.node.active = true
        }

    },

    setData ( index, data  ) {

        if( index < this.pics.length )  {

            this.pic.spriteFrame = this.pics[index];

        } else {
            this.pic.spriteFrame = null;
        }

        this.index.string = index + 1;

        if( data ) {

            this.nickname.string = data.nickname
            this.detail.string = data.detail
        }

    }

});
