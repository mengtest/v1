/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 10:43:15
 * @LastEditTime: 2019-05-07 11:01:06
 */
var express = require('express');
var router = express.Router();
var GameDao = require('../src/gameDao'), GameModel = require('../src/game');

/* GET home page. */
router.get('/', function(req, res, next) {
    
    res.status(200); 
    res.type('text/json;charset=utf-8');  

    let gameDao = new GameDao();

    gameDao.findOne( {}).then((result)=>{

        console.log(typeof result);

        if( result != null ) {

            res.send({
                message:'获取版本成功',
                status:true,
                content:{
                    game: result.game,
                    version: result.version
                }
            });

        } else {
            res.send({
                message:'获取版本失败',
                status:false,
                content:{}
            });
        }
      
    });
   
});

module.exports = router;