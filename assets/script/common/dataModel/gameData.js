/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 14:07:04
 * @LastEditTime: 2019-07-10 14:21:41
 */

let PlayerInfo = cc.Class({
    name: "PlayerInfo",
    properties: {
       
    },

    statics: { 

    },

})

let GameData = cc.Class({
    name: "GameData",
    properties: {

        playerInfo: {
            type: PlayerInfo,
            default: null
        } 

    },
    ctor () {
        this.playerInfo = new PlayerInfo();
    },

    statics: { 
       
    },

    

});
