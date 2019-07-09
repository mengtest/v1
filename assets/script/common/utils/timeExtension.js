/*
 * @Author: Michael Zhang
 * @Date: 2019-07-09 17:20:35
 * @LastEditTime: 2019-07-09 17:25:52
 */

// 获取当前时间
Date.getNowTime = function() {
    return new Date();
}

// 时间与天数相加
Date.getTimeAddDays = function(time, days) {
    return new Date(time.getTime() + days * 24 * 60 * 60 * 1000);
}

// 获取并格式化日期：年-月-日
Date.getFormatDate  = function(time) {
    return time.getFullYear() + "-" + (time.getMonth() + 1) + "-" + time.getDate();
}

// 字符串转换为日期，字符串格式：2011-11-20
Date.convertToDate  = function(strings) {
    return new Date(Date.parse(strings.replace(/-/g, "/")));
}

// 时间比较
Date.compareTime = function(time1, time2)  {
    return time1.getTime() - time2.getTime();
}

// 计算两个日期之间相隔的天数
Date.getDays = function(time1, time2) {
    var day = 24*60*60*1000;
    return (time1.getTime() - time2.getTime())/day;
}
