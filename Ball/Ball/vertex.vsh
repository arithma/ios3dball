precision mediump float;

uniform mat4 u_mv;
uniform mat4 u_mvp;
uniform vec3 u_light;
uniform vec3 u_up;

attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_coord;

varying vec3 v_position;
varying vec3 v_normal;
varying vec2 v_coord;

void main() {
    v_coord = a_coord;
    v_normal = a_normal;
    v_position = (u_mv * vec4(a_position, 1)).xyz;
    gl_Position = u_mvp * vec4(a_position, 1);
}
