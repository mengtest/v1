/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 15:42:45
 * @LastEditTime: 2019-07-11 15:56:27
 */
let core = cc.Class({
    
    isObject : function (param) {
        return typeof (param) === "object"
    },
    isArray : function (param) {
        return typeof (param) === "Array" || param instanceof Array
    },
    isNumber : function (param) {
        return !isNaN(param)
    },
    isNaN : function (param) {
        return isNaN(param)
    },
    isFunction : function (param) {
        return typeof (param) === "function"
    },
    isString : function (param) {
        return typeof (param) === "string"
    },
    random : function (min, max) {
        switch (arguments.length) {
            case 1: return parseInt(Math.random() * min + 1)
            case 2: return parseInt(Math.random() * (max - min + 1) + min)
            default: return math.random()
        }
    },
    clone : function (obj) {
        if (this.isUndefined(obj)) {
            return null
        }
        if (this.isArray(obj)) {
            var newArray = new Array()
            for (var i = 0, length = obj.length; i < length; ++i) {
                newArray[i] = this.clone(obj[i])
            }
            return newArray
        }
        if (this.isObject(obj)) {
            var newObj = new Object()
            for (var i in obj) {
                newObj[i] = this.clone(obj[i])
            }
            return newObj
        }
        return obj
    },
    //合并但是不改变dest
    merge : function (dest, src) {
        var t = this.clone(dest)
        if (!src) {
            return t
        }
        if (this.isArray(src)) {
            t = t || []
            var tlen = t.length
            for (var i = 0, len = src.length; i < len; ++i) {
                var value = src[i]
                if (this.isFunction(value)) {
                    continue
                }
                if (this.isArray(value) || this.isObject(value)) {
                    if (i < tlen) {
                        t[i] = this.merge(null, value)
                    }
                    else {
                        t.push(this.merge(null, value))
                    }

                }
                else {
                    if (i < tlen) {
                        t[i] = value
                    }
                    else {
                        t.push(value)
                    }
                }
            }
        }
        else if (this.isObject(src)) {
            t = t || {}
            for (var key in src) {
                var value = src[key]
                if (this.isFunction(value)) {
                    continue
                }
                if (this.isArray(value) || this.isObject(value)) {
                    t[key] = this.merge(null, value)
                }
                else {
                    t[key] = value
                }
            }
        }
        else {
            t = src
        }
        return t
    },

    //只是取出template里面已经有的部分
    getExit : function (template, src) {
        if (!src || !template) {
            return {}
        }
        var t = {}
        for (var key in src) {
            if (this.isUndefined(template[key])) {
                continue
            }
            var value = src[key]
            if (this.isFunction(value)) {
                continue
            }
            if (this.isArray(value) || this.isObject(value)) {
                t[key] = this.getExit(template[key], value)
            }
            else {
                t[key] = value
            }
        }
        return t
    },
    dump : function (data) {
        var strSpace = "    "
        var _dump = function (data,intent) {
            var startIntentStr = ""
            for (var i = 0; i < intent; ++i) {
                startIntentStr += strSpace
            }
            var contentStr = ""
            if (this.isArray(data)) {
                contentStr += "\n" + startIntentStr + "[\n"
                for (var i = 0, length = data.length; i < length; ++i) {
                    if (!this.isArray(data[i]) && !this.isObject(data[i]) && !this.isFunction(data[i])) {
                        contentStr += startIntentStr + strSpace + _dump(data[i], intent + 1) + ",\n"
                    }
                    else {
                        contentStr += startIntentStr + _dump(data[i], intent + 1) + ",\n"
                    }
                }
                contentStr += startIntentStr + "]"
            }
            else if (this.isObject(data)) {
                contentStr += startIntentStr + "{\n"
                for (var key in data) {
                    contentStr += startIntentStr + strSpace + key + ":" + _dump(data[key], intent + 1) + ",\n"
                }
                contentStr += startIntentStr + "}"
            }
            else if (!this.isFunction(data)) {
                if (this.isString(data)) {
                    return "\"" + data + "\""
                }
                return data
            }
            if (contentStr == "") {
                return ""
            }
            return contentStr
        }
        console.log(_dump(data, 0))
    },

    toArray : function (table) {
        var array = []
        for (var key in table) {
            if (this.isFunction(table[key])) {
                continue
            }
            array.push(key)
            array.push(table[key])
        }
        return array
    },

    foreach : function (items, callback) {
        if (!items || !callback) {
            return
        }
        if (this.isNumber(items)) {
            for (var i = 0; i < items; ++i) {
                var ret = callback(i)
                if (ret) {
                    return
                }
            }
        }
        else if (this.isString(items)) {
            for (var i = 0, length = items.length; i < length; i++) {
                var ret = callback(i, items.charAt(i))
                if (ret) {
                    return
                }
            }
        }
        else if (this.isArray(items)) {
            for (var i = 0, length = items.length; i < length; ++i) {
                var ret = callback(i, items[i])
                if (ret) {
                    return
                }
            }
        }
        else if (this.isObject(items)) {
            for (var key in items) {
                var ret = callback(key, items[key])
                if (ret) {
                    return
                }
            }
        }
        return
    },

    length : function (items) {
        if (this.isArray(items)) {
            return items.length
        }
        if (this.isObject) {
            var len = 0
            this.foreach(items, function () {
                ++len
            })
            return len
        }
        return 0
    },
    find : function (items, callback) {
        if (!items || !callback) {
            return
        }
        if (this.isArray(items)) {
            for (var i = 0, length = items.length; i < length; ++i) {
                if (callback(items[i]) === true) {
                    return items[i]
                }
            }
        }
        else if (this.isObject(items)) {
            for (var key in items) {
                if (callback(items[key]) === true) {
                    return items[key]
                }
            }
        }
    },

    indexOf : function (items, value) {
        if (!items || !value) {
            return -1
        }
        if (this.isArray(items)) {
            for (var i = 0, length = items.length; i < length; ++i) {
                if (items[i] === value) {
                    return i
                }
            }
        }
        else if (this.isObject(items)) {
            for (var key in items) {
                if (items[key] === value) {
                    return key
                }
            }
        }
        return -1
    },
    include : function (objs, key) {
        var r = false
        this.foreach(objs, function (k, obj) {
            if (k == key) {
                r = true
                return true
            }
        })
        return r
    },
    supportsWebSocket : function () {
        return window.WebSocket || window.MozWebSocket
    },

    userAgentContains : function (string) {
        return navigator.userAgent.indexOf(string) != -1
    },

    isTablet : function (screenWidth) {
        if (screenWidth > 640) {
            if ((this.userAgentContains('Android') && this.userAgentContains('Firefox'))
                || this.userAgentContains('Mobile')) {
                return true
            }
        }
        return false
    },

    isWindows : function () {
        return this.userAgentContains('Windows')
    },

    isChromeOnWindows : function () {
        return this.userAgentContains('Chrome') && this.userAgentContains('Windows')
    },

    canPlayMP3 : function () {
        return Modernizr.audio.mp3
    },

    isSafari : function () {
        return this.userAgentContains('Safari') && !this.userAgentContains('Chrome')
    },

    isOpera : function () {
        return this.userAgentContains('Opera')
    },
    isInt : function (n) {
        return (n % 1) === 0
    },

    removeAt : function (arr, index) {
        if (typeof arr === "undefined" || typeof index === "undefined") {
            return arr
        }
        if (!this.isArray(arr)) {
            return arr
        }
        var len = arr.length
        if (isNaN(index) || index >= len || index < 0) {
            return arr
        }
        for (var i = 0; i < len - 1; ++i) {
            if (i < index) {
                continue
            }
            else {
                arr[i] = arr[i + 1]
            }
        }
        arr.length -= 1
        return arr
    },
    char2buf : function (str) {
        var out = new ArrayBuffer(str.length * 2);
        var u16a = new Uint16Array(out);
        var strs = str.split("");
        for (var i = 0; i < strs.length; i++) {
            u16a[i] = strs[i].charCodeAt();
        }
        return out;
    },

    array2arraybuffer : function (array) {
        var b = new ArrayBuffer(array.length);
        var v = new DataView(b, 0);
        for (var i = 0; i < array.length; i++) {
            v.setUint8(i, array[i]);
        }
        return b;
    },

    arraybuffer2array : function (buffer) {
        var v = new DataView(buffer, 0);
        var a = new Array();
        for (var i = 0; i < v.byteLength; i++) {
            a[i] = v.getUint8(i);
        }
        return a;
    },

    firstCharUpCase : function (str) {
        var reg = /\b(\w)|\s(\w)/g
        str = str.toLowerCase()
        return str.replace(reg, function (m) { return m.toUpperCase() })
    },

    getGoogleProtoSetName : function (str) {
        var strs = str.split("_")
        var result = "set"
        this.foreach(strs, function (index, s) {
            result += this.firstCharUpCase(s)
        })
        return result
    },

    convertIntToUInt8Array : function (num) {
        var c2 = num % 256
        var c1 = Math.floor(num / 256)

        var c = [c1, c2]
        return c
    },

    convertUInt8ArrayToInt : function (array) {
        if (array.length != 2) {
            return 0
        }
        return array[0] * 256 + array[1]
    },
    //从一个数组里面按照下标和长度的方式去获取另一个数组，至少返回空数组
    //包含start
    getArrayFromArray : function (data, start, l) {
        var len = data.length
        start = start || 0//默认最开始
        l = l || len//默认到最后
        if (start >= len) {
            return []
        }
        var arr = []
        for (var i = start; i < start + l && i < len; ++i) {
            arr.push(data[i])
        }
        return arr
    },

    blobToArrayBuffer : function (data, callback) {
        if (cc.sys.isNative) {
            callback(data)
            return
        }
        var fileReader = new FileReader()
        fileReader.onload = function (progressEvent) {
            if (callback) {
                callback(this.result)
            }
        }
        fileReader.readAsArrayBuffer(data)
    },

})

module.exports = new core();