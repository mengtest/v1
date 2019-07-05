/*
 * @Author: Michael Zhang
 * @Date: 2019-05-06 15:39:23
 * @LastEditTime: 2019-07-05 10:17:48
 */

let mongoose = require('mongoose');
let mongodbConfig = require('../config/default')['mongodb'];

/**
 * debug 模式
 */
// mongoose.set('debug', true);

/**
 * 使用 Node 自带 Promise 代替 mongoose 的 Promise
 */
mongoose.Promise = global.Promise;

// 配置 plugin。此处配置 plugin 的话是全局配置，推荐在 每个 Model 内 自己定义
// mongoose.plugin(require('./plugin').updatedAt);


/**
 * 配置 MongoDb options
 */
function getMongoOptions() {
    let options = {
        poolSize: 5, // 连接池中维护的连接数
        reconnectTries: Number.MAX_VALUE,
        keepAlive: 120,
        useNewUrlParser: true
    };

    if (mongodbConfig["user"]) options.user = mongodbConfig["user"];
    if (mongodbConfig["pass"]) options.pass = mongodbConfig["pass"];
    if (mongodbConfig["replicaSet"]["name"]) options.replicaSet = mongodbConfig["replicaSet"]["name"];
    
    return options;
}


/**
 * 拼接 MongoDb Uri
 *
 * @returns {string}
 */
function getMongoUri() {
    let mongoUri = 'mongodb://';
    let dbName = mongodbConfig['db'];
    let replicaSet = mongodbConfig['replicaSet'];
    if (replicaSet["name"]) { // 如果配置了 replicaSet 的名字 则使用 replicaSet
        let members = replicaSet["members"];
        for (let member of members) {
            mongoUri += `${member.host}:${member.port},`;
        }
        mongoUri = mongoUri.slice(0, -1); // 去掉末尾逗号
    } else {
        mongoUri += `${mongodbConfig["host"]}:${mongodbConfig["port"]}`;
    }
    mongoUri += `/${dbName}`;

    return mongoUri;
}


/**
 * 创建 Mongo 连接，内部维护了一个连接池，全局共享
 */
let mongoClient = mongoose.createConnection(getMongoUri(), getMongoOptions());

/**
 * Mongo 连接成功回调
 */
mongoClient.on('connected', function () {
    console.log('Mongoose1 connected to ' + getMongoUri());
});
/**
 * Mongo 连接失败回调
 */
mongoClient.on('error', function (err) {
    console.log('Mongoose1 connection error: ' + err);
});
/**
 * Mongo 关闭连接回调
 */
mongoClient.on('disconnected', function () {
    console.log('Mongoose1 disconnected');
});


/**
 * 关闭 Mongo 连接
 */
function close() {
    mongoClient.close();
}


module.exports = {
    mongoClient: mongoClient,
    close: close,
};
