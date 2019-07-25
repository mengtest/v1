let pbkiller = require('../src/pbkiller');

cc.Class({
    extends: cc.Component,

    properties: {
        textLabel: cc.Label
    },

    // use this for initialization
    onLoad: function () {
        //this.loadProto();
    },

    log(msg) {
        cc.log(msg);
        this.textLabel.string += `${msg}\n`;
    },

    /**
     * 如果要在微信小游戏环境执行，需要先执行pbkiller.preload函数
     */
    loadProto() {
        //loadAll自动加载resources/pb下所有proto
        let pb = pbkiller.loadAll();
        this.log(JSON.stringify(pb.grace.proto.msg, null, 4));

        //loadAll自动加载resources/pb下所有proto
        pb = pbkiller.loadAll('proto', 'grace.proto.msg');
        this.log(JSON.stringify(new pb.Player(), null, 4));

        //loadFromFile加载指定文件
        pb = pbkiller.loadFromFile('Player.proto', 'grace.proto.msg');
        this.log(JSON.stringify(new pb.Player(), null, 4));

        //loadFromFile加载resources/pb下指定文件
        pb = pbkiller.loadFromFile(['Player.proto', 'ActionCode.proto'], 'grace.proto.msg');
        this.log(JSON.stringify(new pb.PBMessage(), null, 4));

        //loadFromFile加载resources/pb下指定文件
        pb = pbkiller.loadFromFile(['Player2.json', 'ActionCode.proto'], 'grace.proto.msg');
        this.log(JSON.stringify(new pb.Player(), null, 4));
    },

    decode() {
        let pb = pbkiller.loadFromFile('Player2.json', 'grace.proto.msg');
        let player = new pb.Player();
        player.id = 1000;
        player.name = 'ShawnZhang';
        player.enterTime = Date.now();
        this.log('-----decode-----');
        this.log(`序列化前：${JSON.stringify(player, null, 4)}`);

        let data = player.toArrayBuffer();
        let player2 = pb.Player.decode(data);
        this.log(`反序列化后：${JSON.stringify(player2, null, 4)}`);
        this.log(`int64类型的读取：${player2.enterTime}`);
    },

    /**
     * 加载二进制proto数据文件
     */
    decodeFile() {
        if (cc.sys.platform === cc.sys.WECHAT_GAME) {
            this.log('decode二进制文件不能在微信小游戏环境执行');
            return;
        }
        let pb = pbkiller.loadFromFile('puzzle_config.proto', 'WePuzzle');
        pbkiller.loadData(cc.url.raw('resources/pb/bin/testPuzzle.bin'), (data) => {
            let obj = pb.PuzzleConfig.decode(data);
            this.log(JSON.stringify(obj));       
        });
    },

    /**
     * 使用pbkiller.preload方法预加载所有resources/pb目录下的proto文件
     * 之后用法与之前相同
     */
    asyncLoad() {
        pbkiller.preload(() => {
            this.loadProto();
        });
    }
});
