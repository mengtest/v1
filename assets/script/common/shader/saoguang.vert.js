/*
 * @Author: Michael Zhang
 * @Date: 2019-07-15 11:47:29
 * @LastEditTime: 2019-07-15 11:58:22
 */

module.exports = `
uniform mat4 viewProj;
attribute vec3 a_position;
attribute vec2 a_uv0;
varying vec2 uv0;
void main () {
    vec4 pos = viewProj * vec4(a_position, 1);
    gl_Position = pos;
    uv0 = a_uv0;
}`