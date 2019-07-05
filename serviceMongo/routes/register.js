/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 10:16:40
 * @LastEditTime: 2019-05-07 11:42:36
 */
var express = require('express');
var router = express.Router();
let User = require('../src/user'), UserDao = require('../src/userDao');


/* GET home page. */
router.post('/', function(req, res, next) {
    
    res.status(200); 
    res.type('text/json;charset=utf-8');  

    let userDao = new UserDao();
    let user = new User();
    user.phone = req.body.phone;
    user.code = 0;
    user.nickname = req.body.phone;
    user.avatar = '';
    user.coin = 999;

    userDao.findAll({
        phone: req.body.phone
    }).then((result)=>{
      
        if( result != null && result.length != 0 ){

            res.send({
                message:'注册失败',
                status:false,
                content:{}
            });
          
        } else {

            userDao.update({
                phone: req.body.phone
            }, user, {
                upsert: true
            }).then( (result)=>{

                if( result.ok == 1 ){

                    res.send({
                        message:'注册成功',
                        status: true,
                        content: user
                    });

                } else {
                    
                    res.send({
                        message:'注册失败',
                        status:false,
                        content:{}
                    });
                }
                
            });
        }

    } );

});

module.exports = router;