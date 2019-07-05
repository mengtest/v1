/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 09:36:45
 * @LastEditTime: 2019-05-07 09:51:55
 */
var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'GOOOD' });
});

module.exports = router;
