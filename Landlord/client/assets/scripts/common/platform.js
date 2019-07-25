// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html

var platform = {}

platform.getImei = function () {
   var imei="";
   if (cc.sys.platform == cc.sys.OS_IOS) {
      imei = jsb.reflection.callStaticMethod("SimulateIDFA", "getIDFA");
      return imei;
   }
   else if (cc.sys.platform == cc.sys.OS_ANDROID) {
      imei = jsb.reflection.callStaticMethod("org/cocos2dx/javascript/AppActivity", "getImei", "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;", "title", "message");
      return imei;
   } else {
      imei = "";
      return imei;
   }

}

module.exports = platform;