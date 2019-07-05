/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 10:12:48
 * @LastEditTime: 2019-05-07 12:01:30
 */
let {Schema} = require('mongoose');
let {mongoClient} = require('../lib/mongo');

const userSchema = new Schema({
    phone: {type:String, required: true},
    code: { type:String, required: false, default:'' } ,
    nickname: {type:String, required: false, default:""},
    avatar: {type:String, required: false, default:""},
    coin: {type:Number, required: false, default:0}
});

/**
 * 参数一要求与 Model 名称一致
 * 参数二为 Schema
 * 参数三为映射到 MongoDB 的 Collection 名
 */
let User = mongoClient.model(`User`, userSchema, 'user');

module.exports = User;