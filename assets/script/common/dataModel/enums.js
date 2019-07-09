/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 15:53:55
 * @LastEditTime: 2019-07-09 16:59:30
 */
let enums = cc.Class( {

    statics: {

        // 配置枚举

        SERVER_TYPE: cc.Enum({  // 服务器协议 枚举

            WEBSOCKET: 0,
            HTTP: 1
        }),

        GameWebSocketState: cc.Enum({
            CONNECTING: 1,
            OPEN: 2,
            CLOSING: 3,
            CLOSED: 4
        }),

    }
});

module.exports = enums;
