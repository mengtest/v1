/*
 * @Author: Michael Zhang
 * @Date: 2019-07-02 15:58:37
 * @LastEditTime: 2019-07-23 14:21:51
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
var panelManager = {}
panelManager.init = function(){

}
panelManager.isLoading = false
panelManager.createPanel = function(cfg,callBack,parent){
    if( this.isLoading ){
        return
    } else {
        this.isLoading = true
    }
    cc.log(cfg.prefab)
    if(cfg == null){
        if(callBack){
            callBack(false,null);
            this.isLoading = false
        }
        return;
    }
    function loadOver(err,prefab){
        if (err) {
            cc.error(err.message || err);
            if(callBack){
                callBack(false,null);
                this.isLoading = false
            }
            return;
        }
        var panel = cc.instantiate(prefab);
        panel.setPosition(cc.winSize.width/2.0,cc.winSize.height/2.0);
        panel.zIndex = 10;
        var scene = cc.director.getScene();
        if(parent == null){
            parent = scene;
        }
        parent.addChild(panel);
        if(callBack){
            callBack(true,panel);
            this.isLoading = false
        }
    }
    if(cfg.prefab){
        cc.loader.loadRes(cfg.prefab,cc.Prefab,util.handler2(loadOver,this));
    }else{
        if(callBack){
            callBack(false,null);
            this.isLoading = false
        }        
    }
}
module.exports = panelManager;