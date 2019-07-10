/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 16:08:36
 * @LastEditTime: 2019-07-10 11:06:47
 */

let CommonData = require('../dataModel/commonData')

let AudioManager = cc.Class({
    
    properties : {

        bgm : "",

        isPlayedBGM : false, // 当前有没有播放过音乐
    },

    statics :{

        instance: null,
         
        getInstance () {
            if(this.instance == null) {
                this.instance = new AudioManager();
            }
            return this.instance;
        },
    },

    playSound(soundName, loop, volume, callback){
       
        let path = CommonData.AUDIO_DIR + soundName;
        cc.loader.loadRes(path, cc.AudioClip, function (err, clip) {
            if(err)
            {
                cc.error(err);
                return;
            }
            var audioID = cc.audioEngine.play(clip, loop?loop:false, volume?volume:1);
            if( callback )
                cc.audioEngine.setFinishCallback(audioID, callback);

		});
    },

    stopAll()
    {
        cc.audioEngine.stopAll();
    },

    pauseAll()
    {
        cc.audioEngine.pauseAll();
    },

    resumeAll()
    {
        cc.audioEngine.resumeAll();
    },

    playBGM(soundName)
    {
        if(this.bgm == soundName)
        {
            return;
        }
        this.bgm = soundName;
       
        cc.audioEngine.stopMusic();
        let path = CommonData.AUDIO_DIR + soundName;
    
        cc.loader.loadRes(path, cc.AudioClip, function (err, clip) {
            if(err)
            {
                cc.error(err);
                return;
            }
            this.isPlayedBGM = true;
		    cc.audioEngine.playMusic(clip, true);
		});
    } ,
    
    resumeBGM() {

        if( this.isPlayedBGM ) {
            
            cc.audioEngine.resumeMusic();
        
        } else {
            
            let path = CommonData.AUDIO_DIR + this.bgm;
        
            cc.loader.loadRes(path, cc.AudioClip, function (err, clip) {
                if(err)
                {
                    cc.error(err);
                    return;
                }
                this.isPlayedBGM = true;
                cc.audioEngine.playMusic(clip, true);
            });
        }

     
    },

    pauseBGM (){
        cc.audioEngine.pauseMusic();
    },

    
})