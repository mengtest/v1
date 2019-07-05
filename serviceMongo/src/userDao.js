/*
 * @Author: Michael Zhang
 * @Date: 2019-05-07 10:13:05
 * @LastEditTime: 2019-05-07 10:15:37
 */

let BaseDao = require('../lib/baseDao');
let User = require('./user');

class UserDao extends BaseDao {
    constructor() {
        super(User);
    }
}

module.exports = UserDao;
