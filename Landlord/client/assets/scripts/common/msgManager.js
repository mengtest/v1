// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var protobuf = require('protobuf')
var msgManager = {}
var protoMsgFile = [
    "proto/LoginMessage",
];
msgManager.init = function(initOverBack){
    this.protoMsg = {};
    this.initOverBack = initOverBack;
    this.haveLoadProtoCount = 0;
    function bindLoadResBack(callBack,target){
        var bindFunc = function(err,data){
            callBack.call(target,err,data);
        };
        return bindFunc;        
    }
    for(var i = 0;i < protoMsgFile.length;i++)
    {
        cc.loader.loadRes(protoMsgFile[i],bindLoadResBack(this.loadResBack,this));        
    }
};
msgManager.loadResBack = function(err,data){
    if (err) {
        cc.error(err.message || err);
        return;
    }
    this.haveLoadProtoCount++;
    var builder = protobuf.protoFromString(data);
    var proto = builder.build("com.game.proto");
    for (var msgName in proto){
        if(typeof proto[msgName] == "function"){
            if(proto[msgName].$type && proto[msgName].$type._fieldsByName.msgID && proto[msgName].$type._fieldsByName.msgID.defaultValue)
            {
                this.protoMsg[proto[msgName].$type._fieldsByName.msgID.defaultValue] = proto[msgName];
            }
        }
    }
    if(this.haveLoadProtoCount >= protoMsgFile.length && this.initOverBack){
        this.initOverBack();
    }    
};
msgManager.loadProto = function(protoFile,loadBack){
    function loadOver(err,data){
        if (err) {
            cc.error(err.message || err);
            if(loadBack){
                loadBack(false);
            }
            return;
        }
        var builder = protobuf.protoFromString(data);
        var proto = builder.build("com.game.proto");
        for (var msgName in proto){
            if(typeof proto[msgName] == "function"){
                if(proto[msgName].$type && proto[msgName].$type._fieldsByName.msgID && proto[msgName].$type._fieldsByName.msgID.defaultValue)
                {
                    this.protoMsg[proto[msgName].$type._fieldsByName.msgID.defaultValue] = proto[msgName];
                }
            }
        }
        if(loadBack){
            loadBack(true);
        }        
    }
    function bindLoadResBack(callBack,target){
        var bindFunc = function(err,data){
            callBack.call(target,err,data);
        };
        return bindFunc;        
    }
    cc.loader.loadRes(protoFile,bindLoadResBack(loadOver,this));
};
msgManager.setProtoMsg = function(msgID,msgFunc){
    this.protoMsg[msgID] = msgFunc;
};
msgManager.getProtoMsg = function(msgID){
    return this.protoMsg[msgID];
}
msgManager.encodeMsg = function(msgID,msg){
    var msgFunc = this.getProtoMsg(msgID);
    if (msgFunc){
        var msgbuilder = new msgFunc();
        cc.log(msg)
        //mapModelId
        for (var key in msg){
            if (msgbuilder.hasOwnProperty(key)){
                msgbuilder[key] = msg[key];
            }
        }
        cc.log(msgbuilder);
        var headBuf = protobuf.ByteBuffer.allocate(4);
        var dataBuff = msgbuilder.encode();
        headBuf.writeInt16(2+dataBuff.limit);
        headBuf.writeInt16(msgID);
        headBuf.flip();
        var sendBuf = protobuf.ByteBuffer.concat([headBuf,dataBuff]);
        return sendBuf.view.buffer;         
    }
    return null;
}
msgManager.decodeMsg = function(buffer,decodeBack){
    if((buffer instanceof ArrayBuffer) == true)
    {
        console.log("is arrayBuffer");
        var recvByteBuffer = protobuf.ByteBuffer.wrap(buffer);
        var msgTotalLen = recvByteBuffer.readInt16();
        var msgID = recvByteBuffer.readInt16();
        cc.log(msgID);
        var msgFunc = this.getProtoMsg(msgID);
        var recvMsg = null;
        if (msgFunc){
            var msgBuff = recvByteBuffer.readBytes(msgTotalLen-2);
            recvMsg = msgFunc.decode(msgBuff);
        }
        if(decodeBack){
            decodeBack(recvMsg,msgID);
        }                                 
    }
    else if(buffer instanceof Blob){
        var reader = new FileReader();
        function readBack(event){
            var content = reader.result;//内容就在这里
            cc.log(content);
            var recvByteBuffer = protobuf.ByteBuffer.fromBinary(content);
            var msgTotalLen = recvByteBuffer.readInt16();
            var msgID = recvByteBuffer.readInt16();
            cc.log(msgID);
            var msgFunc = this.getProtoMsg(msgID);
            var recvMsg = null;
            if (msgFunc){
                var msgBuff = recvByteBuffer.readBytes(msgTotalLen-2);
                recvMsg = msgFunc.decode(msgBuff);
            }
            if(decodeBack){
                decodeBack(recvMsg,msgID);
            }              
        }
        
        reader.onload = util.handler(readBack,this);
        reader.readAsBinaryString(buffer);
    }    
}
module.exports = msgManager;