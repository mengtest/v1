/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 15:49:58
 * @LastEditTime: 2019-07-09 17:20:12
 */
String.format = function(src){
    if (arguments.length == 0) return null;
    var args = Array.prototype.slice.call(arguments, 1);
    return src.replace(/\{(\d+)\}/g, function(m, i){
        return args[i];
    });
};

// 座机
// const phoneRule = /^[0]?\d{2,3}[- ]?\d{7,8}$/
// 座机及手机
// const telephoneRule = /^[0]?\d{2,3}[- ]?\d{7,8}$|(?:^1[3456789]|^9[28])\d{9}$/
