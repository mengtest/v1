// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
cc.Class({
    extends: cc.Component,

    properties: {
        // foo: {
        //     // ATTRIBUTES:
        //     default: null,        // The default value will be used only when the component attaching
        //                           // to a node for the first time
        //     type: cc.SpriteFrame, // optional, default is typeof default
        //     serializable: true,   // optional, default is true
        // },
        // bar: {
        //     get () {
        //         return this._bar;
        //     },
        //     set (value) {
        //         this._bar = value;
        //     }
        // },
        chaneNamePanel:{
            default:null,
            type:cc.Node
        },
        chaneHeadPanel:{
            default:null,
            type:cc.Node
        },
        baseinfoPanel:{
            default:null,
            type:cc.Node
        },
        zhuangshiPanel:{
            default:null,
            type:cc.Node
        },
        gamerecordsPanel:{
            default:null,
            type:cc.Node
        },
        changeBtn:{
            default:null,
            type:cc.Node
        },
        Gameinfobtnexit:{
            default:null,
            type:cc.Node
        },
        gameinfoAtla:{
            default:null,
            type:cc.SpriteAtlas
        },
        //对局记录iteam
        recorditeam:{
            default:null,
            type:cc.Prefab
        },
        isSelectheadbg : 1,//是否是切换头像边框选择1是头像2是闹钟

    },

    // LIFE-CYCLE CALLBACKS:

    // onLoad () {},

    start () {
        var listBtn = this.changeBtn.children;
        cc.log(listBtn)
        for(var i in listBtn)
        {
            var selectbtn = this.changeBtn.getChildByName("toggle"+i.toString()).addComponent(cc.Button);  
            util.addClickEvent(selectbtn.node,this.node,"gameinfo","selectbtn");
        }
        this.initbaseinfo();
        //this.showToggle(0);

    },
    //传入index显示需要初始化显示的按钮
    showToggle:function(index)
    {
        var listBtn = this.changeBtn.children;
        for(var i in listBtn)
        {
            if(i == index)
            {
                this.changeBtn.getChildByName("toggle"+i.toString()).getComponent(cc.Toggle).isChecked = true;
                this.updateview(index);
            }
        }
    },
    updateview:function(index)
    {
        //0 基本资料 1装饰道具2对局记录
        switch(index)
        {
            
            case 0:
                this.baseinfoPanel.active = true;
                this.zhuangshiPanel.active = false;
                this.gamerecordsPanel.active = false;
                break;
                case 1:
                        this.baseinfoPanel.active = false;
                        this.zhuangshiPanel.active = true;
                        this.gamerecordsPanel.active = false;
                        break;
                        case 2:
                                this.baseinfoPanel.active = false;
                                this.zhuangshiPanel.active = false;
                                this.gamerecordsPanel.active = true;
                                break;
                
        }
    },
    selectbtn:function(e,obj)
    {
        cc.log(obj);
        switch(obj.name)
        {
            
            case "toggle0":
                this.baseinfoPanel.active = true;
                this.initbaseinfo();
                this.zhuangshiPanel.active = false;
                this.gamerecordsPanel.active = false;
                break;
                case "toggle1":
                        this.baseinfoPanel.active = false;
                        this.zhuangshiPanel.active = true;
                        this.gamerecordsPanel.active = false;
                        this.showdecoratePanel();
                        break;
                        case "toggle2":
                                this.baseinfoPanel.active = false;
                                this.zhuangshiPanel.active = false;
                                this.gamerecordsPanel.active = true;
                                this.showgamerecordsPanel();
                                break;
                
        }
    },
    //初始化个人信息
    initbaseinfo:function()
    {
        var basenode = this.baseinfoPanel.getChildByName("13");
        var baserongyunode = this.baseinfoPanel.getChildByName("24").getChildByName("22");
        basenode.getChildByName("id").getComponent(cc.Label).string = "id:9527"
        basenode.getChildByName("gold").getComponent(cc.Label).string = "98765432"
        basenode.getChildByName("diamond").getComponent(cc.Label).string = "98765432"
        basenode.getChildByName("ad").getComponent(cc.Label).string = "天朝"
        basenode.getChildByName("title").getComponent(cc.Label).string = "无法无天"
        basenode.getChildByName("id").getComponent(cc.Label).string = "id:9527"
        this.baseinfoPanel.getChildByName("namebg").getChildByName("state").getComponent(cc.Sprite).spriteFrame = "";
        this.baseinfoPanel.getChildByName("namebg").getChildByName("name").getComponent(cc.Label).string = "法力无边"
        //荣誉墙信息数据依次显示胜率，最高连胜，总对局数，春天次数，炸弹次数，最高倍数
        baserongyunode.getChildByName("winnum").getChildByName("num").getComponent(cc.Label).string = "1"
        baserongyunode.getChildByName("lianshengNum").getChildByName("num").getComponent(cc.Label).string = "2"
        baserongyunode.getChildByName("allNum").getChildByName("num").getComponent(cc.Label).string = "3"
        baserongyunode.getChildByName("chuntianNum").getChildByName("num").getComponent(cc.Label).string = "4"
        baserongyunode.getChildByName("zhadanNum").getChildByName("num").getComponent(cc.Label).string = "5"
        baserongyunode.getChildByName("zuigaoNum").getChildByName("num").getComponent(cc.Label).string = "6"
    },
    closegameinfo:function()
    {
        //退出后刷新大厅
        var str= this.node.parent.getChildByName("Canvas").getChildByName("Lobby_Panel").getComponent("lobby").updateGameInfo();
        this.node.destroy(); 
    },
    gochaneNamePanel:function()
    {
        this.chaneNamePanel.active = true;
        var changenameBtnok = this.chaneNamePanel.getChildByName("29");
        util.addClickEvent(changenameBtnok.addComponent(cc.Button).node,this.node,"gameinfo","changenameBack")
    },
    changenameBack:function()
    {
        this.closechaneNamePanel();
    },
    gochaneHeadPanel:function()
    {
        this.chaneHeadPanel.active = true;
        var chanheadbtn = this.chaneHeadPanel.getChildByName("29");
        util.addClickEvent(chanheadbtn.addComponent(cc.Button).node,this.node,"gameinfo","chanheadback")
    },
    chanheadback:function()
    {
        this.closechaneHeadPanel();
    },
    closechaneNamePanel:function()
    {
        //刷新名字和性别
        //this.chaneNamePanel.getChildByName("New EditBox").getComponent(cc.EditBox).string = "9588";
        this.baseinfoPanel.getChildByName("namebg").getChildByName("name").getComponent(cc.Label).string = 
        this.chaneNamePanel.getChildByName("New EditBox").getComponent(cc.EditBox).string;
        this.chaneNamePanel.getChildByName("New ToggleContainer").getComponent(cc.ToggleContainer)
        var tog = this.chaneNamePanel.getChildByName("New ToggleContainer").children;
        cc.log(this.chaneNamePanel.getChildByName("New ToggleContainer").getComponent(cc.ToggleContainer));
        for(var i  in tog)
        {
            if(tog[i].getComponent(cc.Toggle).isChecked)
            {
                if(tog[i].name=="toggle0")
                {
                    //17 男 16 女
                    this.baseinfoPanel.getChildByName("namebg").getChildByName("state").getComponent(cc.Sprite).spriteFrame = 
                    this.gameinfoAtla.getSpriteFrame("17");
                }
                else
                {
                    this.baseinfoPanel.getChildByName("namebg").getChildByName("state").getComponent(cc.Sprite).spriteFrame = 
                    this.gameinfoAtla.getSpriteFrame("16");
                }
            }
            
        }
        this.chaneNamePanel.active = false;

    },
    closechaneHeadPanel:function()
    {
        //刷新头像
        var headList = this.chaneHeadPanel.getChildByName("New ToggleContainer").children;
        for(var i in headList)
        {
            if(headList[i].getComponent(cc.Toggle).isChecked)
            {
                cc.log("当前选中头像"+headList[i].name);
                var newhead = headList[i].getChildByName("Background").getComponent(cc.Sprite).spriteFrame.name;
                cc.log("newhead--------->"+newhead);
                this.baseinfoPanel.getChildByName("13").getChildByName("headicon").getComponent(cc.Sprite).spriteFrame =
                this.gameinfoAtla.getSpriteFrame(newhead);
            }
        }
        this.chaneHeadPanel.active = false;
    },
    //显示对局详情
    showgamerecordsPanel:function()
    {
        var iteamNode = this.gamerecordsPanel.getChildByName("13").getChildByName("ScrollView").getChildByName("view").getChildByName("grid");
        iteamNode.removeAllChildren(true);
        for(var i =0;i<4;i++)
        {
            var iteam = cc.instantiate(this.recorditeam);
            iteam.getChildByName("state").getComponent(cc.Sprite).spriteFrame = this.gameinfoAtla.getSpriteFrame("44");//43胜利44失败
            iteam.getChildByName("goldNum").getComponent(cc.Label).string = "988"
            iteam.getChildByName("type1").getComponent(cc.Label).string = "金典999"
            //iteam.getChildByName("time").getComponent(cc.Label).string = "2019/7/22"
            iteamNode.addChild(iteam);
        }
    },
    //装饰面板根据按钮切换显示对应数据
    changedecoratePanel:function(e,obj)
    {
        var headbgIteamList = this.zhuangshiPanel.getChildByName("headPanel").getChildByName("37").getChildByName("New ToggleContainer").children;
        cc.log(obj.name)
        switch(obj.name)
        {
            //14 头像边框 39 是闹钟样式
            case "toggle0":
                this.isSelectheadbg = 1;
                for(var i in headbgIteamList)
                {
                    headbgIteamList[i].addComponent(cc.Button);
                    headbgIteamList[i].getChildByName("Background").getComponent(cc.Sprite).spriteFrame = 
                    this.gameinfoAtla.getSpriteFrame("14");
                    util.addClickEvent(headbgIteamList[i].addComponent(cc.Button).node,this.node,"gameinfo","selectheadBg")
                    if(headbgIteamList[i].getComponent(cc.Toggle).isChecked)
                    {
                        cc.log(headbgIteamList[i].name);
                    }
                }
                break;
            case "toggle1":
                this.isSelectheadbg = 2;
                for(var i in headbgIteamList)
                {
                    headbgIteamList[i].addComponent(cc.Button);
                    headbgIteamList[i].getChildByName("Background").getComponent(cc.Sprite).spriteFrame = 
                    this.gameinfoAtla.getSpriteFrame("39");
                    util.addClickEvent(headbgIteamList[i].addComponent(cc.Button).node,this.node,"gameinfo","selectheadBg")
                    if(headbgIteamList[i].getComponent(cc.Toggle).isChecked)
                    {
                        cc.log(headbgIteamList[i].name);
                    }
                }
                break;
        }

    },
    //监听头像边框
    onheadbgClick:function()
    {
        var headbgIteamList = this.zhuangshiPanel.getChildByName("headPanel").getChildByName("37").getChildByName("New ToggleContainer").children;
                for(var i in headbgIteamList)
                {
                    util.addClickEvent(headbgIteamList[i].addComponent(cc.Button).node,this.node,"gameinfo","selectheadBg")
                    if(headbgIteamList[i].getComponent(cc.Toggle).isChecked)
                    {
                        cc.log(headbgIteamList[i].name);
                    }
                }
        var okbtn = this.zhuangshiPanel.getChildByName("headPanel").getChildByName("38").getChildByName("29");
        util.addClickEvent(okbtn.addComponent(cc.Button).node,this.node,"gameinfo","selectheadBg")
    },
    //处理选中头像
    selectheadBg:function(e,obj)
    {
        cc.log(obj.name)
        var newheadbg;
        if(obj.name != "29")
        {
            cc.log(obj.getChildByName("Background").getComponent(cc.Sprite).spriteFrame.name);
            var selectbg = this.zhuangshiPanel.getChildByName("headPanel").getChildByName("38").getChildByName("14");
            newheadbg = obj.getChildByName("Background").getComponent(cc.Sprite).spriteFrame.name
            selectbg.getComponent(cc.Sprite).spriteFrame = 
            this.gameinfoAtla.getSpriteFrame(newheadbg);
            cc.log(newheadbg)

        }
        else
        {
            var headbgIteamList = this.zhuangshiPanel.getChildByName("headPanel").getChildByName("37").getChildByName("New ToggleContainer").children;
            for(var i in headbgIteamList)
            {
                if(headbgIteamList[i].getComponent(cc.Toggle).isChecked)
                {
                    //获取到当前选中的头像框名称
                    newheadbg =  headbgIteamList[i].getChildByName("Background").getComponent(cc.Sprite).spriteFrame.name;
                    cc.log(this.isSelectheadbg)//判断保存那种类型数据1头像边框2闹钟样式
                    switch(this.isSelectheadbg)
                    {
                        case 1:
                            cc.log("头像边框")
                            break
                        case 2:
                            cc.log("闹钟样式")
                            break
                    }
                    cc.log(newheadbg);
                }
            }
        }
    },
    //显示装饰道具
    showdecoratePanel:function()
    {
        var listbtn = this.zhuangshiPanel.getChildByName("31").getChildByName("New ToggleContainer").children;
        for(var i in listbtn)
        {
            //0：头像边框 1：闹钟边框
            cc.log(listbtn[i].getComponent(cc.Toggle).isChecked);
            var selectbtn = listbtn[i].addComponent(cc.Button);  
            util.addClickEvent(selectbtn.node,this.node,"gameinfo","changedecoratePanel");
        }
        this.onheadbgClick();
    }
   
    // update (dt) {},
});
