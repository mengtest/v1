/*
 * @Author: Michael Zhang
 * @Date: 2019-07-15 11:47:21
 * @LastEditTime: 2019-07-15 11:57:00
 */

module.exports =
    `
uniform sampler2D texture;
varying vec2 uv0;
uniform float sys_time;
void main()
{
    vec4 src_color = texture2D(texture, uv0).rgba;
    float width = 0.2;
    float start = sys_time * 1.2;
    float strength = 0.02;
    float offset = 0.2;
    
    if( uv0.x < (start - offset * uv0.y) &&  uv0.x > (start - offset * uv0.y - width))
    {
        vec3 improve = strength * vec3(255, 255, 255);
        vec3 result = improve * vec3( src_color.r, src_color.g, src_color.b);
        gl_FragColor = vec4(result, src_color.a);
    } else {
        gl_FragColor = src_color;
    }
}
`