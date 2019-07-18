/*
 * @Author: Michael Zhang
 * @Date: 2019-07-15 11:57:37
 * @LastEditTime: 2019-07-15 12:02:33
 */

let ShaderMaterial = require('./shaderMaterial')

var util = {};
util.useShader = function (sprite, lab) {
    if (cc.game.renderType === cc.game.RENDER_TYPE_CANVAS) {
        console.warn('Shader not surpport for canvas');
        return;
    }
    if (!sprite || !sprite.spriteFrame || sprite.lab == lab) {
        return;
    }
    if (lab) {
        if (lab.vert == null || lab.frag == null) {
            console.warn('Shader not defined', lab);
            return;
        }
        cc.dynamicAtlasManager.enabled = false;
 
        let material = new ShaderMaterial();
        let name = lab.name ? lab.name : "None"
        material.callfunc(name, lab.vert, lab.frag, lab.defines || []);
 
        let texture = sprite.spriteFrame.getTexture();
        material.setTexture(texture);
        material.updateHash();
 
        sprite._material = material;
        sprite._renderData.material = material;
        sprite.lab = lab;
        return material;
    } else {
        // 这个就是直接变成灰色
        sprite.setState(1);
    }
};
cc.Class({
    extends: cc.Component,
 
    properties: {
      
    },
 
    onLoad: function () {
        this._time = 0;
        this._sin = 0;
 
        // this._program = ShaderUtils.setShader(this.sp, "galaxy");
    },
    start: function () {
        var name = "saoguang";
        var vert = require(cc.js.formatStr("%s.vert", name));
        var frag = require(cc.js.formatStr("%s.frag", name));
        var lab = {
            vert: vert,
            frag: frag,
            name: "galaxy"
        }
        let sprite = this.node.getComponent(cc.Sprite);
        let spriteFrame = sprite.spriteFrame;
        if (spriteFrame.textureLoaded()) {
            this._merial = this.changeMaterial(sprite, lab);
        }
    },
    changeMaterial: function (sprite, lab) {
        let material = util.useShader(sprite, lab);
        return material;
    },
 
    update(dt) {
        this._time += 2 * dt;
        // this._program.use();
        this._sin = Math.sin(this._time);
        if (this._sin > 0.99) {
            this._sin = 0;
            this._time = 0;
        }
        this._merial.setSysTime(this._sin)
    },
});