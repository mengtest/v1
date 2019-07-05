
var TimerFactory = {
    // create: function () {
    //     return {
    init: function (node) {
        this.node = node;
    },

    start: function (action, callback, node) {
        var node = node || this.node;
        if (typeof node == "undefined") {
            return null;
        }

        var timer = { clear: null, sequence: null, node: node };
        if (typeof action == "number") {
            action = cc.delayTime(action)
        }
        var s = cc.sequence(action, cc.callFunc(function () {
            timer.sequence = null;
            timer.clear();
            if (callback)
                callback();
        }));
        timer.sequence = s;
        timer.clear = function () {
            if (typeof node == "undefined") {
                return;
            }
            if (timer.sequence) {
                node.stopAction(timer.sequence);
                timer.sequence = null;
            }
           // node.off("active-in-hierarchy-changed", timer.clear);
        }
      //  node.on("active-in-hierarchy-changed", timer.clear);

        node.runAction(timer.sequence);
        return timer;
    },

    stop: function (timer) {
        if (typeof timer == "undefined" || timer == null) {
            return;
        }
        var node = timer.node;
        if (typeof node == "undefined") {
            return;
        }
        if (timer.sequence) {
            node.stopAction(timer.sequence);
            timer.sequence = null;
        }
       // node.off("active-in-hierarchy-changed", timer.clear);
    },
}
//     }

// }
