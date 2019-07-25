/*
 * @Author: Michael Zhang
 * @Date: 2019-07-08 10:16:56
 * @LastEditTime: 2019-07-16 11:45:10
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
var util = {}
util.handler = function (callBack, target) {
    var bindFunc = function (params) {
        callBack.call(target, params);
    };
    return bindFunc;
}
util.handler2 = function (callBack, target) {
    var bindFunc = function (param1, param2) {
        callBack.call(target, param1, param2);
    };
    return bindFunc;
}
util.handler3 = function (callBack, target) {
    var bindFunc = function (...args) {
        callBack.call(target, ...args);
    };
    return bindFunc;
}
util.toString = function (param) {
    if (typeof param == "string") {
        var index1 = param.indexOf('\'');
        var index2 = param.lastIndexOf('\'');
        if (index1 >= 0 && index2 > 0 && index2 > index1) {
            var str = param.slice(index1 + 1, index2);
            return str;
        }
    }
    return param;
}
util.toInt = function (param) {
    if (typeof param == "string") {
        for (var i = 0; i < param.length; i++) {
            var code = param.charCodeAt(i);
            if ((code != 46 && code < 48) || code > 57) {
                return param;
            }
        }
        param = parseInt(param);
    }
    return param;
}
util.convertMoney = function (money) {
    var str = money;
    if (money >= 100000000) {
        str = Math.floor((money / 100000000) * 100) / 100 + "亿";
    } else if (money >= 10000) {
        str = Math.floor((money / 10000) * 100) / 100 + "万";
    } else {
        str = Math.floor(money * 100) / 100;
    }
    return str;
}
util.parseLuaStr = function (luaStr) {
    console.log("util.parseLuaStr");
    var index1 = luaStr.indexOf('.');
    var index2 = luaStr.indexOf('(');
    var index3 = luaStr.lastIndexOf(')');
    var head = null;
    var func = null;
    var params = [];
    if (index1 > 0 && index2 > 0 && index3 > 0 && index3 > index2) {
        head = luaStr.slice(0, index1);
        func = luaStr.slice(index1 + 1, index2);
        var findIndex = index2;
        for (var i = index2 + 1; i <= index3; i++) {
            if (luaStr.charAt(i) == '\'') {
                for (var j = i + 1; j <= index3; j++) {
                    if (luaStr.charAt(j) == '\'') {
                        var parm = luaStr.slice(i + 1, j);
                        var param = this.toString(parm);
                        i = j + 1;
                        findIndex = j + 1;
                        console.log(param);
                        params.push(param);
                        break;
                    }
                }
            } else {
                var divIndex = luaStr.indexOf(',', i);
                if (divIndex > 0) {
                    var parm = luaStr.slice(i, divIndex);
                    var param = this.toString(parm);
                    console.log(this.toInt(param));
                    params.push(this.toInt(param));
                    i = divIndex;
                    findIndex = divIndex;
                }
                if (i == index3 && findIndex < i) {
                    var parm = luaStr.slice(findIndex + 1, i);
                    var param = this.toString(parm);
                    console.log(this.toInt(param));
                    params.push(this.toInt(param));
                }
            }
        }
        return { head: head, func: func, params: params };
    }
}

util.formatDateTime = function (timeStamp) {
    let date = new Date();
    date.setTime(timeStamp);
    let y = date.getFullYear();
    let m = date.getMonth() + 1;
    m = m < 10 ? ('0' + m) : m;
    let d = date.getDate();
    d = d < 10 ? ('0' + d) : d;
    let h = date.getHours();
    h = h < 10 ? ('0' + h) : h;
    let minute = date.getMinutes();
    let second = date.getSeconds();
    minute = minute < 10 ? ('0' + minute) : minute;
    second = second < 10 ? ('0' + second) : second;
    return y + '-' + m + '-' + d + ' ' + h + ':' + minute + ':' + second;
}
    util.addClickEvent =function(node,target,component,handler){
        console.log(component + ":" + handler);
        var eventHandler = new cc.Component.EventHandler();
        eventHandler.target = target;
        eventHandler.component = component;
        eventHandler.customEventData = node;
        eventHandler.handler = handler;
        var clickEvents = node.getComponent(cc.Button).clickEvents;
        clickEvents.push(eventHandler);
    }
//随机数包含n,不包含m
util.random = function (n, m) {
    var ma1 = (Math.random() * (m - n)) + n;
    var random = parseInt(ma1, 10);
    return random;
}

module.exports = util;