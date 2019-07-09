/*
 * @Author: Michael Zhang
 * @Date: 2019-07-09 17:18:13
 * @LastEditTime: 2019-07-09 17:19:03
 */
Math.randomRangeInt = function(min, max) 
{
	let rand = Math.random();
	if (rand === 1) {
		rand -= Number.EPSILON;
	}
	return min + Math.floor(rand * (max - min));
}
Math.randomRangeFloat = function(min, max) 
{
    return min + (Math.random() * (max - min));
}

Math.fmod = function(x, y)
{
    let temp = Math.floor(x / y);
    return x - temp * y;
}