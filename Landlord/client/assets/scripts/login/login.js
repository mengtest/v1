/*
 * @Author: Michael Zhang
 * @Date: 2019-07-02 15:58:37
 * @LastEditTime: 2019-07-24 10:59:32
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
require("../common/commonInclude")
cc.Class({
    extends: cc.Component,

    properties: {
        loginNode: {
            default: null,
            type: cc.Node,
        },
        registerPanel: {
            default: null,
            type: cc.Node,
        },
        loginPanel: {
            default: null,
            type: cc.Node,
        },
        findPanel: {
            default: null,
            type: cc.Node,
        },
        msg: "",
        phonnum: "",
        pwdnnum: "",
        loginType: 0,//登录类型0是游客1手机2微信
        isremember: true,
        //register

    },

    // LIFE-CYCLE CALLBACKS:
    addEvents() {
        eventManager.addEvent("NET_" + msgNameDefine.verify + "_EVENT", util.handler(this.recvVerifyMsg, this), "login1");
        eventManager.addEvent("NET_" + msgNameDefine.login + "_EVENT", util.handler(this.recvLoginMsg, this), "login2");
        eventManager.addEvent("NET_" + msgNameDefine.auth + "_EVENT", util.handler(this.recvPlayerMsg, this), "login3");
        eventManager.addEvent("NET_" + msgNameDefine.loginGame + "_EVENT", util.handler(this.recvLoginGameMsg, this), "login4");
    },
    recvLoginMsg(msg) {
        cc.log(msg);
        if (msg.e == 0) {
            if (this.isremember) {
                cc.sys.localStorage.setItem("acount", this.phonnum);
                cc.sys.localStorage.setItem("paswword", this.pwdnnum);
            }
            this.loginToGame(msg.servers.ip, msg.servers.port, msg.uid, msg.token, msg.auth);
        } else {
            console.log("账号或密码错误...");
        }
    },
    recvVerifyMsg(msg) {
        cc.log(msg);
        cc.log(this.loginType)
        switch (this.loginType) {
            case 0:
                var imei = platform.getImei();
                netManager.sendMsg(msgNameDefine.login, { "token": msg.token, "imei": imei });
                break
            case 1:
                netManager.sendMsg(msgNameDefine.login, { "token": msg.token,"imei":"1", "username": this.phonnum, "password": this.pwdnnum });
                break
        }
    },
    recvPlayerMsg(msg) {
        cc.log(msg);
        if (msg.e == 0) {
            netManager.sendMsg(msgNameDefine.loginGame, { "rid": msg.roles[0].rid });
        }
    },
    recvLoginGameMsg(msg) {
        if (msg.e == 0) {
            globalControl.changeToLobby();
        }
    },
    start() {
        this.loginNode.active = false;
        globalControl.init(util.handler(this.initOver, this));
        this.addEvents();
    },
    initOver() {
        cc.log("initOver");
        this.loginNode.active = true;
    },
    connectServer() {
        function connectServerBack(state) {
            this.loginNode.active = !state;
        }
        netManager.connect('192.168.1.77', 4223, util.handler(connectServerBack, this));
    },
    loginToServer() {
        this.connectServer();
    },
    loginToGame(ip, port, uid, token, auth) {
        this.connectGame(ip, port, uid, token, auth);
    },
    connectGame(ip, port, uid, token, auth) {
        function connectServerBack(state) {
            cc.log("connectGame:" + state);
            if (state) {
                var ti = Date.now();
                var md5 = require("md5");
                var newToken = md5(token + ti);
                cc.log("newToken")
                cc.log(newToken);
                netManager.sendMsg(msgNameDefine.auth, { "uid": uid, "token": newToken, "ti": "" + ti, "auth": auth });
            }
        }
        netManager.connect(ip, port, util.handler(connectServerBack, this));
    },
    onEnterBtnClick(event, data) {
        let sceneName = "lobby";
        switch (data) {
            case "tourist":
                //test
                this.loginType = 0;
                this.loginToServer();
                break;

            case "phone":
                this.onphoneBtn();
                break;

            case "wechat":

                break;

            default:
                break;
        }

    },
    onBtnClicked() {
        audioManager.playAudio("common/audio/click")
    },
    //登录Panel
    onphoneBtn() {
        var aco = cc.sys.localStorage.getItem("acount");
        var pas = cc.sys.localStorage.getItem("paswword");
        console.log("账号..." + aco + "---密码..." + pas);
        if (aco == null || pas == null) {
            this.loginPanel.active = true;
            var loginBtn = this.loginPanel.getChildByName("bg").getChildByName("loginBtn")
            util.addClickEvent(loginBtn.addComponent(cc.Button).node, this.node, "login", "goPhoneLogin")
        } else {
            this.pwdnnum = pas
            this.phonnum = aco
            this.loginType = 1;
            this.connectServer();
        }

    },
    goPhoneLogin: function () {
        var phonnum = this.loginPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string
        var pwdnnum = this.loginPanel.getChildByName("bg").getChildByName("pwd").getChildByName("pwdEditBox").getComponent(cc.EditBox).string
        if (phonnum == "" || pwdnnum == "") {
            console.log("请输入账号或者密码...");
            return;
        }
        this.pwdnnum = pwdnnum
        this.phonnum = phonnum
        this.loginType = 1;
        this.connectServer();
    },
    //注册Panel
    showregisterPanel() {
        this.registerPanel.active = true;
        this.registerPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string="";
        this.registerPanel.getChildByName("bg").getChildByName("pwd").getChildByName("pwdEditBox").getComponent(cc.EditBox).string="";
        this.registerPanel.getChildByName("bg").getChildByName("check").getChildByName("checkEditBox").getComponent(cc.EditBox).string="";
        
    },
    getregisterCode() {
        var acount = this.registerPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string;
        if (acount == "") {
            console.log("请输入手机号...");
            return;
        }
        //SEND
    },
    registerok() {
        var acount = this.registerPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string;
        var paswoord = this.registerPanel.getChildByName("bg").getChildByName("pwd").getChildByName("pwdEditBox").getComponent(cc.EditBox).string;
        var code = this.registerPanel.getChildByName("bg").getChildByName("check").getChildByName("checkEditBox").getComponent(cc.EditBox).string;
        if (acount == "" || paswoord == "" || code == "") {
            console.log("请输入完整信息...");
            return;
        }
        //SEND
    },
    //忘记密码Panel
    showfindPanel() {
        this.findPanel.active = true;
        this.findPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string="";
        this.findPanel.getChildByName("bg").getChildByName("pwd").getChildByName("pwdEditBox").getComponent(cc.EditBox).string="";
        this.findPanel.getChildByName("bg").getChildByName("check").getChildByName("checkEditBox").getComponent(cc.EditBox).string="";
       
    },
    getfindCode() {
        var acount = this.findPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string;
        if (acount == "") {
            console.log("请输入手机号...");
            return;
        }
        //SEND
    },
    findok() {
        var acount = this.findPanel.getChildByName("bg").getChildByName("tel").getChildByName("telEditBox").getComponent(cc.EditBox).string;
        var paswoord = this.findPanel.getChildByName("bg").getChildByName("pwd").getChildByName("pwdEditBox").getComponent(cc.EditBox).string;
        var code = this.findPanel.getChildByName("bg").getChildByName("check").getChildByName("checkEditBox").getComponent(cc.EditBox).string;
        if (acount == "" || paswoord == "" || code == "") {
            console.log("请输入完整信息...");
            return;
        }
        //SEND
    },
    //隐藏Panel
    closeView: function (e, obj) {
        cc.log(obj);
        switch (obj) {
            case "loginPanel":
                this.loginPanel.active = false;
                break;
            case "register":
                this.registerPanel.active = false;
                break;
            case "find":
                this.findPanel.active = false;
                break;
        }
    },
    selecRemem() {
        this.isremember = !this.isremember;
    },
    // update (dt) {},
    onDestroy() {
        this.removeEvents();
    },
    removeEvents() {
        eventManager.removeEvent("NET_" + msgNameDefine.verify + "_EVENT", "login1");
        eventManager.removeEvent("NET_" + msgNameDefine.login + "_EVENT", "login2");
        eventManager.removeEvent("NET_" + msgNameDefine.auth + "_EVENT", "login3");
        eventManager.removeEvent("NET_" + msgNameDefine.loginGame + "_EVENT", "login4");
    }
});
