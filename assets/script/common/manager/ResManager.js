/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 16:08:52
 * @LastEditTime: 2019-07-12 10:13:22
 */
let ResManager = cc.Class({

    statics: {

        instance: null,

        getInstance () {

            if( ! this.instance ) {

                this.instance = new ResManager();

            }
            
            return this.instance;
        }
    },

    properties: {

    },

    ctor ( ) {
        
    },

    /**
     * 资源记载器
     * @param {*} resPath 资源路径
     * @param {*} callback 加载回调
     * @param {*} assetType 资源类型
     */
    loadRes ( resPath, callback, assetType ) {

        if( assetType ) {
            cc.loader.loadRes( resPath, assetType , (err, assets )=>{
                if( err ) { 
                    cc.error(err)
                } else {
                   callback( assets )
                }
            });
        } else {
            cc.loader.loadRes( resPath, (err, assets )=>{
                if( err ) {
                    cc.error(err)
                } else {
                   callback( assets )
                }
            });
        }
    },

    /**
     * 资源加载器
     * @param {*} resPath 文件夹路径
     * @param {*} callback 加载回调
     * @param {*} assetType 资源类型
     */
    loadResDir ( resPath, callback, assetType ) {

        if( assetType ) {

            cc.loader.loadResDir( resPath, assetType, (err, assets)=>{
                if( err ){
                    cc.error(err)
                }else{
                    callback(assets)
                }
            })

        } else {
            
            cc.loader.loadResDir( resPath, (err, assets, urls )=>{
                if( err ){
                    cc.error(err)
                } else {
                    callback(assets, urls)
                }
            } )
        }
        
    },


    /**
     * 加载Json
     * @param {*} resPath 资源路径 
     * @param {*} callback 加载成功回调
     */
    loadJson ( resPath, callback ) {
        
        this.loadRes( resPath, ( jsonAssets )=>{
            callback( jsonAssets.json )
        });
    },

    /**
     * 加载文本
     * @param {} resPath 资源路径
     * @param {*} callback 加载成功回调
     */
    loadText ( resPath, callback ) {
        
        this.loadRes( resPath, (textAssets )=>{
            callback(  textAssets.text )
        });
    },

    /**
     * 加载图片
     * @param {*} resPath 资源路径
     * @param {*} callback 加载成功回调
     */
    loadSpriteFrame ( resPath, callback ) {

        this.loadRes( resPath, ( spriteFrame)=>{
            callback( spriteFrame );
        }, cc.SpriteFrame)

    },

    /**
     * 加载音频
     * @param {*} resPath 资源路径
     * @param {*} callback 加载成功回调
     */
    loadAudioClip ( resPath, callback ) {

        this.loadRes( resPath, ( audioClip)=>{
            callback( audioClip );
        }, cc.AudioClip)

    },

    /**
     * 从图集中加载图片资源
     * @param {*} resPath 图集资源路径
     * @param {*} spriteName 图片资源名称
     * @param {*} callback 资源加载回调
     */
    loadSpriteFrameFromAtlas ( resPath, spriteName , callback ) {

        this.loadRes( resPath, ( altas )=>{
            callback( altas.getSpriteFrame(spriteName) );
        }, cc.SpriteAtlas );

    },


    /**
     * 资源释放
     * @param {*} resPath 释放资源路径 
     * @param {*} assetType 释放资源类型
     */
    releaseRes ( resPath, assetType ) {

        if( assetType ) {
            cc.loader.releaseRes( resPath, assetType );
        } else {
            cc.loader.releaseRes( resPath );
        }
    },

    /**
     * 资源实例释放
     * @param {*} asset 待释放实例
     */
    releaseAsset ( asset ) {
        cc.loader.releaseAsset( asset );
    },

    /**
     * 记载远程资源
     * @param {*} url 资源地址 
     * @param {*} callback 加载回调
     */
    loadRemoteUrl ( url, callback, assetType ) {
        
        if( assetType ) {

            cc.loader.load( { url:url , type: assetType }, ( err, texture )=>{

                if( err ){
                    cc.error( err )
                } else {
                    callback( texture );
                }
            } )

        } else {
            
            cc.loader.load( url, ( err, texture )=>{
                if( err ){
                    cc.error( err )
                } else {
                    callback( texture );
                }
            } )
        }
        
    },










    /**
     * 加载场景
     * @param sceneName 场景名
     * @param callback 成功回调
     */
    loadScene ( sceneName, callback ) {

        cc.director.preloadScene( sceneName, ( completedCount, totalCount, item )=>{
        }, ( err, sceneAssets )=>{
            cc.director.loadScene( sceneName, ( )=>{})
        })
    },

});

module.exports = ResManager;