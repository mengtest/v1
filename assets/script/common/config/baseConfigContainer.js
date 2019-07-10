/*
 * @Author: Michael Zhang
 * @Date: 2019-07-10 11:09:54
 * @LastEditTime: 2019-07-10 11:38:08
 */

let BaseConfigContainer = cc.Class({

    properties: {

        tag: {
            get: function (){
                return this.mTag;
            },
            set: function(value) {
                this.mTag = value;
            }
        },
        
    },

});

module.exports = BaseConfigContainer;