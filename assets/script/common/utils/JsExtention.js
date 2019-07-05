/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 15:49:58
 * @LastEditTime: 2019-07-04 15:50:08
 */
String.format = function(src){
    if (arguments.length == 0) return null;
    var args = Array.prototype.slice.call(arguments, 1);
    return src.replace(/\{(\d+)\}/g, function(m, i){
        return args[i];
    });
};