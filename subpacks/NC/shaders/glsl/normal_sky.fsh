// __multiversion__
// This signals the loading code to prepend either #version 100 or #version 300 es as apropriate.

#include "fragmentVersionSimple.h"

uniform vec4 CURRENT_COLOR;
uniform vec4 FOG_COLOR;

varying POS3 position;
varying float fog;

void main()
{
	vec4 C_C = CURRENT_COLOR;
	gl_FragColor = mix(C_C,FOG_COLOR,fog);
}