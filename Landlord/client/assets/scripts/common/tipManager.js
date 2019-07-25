/*
 * @Author: Michael Zhang
 * @Date: 2019-07-24 17:17:36
 * @LastEditTime: 2019-07-24 18:09:15
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

var tipManager = {}

tipManager.init = function(){

    function loadOver(err,prefab){
        if (err) {
            cc.error(err.message || err);
            return;
        }
        this.tipPrefab = prefab
   
    }
    cc.loader.loadRes(panelCfg.TipNode.prefab,cc.Prefab,util.handler2(loadOver,this));
}

tipManager.tips = new cc.NodePool();

tipManager.createTipNode = function () {

    let tipNode = null;

    if (this.tips.size() > 0) { // 通过 size 接口判断对象池中是否有空闲的对象

        tipNode = this.tips.get();

    } else { // 如果没有空闲对象，也就是对象池中备用对象不够时，我们就用 cc.instantiate 重新创建

        tipNode = cc.instantiate(this.tipPrefab);
    }
    tipNode.opacity = 255
    return tipNode;
}


tipManager.showTip = function( text ){
    
 
    var panel = this.createTipNode()


    cc.log( panel )

    panel.setPosition(cc.winSize.width/2.0,cc.winSize.height/2.0);
    panel.zIndex = 999;
    
    var scene = cc.director.getScene();

    panel.getComponent( require('../../scripts/common/tipNode') ).setText( text , ()=>{
        
        this.tips.put( panel )

        cc.log(2121)
    } )

    scene.addChild(panel);
        
}
module.exports = tipManager;