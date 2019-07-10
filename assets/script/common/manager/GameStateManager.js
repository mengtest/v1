/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 16:10:59
 * @LastEditTime: 2019-07-10 15:23:22
 */

let config = require('./common/manager/configManager')
let ShopConfigContainer = require('./common/config/shopConfigContainer')

let GameDataManager = require('./gameDataManager')

 let GameStateManager = cc.Class({

    statics: {
        instance : null,
        getInstance() {
            if(this.instance == null) {
                this.instance = new GameStateManager();
            }
            return this.instance;
        }
    },

    initGame () {

        config.getInstance().loadAllConfig(()=>{
      
            GameDataManager.getInstance()

        })
    }

 });

 module.exports = GameStateManager;