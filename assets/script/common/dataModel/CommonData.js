/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 16:05:19
 * @LastEditTime: 2019-07-11 13:45:02
 */

let Enums = require('./enums')

let CommonData = cc.Class({
    
    statics: {

        AUDIO_DIR: "audio/",
        CONFIG_FILE_DIR: "config/",
        PREFAB_UI_DIR: "prefab/",
        TEXTURE_DIR: "texture/",

        GAME_SERVER_TYPE: Enums.SERVER_TYPE.WEBSOCKET,
        GAME_SERVER_IP: "127.0.0.1",
        GAME_SERVER_PORT: "8082",
        GAME_SERVER_WS_URL: function () {
            return "ws://" + this.GAME_SERVER_IP + ":" + this.GAME_SERVER_PORT;
        },
        GAME_SERVER_HTTP_URL: function () {
            return 'http://' + this.GAME_SERVER_IP + ":" + this.GAME_SERVER_PORT + "/";
        },

        


    }
});

module.exports = CommonData;