// Learn cc.Class:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/class.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/class.html
// Learn Attribute:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/reference/attributes.html
//  - [English] http://docs.cocos2d-x.org/creator/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - [Chinese] https://docs.cocos.com/creator/manual/zh/scripting/life-cycle-callbacks.html
//  - [English] https://www.cocos2d-x.org/docs/creator/manual/en/scripting/life-cycle-callbacks.html
var audioManager = {};
audioManager.init = function(){
    var soundVolume = cc.sys.localStorage.getItem("soundVolume");
    if(soundVolume == null){
        soundVolume = 1;
    }
    var musicVolume = cc.sys.localStorage.getItem("musicVolume");
    if(musicVolume == null){
        musicVolume = 1;
    }
    this.setSoundVolume(soundVolume);
    this.setMusicVolume(musicVolume);
}
audioManager.playAudio = function(url,isLoop,volume){
    if(isLoop == null){
        isLoop = false;
    }
    if(volume == null){
        var volume = cc.sys.localStorage.getItem("soundVolume");
        if(volume == null){
            volume = 1;
        }
    }
    cc.loader.loadRes(url, cc.AudioClip, function (err, clip) {
        if (err) {
            cc.error(err.message || err);
            return;
        }        
        cc.audioEngine.play(clip,isLoop,volume);
    });
}
audioManager.playMusic = function(url,isLoop){
    if(isLoop == null){
        isLoop = false;
    }
    cc.loader.loadRes(url, cc.AudioClip, function (err, clip) {
        if (err) {
            cc.error(err.message || err);
            return;
        }        
        cc.audioEngine.playMusic(clip,isLoop);
    });    
}
audioManager.stopMusic = function(){
    cc.audioEngine.stopMusic(clip,isLoop);
}
audioManager.setSoundVolume = function(volume){
    //cc.audioEngine.setVolume(volume);
}
audioManager.setMusicVolume = function(volume){
    cc.audioEngine.setMusicVolume(volume);
}
module.exports = audioManager;
