/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 11:49:56
 * @LastEditTime: 2019-05-07 12:01:44
 */
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {

    res.status(200); 
    res.type('text/json;charset=utf-8');  

    res.send( { code: "0000" });
});

module.exports = router;