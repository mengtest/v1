/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 16:10:43
 * @LastEditTime: 2019-07-11 16:54:13
 */

let UIManager = cc.Class({

    name: "UIManager",

    properties: {

        uiList: [], // 主界面 
        uiRoot: null, // 根界面

        popViewList: null, // 界面弹出框

    },

    statics: {

        instance: null,

        getInstance () { 
            if( this.instance == null ) {
                this.instance = new UIManager();
            }
            return this.instance;
        }
    },

    ctor () {

        this.uiRoot = cc.find("Canvas");
        this.popViewList = new Map();
    },

    descrip () {
        let str = ''
        for (let index = 0; index < this.uiList.length; index++) {
            let element = this.uiList[index];
            str +=  element.name + " "
        }
        return str;
    },

    openUI ( uiClass, zOrder, callback, onProgress, ...args) {
        if(this.getUI(uiClass)){
            return;
        }
        cc.loader.loadRes(uiClass.getUrl(),(completedCount, totalCount, item)=>{

            if(onProgress) {
                onProgress(completedCount, totalCount, item);
            }

        }, (error, prefab)=> {

            if(error) {
                cc.log(error);
                return;
            }
            if(this.getUI(uiClass)) {
                return;
            }
            
            let uiNode = cc.instantiate(prefab);
            uiNode.parent = this.uiRoot;

            if (zOrder) { uiNode.zIndex = zOrder; }
            let ui = uiNode.getComponent(uiClass);
            ui.tag = uiClass;
            this.uiList.push(ui);
            if(callback) {
                callback(args);
            }
      
        });
        
    },

    closeUI(uiClass) {

        for(let i = 0; i < this.uiList.length; ++i) {
        
            if(this.uiList[i].tag === uiClass) {
               
                this.uiList[i].node.destroy();
                this.uiList.splice(i, 1);
               
                return;
            }
        }
        
    },

    showUI(uiClass, callback)
    {
        let ui = this.getUI(uiClass);
    
        if(ui) {

            ui.node.active = true;
            ui.onShow();
            if(callback) {
                callback();
            }

        } else {
            
            this.openUI(uiClass, 0, ()=>{
                callback&&callback();
                let ui = this.getUI(uiClass);
                ui.onShow();
            });
        }
     
    },

    hideUI(uiClass) {
        
        let ui = this.getUI(uiClass);
       
        if(ui) {
            ui.node.active = false;
        }
    },

    getUI(uiClass) {

        for(let i = 0; i < this.uiList.length; ++i) {

            if(this.uiList[i].tag === uiClass) {
                
                return this.uiList[i];
            }
        }
        return null;
    },

    openPop ( uiClass, zOrder, callback, onProgress, baseNode, ...args ) {
        
        cc.loader.loadRes(uiClass.getUrl(),(completedCount, totalCount, item)=>{

            if(onProgress) {
                onProgress(completedCount, totalCount, item);
            }

        }, (error, prefab)=> {

            if(error) {
                cc.log(error);
                return;
            }
         
            let uiNode = cc.instantiate(prefab);
            uiNode.parent = baseNode;

            if (zOrder) { uiNode.zIndex = zOrder; }
            let ui = uiNode.getComponent(uiClass);
            ui.tag = uiClass;
        
            if( this.popViewList.has( uiClass.className  ) ) {

                let arr = this.popViewList.get( uiClass.className  );
                arr.push(uiNode);

            } else {
                
                this.popViewList.set( uiClass.className , [ uiNode ] )
            }
            if(callback) {
                callback(args);
            }
      
        });
    },

    showPopView ( uiClass, baseUIClass ) {

        this.openPop( uiClass, 10, ()=>{

        }, (completedCount, totalCount, item)=>{

        },baseUIClass );
    },

    closePopView ( uiClass ){

        if( this.popViewList.has( uiClass.tag.className ) ){

            let arr = this.popViewList.get( uiClass.tag.className )

            for (let index = 0; index < arr.length; index++) {
            
                let element = arr[index];
                
                if( element.uuid == uiClass.node.uuid ) {

                    element.destroy( true );
                    arr.splice(index, 1)
                    break
                }
            }
            if( arr.length == 0 ){
                this.popViewList.delete( uiClass.tag.className )
            }
        }
        
    }  

    


});

module.exports = UIManager;