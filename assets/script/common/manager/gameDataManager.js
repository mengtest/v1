/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 14:06:53
 * @LastEditTime: 2019-07-10 14:23:20
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

let GameData = require('../dataModel/gameData');

let GameDataManager = cc.Class({
    name: "GameDataManager",
    properties: {

        gameData: {
            type: GameData,
            default: null
        }
       
    },
    ctor () {
        this.gameData = new GameData();
    },

    statics: { 
        instance: null,
        getInstance(){
            if(this.instance == null) {
                this.instance = new GameDataManager();
            }
            return this.instance;
        }
    },

    getGameData() {
        return this.gameData;
    }

});
