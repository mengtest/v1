/*
 * @Author: Michael Zhang
 * @Date: 2019-05-06 15:37:12
 * @LastEditTime: 2019-07-09 16:23:17
 */
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var bodyParser = require('body-parser');
var multer  = require('multer');
var cors = require('cors');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var loginRouter = require('./routes/login');
var registerRouter = require('./routes/register');
var versionRouter = require('./routes/version');
var codeRouter = require('./routes/code');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(multer({ dest: '/tmp/'}).array('image'));
app.use(cors());
var urlencodedParser = bodyParser.urlencoded({ extended: false })

app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/register',urlencodedParser, registerRouter);
app.use('/heartbreak',urlencodedParser, loginRouter);
app.use('/version', versionRouter);
app.use('/getCode', codeRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.send({message:err.message,status:false});
});

module.exports = app;