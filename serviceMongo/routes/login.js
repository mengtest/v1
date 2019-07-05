/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 09:51:40
 * @LastEditTime: 2019-07-05 12:11:32
 */
var express = require('express');
var router = express.Router();

let User = require('../src/user'), UserDao = require('../src/userDao');

let proto = require('../lib/proto');

/* GET home page. */
router.post('/', function(req, res, next) {
    
    res.status(200); 
    res.type('text/json;charset=utf-8');  

    let userDao = new UserDao();
    let user = new User();

    console.log(req.body)

    userDao.findOne({
        phone: req.body.phone
    }).then((result)=>{1
        

        if( result != null && result.length != 0 ){

            res.send({
                message:'登录成功',
                status: true,
                content: result
            });
          
        } else {

            res.send({
                message:"登录失败",
                status:false,
                content:{}
            });
        }

    } );

});

module.exports = router;
