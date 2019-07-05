/*
 * @Author: Michael Zhang
 * @Date: 2019-05-06 15:42:16
 * @LastEditTime: 2019-05-07 10:11:07
 */

let BaseDao = require('../lib/baseDao');
let Game = require('./game');

class GameDao extends BaseDao {
    constructor() {
        super(Game);
    }
}

module.exports = GameDao;
