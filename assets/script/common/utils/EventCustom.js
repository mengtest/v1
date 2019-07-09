/*
 * @Author: Michael Zhang
 * @Date: 2019-07-05 17:59:46
 * @LastEditTime: 2019-07-09 11:26:59
 */

let EventCustom = {

    index: 0,
    functions : {},

    on(name, callback, node) {
        if (typeof this.functions[name] == "undefined") {
            this.functions[name] = {};
        }
        var index = this.index;
        this.index++;
        this.functions[name][index] = { c: callback, n: node };
        return index;
    },

    once (name, callback, node) {
        var index = this.index;
        function onceFunc(data) {
            this.off(name, index);
            callback(data, name);
        };
        return this.on(name, onceFunc, node);
    },

    emit(data,...args) {
        var name = null;
        var emitIndex = null;
        if (typeof data == "object") {
            name = data.name;
            if (typeof data.emitIndex == "object") {
                emitIndex = data.emitIndex;
            }
        } else {
            name = data;
        }

        if (typeof this.functions[name] == "undefined") {
            return;
        }
        var functions = this.functions[name];
       // var args = [];
        // for (var i = 1; i < argList.length; i++) {
        //     args.push(argList[i]);
        // }

        for(var i in functions){
        //for(var i = 0; i < functions.length; i++){
            var node = functions[i].n;
            if (typeof node != "undefined" && cc.isValid(node) == false) {
                this.off(name, i);
                continue;
            }
            if (emitIndex == null) {
                var content = JSON.stringify(args, null, 0)
                cc.log(" EventCustom.emit(" + name + ") content: \n" + content.substr(0, content.length > 1000 ? 1000 : content.length));
                break;
            } else if (emitIndex[i]) {
                var content = JSON.stringify(args, null, 0)
                cc.log(" EventCustom.emit(" + name + ") content: \n" + content.substr(0, content.length > 1000 ? 1000 : content.length));
                break;
            }
        }
        for(var i in functions){
            var node = functions[i].n;
            if (typeof node != "undefined" && cc.isValid(node) == false) {
                this.off(name, i);
                continue;
            }
            if (emitIndex == null) {
                cc.log(" to " + functions[i].c);
                functions[i].c(args);
            } else if (emitIndex[i]) {
                cc.log(" to " + functions[i].c);
                functions[i].c(args);
            }
        }
    },

    off(name, index) {
        if (typeof index !== "undefined") {
            delete this.functions[name][index];
            for (var i in this.functions[name]) {
                return;
            }
        }

        delete this.functions[name];
    }
}

module.exports = EventCustom;
