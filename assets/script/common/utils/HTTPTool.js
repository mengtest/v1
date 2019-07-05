/*
 * @Author: Michael Zhang
 * @Date: 2019-07-04 17:58:48
 * @LastEditTime: 2019-07-05 13:35:35
 */
let HTTPTool = {

    xmlHttp : cc.loader.getXMLHttpRequest(),

    sendRequest (url, externURL, data, handler, isPost, obj) {

        var param = "";
        if(!isPost) {
            param = "?"
        }
        
        for(var key in data)
        {
            if(param != "?" && param != "")
            {
                param += "&"    
            }
            param += key + "=" + data[key]
        }
        if(isPost) {

            this.xmlHttp.open("POST", url+ externURL);
            this.xmlHttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded");  
            this.xmlHttp.send(param);
            
        } else {
            
            this.xmlHttp.open("GET", url +externURL+ encodeURI(param), true)
            this.xmlHttp.send();
        }
        
        this.xmlHttp.onreadystatechange = ()=>{

            if(this.xmlHttp.readyState === 4 && (this.xmlHttp.status >= 200 && this.xmlHttp.status < 300)){

                try {
                    if(handler !== null){
                        handler.apply(obj, [this.xmlHttp.responseText]);
                    }                        /* code */
                } catch (e) {
                    
                } finally{
                
                }
            }
        };
        
    }

   
}

module.exports = HTTPTool;