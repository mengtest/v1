/**
 * zxh
 * 2016-11-29 15:55
 * proto.js生成器
 */
var rd = require('rd');
var path = require('path');
var fs = require('fs');
var async = require('async');
var util = require('util');
var shell = require('shelljs');
const electron = require('electron')

var template = `
/*eslint-disable global-require*/
var proto = null;
module.exports = (() => {
    if (proto) {
        return proto;    
    }    
    proto = {};
%s
    return proto;
})();

`;

var line = `    proto.%s = require('%s').%s;`;


function Generator(srcProto, destJs, loaderFile) {
    this.srcProto = srcProto;
    this.destJs = destJs;
    this.loaderFile = loaderFile;
}

Generator.prototype = {
    /**
     * 使用protobufjs命令行工具pbjs将proto文件转换为js文件
     */
    pbjs(cb) {
        var src = this.srcProto;
        var dest = this.destJs;
        var files = [];
        var basename = path.basename(src);

        //shell.rm('-rf', dest);    
        var start = src.length;
        rd.eachFileFilterSync(src, /\.proto$/, (protofile) => {
            //var start = protofile.indexOf(basename) + basename.length + 1;
            var end = protofile.indexOf(path.extname(protofile));

            var outfile = `${path.join(dest, protofile.substring(start, end))}.js`;    
            files.push({ protofile, outfile });
        }, (err, list) => {
            console.log(list);
        });
        
        let pluginRoot = Editor.url('packages://pbkiller');
        let cmdPath = path.join(pluginRoot, 'node_modules', 'protobufjs/bin/pbjs');

        var child_process = require('child_process');
        async.eachLimit(files, 4, (item, callback) => {
            var dir = path.dirname(item.outfile);
            //shell.mkdir('-p', dir);
            var cmd = `${cmdPath} -t commonjs ${item.protofile} -o ${item.outfile}`
            var cp = child_process.exec(cmd, {env: process.env},(error, stdout, stderr) => {
                if (error) {
                    Editor.log('stderr', stderr);
                    callback();
                    return;
                }
            });

            cp.on('data', (data) => {
                Editor.log(data.trim());
            });

            cp.on('exit', () => {
                callback();
            });
        }, () => {
            console.log('pbjs转换完成, 数量:', files.length);
            if (cb) {
                cb();
            }
        });
    },

    /**
     * 生成加载文件
     */
    generatorLoaderFile(){
        var src = this.destJs;
        var dest = this.loaderFile;
        var files = [];
        var basename = path.basename(src);

        rd.eachFileFilterSync(src, /\.js$/, (f) => {
            var start = f.indexOf(basename);
            var name = path.basename(f, '.js');
            var filepath = './' + f.substring(start);
            var str = util.format(line, name, filepath, name);
            str = str.replace(/\\/g, '/');    
            files.push(str);
        });
        var codestr = files.join('\n');
        codestr = util.format(template, codestr);
        fs.writeFileSync(dest, codestr, 'utf8');
        console.log('生成加载文件:', dest);
    },

    run(cb) {
        this.pbjs(cb);
    },
};

module.exports = Generator;
// var srcProto =  process.argv[2];
// var destJs =  process.argv[3];
// var loaderFile = process.argv[4];

// var generator = new Generator(srcProto, destJs, loaderFile);
// generator.run();