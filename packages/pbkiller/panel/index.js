// panel/index.js, this filename needs to match the one registered in package.json
let fs = require('fire-fs');
let path = require('fire-path');
let Generator = Editor.require('packages://pbkiller/tools/protojsGenerator');

const PBKILLER_SETTING_FILE = path.join(Editor.projectInfo.path, 'settings', 'pbkiller.json');

Editor.Panel.extend({
  // css style for panel
  style: `
    :host { margin: 5px; }
    h2 { color: #f90; }
  `,

  // html template for panel
  template: fs.readFileSync(Editor.url('packages://pbkiller/panel/index.html', 'utf8')) + "",

  // element and variable binding


  // method executed when template and styles are successfully loaded and initialized
  ready () {
    let setting;
    try{
        setting = require(PBKILLER_SETTING_FILE);
    } catch(e) {
        
    }
    
    window.pbkiller = new window.Vue({
        el: this.shadowRoot,
        created() {
            console.log("---->created");
            if (setting) {
                this.protoPath = setting.protoPath;
                this.jsPath = setting.jsPath;
            }
        },

        init() {
            console.log("---->init");
        },

        data: {
            protoPath: '',
            jsPath: '',
        },

        methods: {
            saveSetting() {
                if (this.protoPath && this.jsPath) {
                    let setting = {
                        protoPath: this.protoPath,
                        jsPath: this.jsPath
                    };
                    fs.writeFileSync(PBKILLER_SETTING_FILE, JSON.stringify(setting, null, 4), 'utf8');
                }
            },

            selectSavePath() {
                let res = Editor.Dialog.openFile({
                    title: "选择要保存的js目录",
                    defaultPath: Editor.projectInfo.path,
                    properties: ['openDirectory', 'createDirectory'],
                });
        
                if (res === -1) {
                    return;
                }
                this.jsPath = res[0];
            },

            selectProtoPath() {
                let res = Editor.Dialog.openFile({
                    title: "选择要转换的proto目录",
                    defaultPath: Editor.projectInfo.path,
                    properties: ['openDirectory'],
                });
                if (res === -1) {
                    return;
                }
                this.protoPath = res[0];
            },

            convertProtoToJs() {
                if (!fs.existsSync(this.protoPath)) {
                    Editor.Dialog.messageBox({ type:'error', message: 'proto目录不存在' });
                    return;
                }

                if (!fs.existsSync(this.jsPath)) {
                    Editor.Dialog.messageBox({ type:'error', message: '保存目录不存在' });
                    return;
                }
                this.saveSetting();
                let pbjs = new Generator(this.protoPath, this.jsPath);
                pbjs.run();
            }
        },
       
    });
  },
});