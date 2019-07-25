'use strict';

const fs = require('fs');
const path = require('path');
const async = require('async');
const rd = require('rd');
const shell = require('shelljs');
const child_process = require('child_process');
      
function copy(src, dist) {
    Editor.log(`copy file ${src} > ${dist}`);
    let extname = path.extname(dist);
    let distFile = extname ? dist : path.join(dist, path.basename(src));
    //Editor.log('创建目录：',path.dirname(distFile));
    shell.mkdir('-p', path.dirname(distFile));
    shell.cp(src, dist);
}

module.exports = {
    _pluginRoot: null,
    _assetsRoot: null,
    load () {
        Editor.log('pbkiller on load');
    },

    /**
     * 复制源码到assets/pbkiller
     * @param {Function} cb 
     */
    copyScript(isLite) {
        //读取runtime-scripts下所有文件，复制到assets/lib/pbkiller下
        let scriptRoot = path.join(this._pluginRoot, 'runtime-scripts');
        let scriptFiles = rd.readFileSync(scriptRoot).sort((a, b) => {
            return b.length - a.length;
        });

        if (isLite) {
            scriptFiles = scriptFiles.filter((str) => {
                return str.indexOf('protobuf') === -1;
            });
        }

        //Editor.log(scriptFiles);
        let array = scriptFiles.map((src) => {
            let fileName = src.substr(scriptRoot.length);
            Editor.log(`---->${fileName}`);
            let dist = path.join(this._assetsRoot, 'pbkiller', fileName);
            return { src, dist, fileName };    
        });
        this.copyToAssets(array);
    },

    /**
     * 复制proto文件到assets/resources/pb
     */
    copyProto() {
        let pbRoot = path.join(this._pluginRoot, 'pb');
        let pbFiles = rd.readFileFilterSync(pbRoot, /\.proto|\.json|\.bin$/);
        let array = pbFiles.map((src) => {
            let fileName = src.substr(pbRoot.length);
            let dist = path.join(this._assetsRoot, 'resources', 'pb', fileName);
            return { src, dist, fileName };    
        });
        this.copyToAssets(array);
    },

    copyToAssets(array) {
        array.forEach((item) => {
            if (fs.existsSync(item.dist)) {
                Editor.log(`文件已经存在，${item.dist}`);
                return;
            }
            copy(item.src, item.dist);
        });
    },

    install(isLite) {
        if (isLite) {
            if (!this.checkProtobufjsNpm()) {
                return;         
            }
        }

        this._pluginRoot = Editor.url('packages://pbkiller');
        this._assetsRoot = Editor.url('db://assets');
        this.copyScript(isLite),
        this.copyProto(),
        setTimeout(() => {
            Editor.assetdb.refresh('db://assets', () => {
                Editor.success('pbkiller install success');        
            });
        }, 1);
        
    },

    checkProtobufjsNpm() {
        let protobufjsPath = path.join(Editor.projectPath, 'node_modules', 'protobufjs');
        if (!fs.existsSync(protobufjsPath)) {
            Editor.log('检测到没有protobufjs npm模块\n1.请先在项目根目录输入：npm install protobufjs@5 --save\n2.或者选择使用源码安装');
            return false;
        }

        return true;
    },

    unload () {
    // execute when package unloaded
    },

  // register your ipc messages here
    messages: {
        'pbjs' () {
            Editor.log('pbjs open----->');
            Editor.Panel.open('pbkiller');
        },

        'install-src'() {
            this.install();
        },

        'install-lite'() {
            this.install(true);
        },
    }
};