/*
 * @Author: Michael Zhang
 * @Date: 2019-07-02 15:58:37
 * @LastEditTime: 2019-07-02 15:58:37
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

var eventManager = {}
eventManager.init = function(){
    this.events = {};
}
eventManager.addEvent = function(eventName,handler,tagName){
    if(this.events[eventName] == undefined || this.events[eventName] == null){
        this.events[eventName] = [];
    }
    cc.log(eventName);
    this.events[eventName][this.events[eventName].length] = [handler,tagName];
    cc.log(this.events[eventName]);
}
eventManager.removeEvent = function(eventName,tagName){
    if(this.events[eventName] == undefined || this.events[eventName] == null){
        return;
    }
    for (var i in this.events[eventName]){
        if(this.events[eventName][i][1] == tagName){
            this.events[eventName].splice(i,1);
            cc.log(eventName);
            cc.log(this.events[eventName]);
            return;
        }
    }    
}
eventManager.dispatchEvent = function(eventName,params){
    if(this.events[eventName] == undefined || this.events[eventName] == null){
        return;
    }
    for (var i in this.events[eventName]){
        this.events[eventName][i][0](params);
    }      
}
module.exports = eventManager;
