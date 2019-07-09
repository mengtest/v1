/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 16:10:20
 * @LastEditTime: 2019-07-09 18:07:48
 */

if( !CC_EDITOR ) {

    let httpData = cc.Class({

        statics: {
            
            data: [
                {"ID":1, "Host":"http://142.4.117.17:8000", "Route":"/user/code", "Params":"phone", "Method":"GET", "Remark":"获取验证码"}
            ],
        
            getDataByID (id) {
        
                for (let index = 0; index < this.data.length; index++) {
                    let element = this.data[index];
                    if( element.ID == id ){
                        return element;
                    }
                }
                return null;
            },

            sendHttp (id, data, handle, obj) {
        
        
                let da = httpData.getDataByID(id);
                
                var url = da.Host;
                var externUrl = da.Route;
                var isPost = da.Method == "POST";
                
                // HTTPTool.sendRequest(url, externUrl, data, handle, isPost, obj)
            }
        }
    })
    
    let net = require('../network/net');
    let netObj = new net();
    
    module.exports = netObj;
} 

