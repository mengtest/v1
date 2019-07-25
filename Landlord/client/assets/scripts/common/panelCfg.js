/*
 * @Author: Michael Zhang
 * @Date: 2019-07-02 15:58:37
 * @LastEditTime: 2019-07-24 17:15:26
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
var panelCfg = {
    //login
    loginPanel:{
        prefab: "login/Prefab/loginPanel"
    },
    registerPanel:{
        prefab: "login/Prefab/registerPanel"
    },
    findPanel:{
        prefab: "login/Prefab/findPanel"
    },
    
    //lobby
    basePanel:{
        prefab: "common/Prefab/basePanel"
    },
    loadingPanel:{
        prefab: "common/Prefab/loading/loading"
    },
    rankListPanel:{
        prefab: "lobby/Prefab/rankList/rankListPanel"
    },
    knapsackPanel:{
        prefab: "lobby/Prefab/knapsack/knapsackPanel"
    },
    signPanel:{
        prefab: "lobby/Prefab/sign/signPanel"
    },
    SetPanel:{
        prefab: "lobby/Prefab/set/SetPanel"
    },
    TaskPanel:{
        prefab: "lobby/Prefab/task/TaskPanel"
    },
    GameInfoPanel:{
        prefab: "lobby/Prefab/GameInfo/GameInfoPanel"
    },
    EamilPanel:{
        prefab: "lobby/Prefab/email/EamilPanel"
    },

    TipNode:{
        prefab: "common/Prefab/tipNode"
    },
};
module.exports = panelCfg;
