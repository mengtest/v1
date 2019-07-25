/*
 * @Author: Michael Zhang
 * @Date: 2019-07-16 11:19:50
 * @LastEditTime: 2019-07-24 16:14:23
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

var sceneManager = {}
sceneManager.init = function(){
}

sceneManager.sceneParams = new Map();
sceneManager.isLoading = false

sceneManager.loadScene = function( sceneName, onProgress, onLanched, ...args ){

    if( this.isLoading ) {
        return
    } else {
        this.isLoading = true
        if( args && args.length > 0 ){
            this.sceneParams.set(sceneName, args)
        } else {
            if(this.sceneParams.has( sceneName ))
                this.sceneParams.delete( sceneName )
        }
    }
    cc.director.preloadScene( sceneName, util.handler3( onProgress, this ), ( err, sceneAsset )=>{

        if( err ){
            cc.error(err);
            this.isLoading = false
            return
        }
        
        cc.director.loadScene( sceneName, util.handler( onLanched, this ) )
        
        this.isLoading = false
    } )
}


module.exports = sceneManager;