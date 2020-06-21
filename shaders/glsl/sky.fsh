// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#if __VERSION__ >= 300
	// version 300 code
	#define varying in
	#define texture2D texture
	out vec4 FragColor;
	#define gl_FragColor FragColor
	#define texture2D texture
#else
	// version 100 code
#endif

varying vec4 color;
varying vec4 fogcolor;
varying float fogintense;
varying highp vec3 position;

uniform highp float TIME;
uniform vec2 FOG_CONTROL;

#include "snoise.h"

vec3 CC_DC = vec3(1.3,1.3,1.1);
vec3 CC_NC = vec3(0.2,0.21,0.25);


highp float fBM(const int octaves, const float lowerBound, const float upperBound, highp vec2 st) {
	highp float value = 0.0;
	highp float amplitude = 0.5;
	for (int i = 0; i < octaves; i++) {
		value += amplitude * (snoise(st) * 0.5 + 0.5);
		if (value >= upperBound) {break;}
		else if (value + amplitude <= lowerBound) {break;}
		st        *= 2.0;
		st.x      -=TIME/256.0*float(i+1);
		amplitude *= 0.5;
	}
	return smoothstep(lowerBound, upperBound, value);
}

void main()
{
vec4 n_color = color;
float weather = smoothstep(.8,1.,FOG_CONTROL.y);//天候時
n_color = mix(mix(n_color,fogcolor,.33)+vec4(0.0,0.05,0.1,0.0),fogcolor*1.1,smoothstep(.1,.4,fogintense));

	float day = smoothstep(.15,.25,fogcolor.g);//日中
	vec3 cc = mix(CC_NC,CC_DC,day);//雲の色
	float lb = mix(.0,.55,weather);//雲の量
	float cm = fBM(10,lb,1.2,position.xz*3.5 -TIME*.01);//雲の動き
	n_color.rgb = mix(n_color.rgb, cc, cm);

gl_FragColor = mix(n_color, fogcolor, fogintense);
}
