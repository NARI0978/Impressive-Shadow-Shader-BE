#include "ShaderConstants.fxh"
#include "snoise.fxh"

struct PS_Input
{
	float4 position : SV_Position;
	float4 color : COLOR;
	float3 pos : ISBECloud;
	float sky : ISBESky;
};
struct PS_Output
{
	float4 color : SV_Target;
};




float fBM(int octaves, float lowerBound, float upperBound, float2 st) {
	float value = 0.0;
	float amplitude = 0.5;
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

ROOT_SIGNATURE
void main( in PS_Input PSInput, out PS_Output PSOutput )
{
	float3 CC_DC = float3(1.3,1.3,1.1);
	float3 CC_NC = float3(0.62,0.62,0.62);
	float4 n_color = PSInput.color;
	float weather = smoothstep(0.8,1.0,FOG_CONTROL.y);//天候時
	n_color = lerp(lerp(n_color,FOG_COLOR,0.33),FOG_COLOR,smoothstep(0.0,0.6,PSInput.sky));

	float day = smoothstep(0.15,0.25,FOG_COLOR.g);//日中
	float3 cc = lerp(CC_NC,CC_DC,day);//雲の色
	float lb = lerp(0.0,0.6,weather);//雲の量
	float cm = fBM(10,lb,1.2,PSInput.pos.xz*4.5 -TIME*0.005);//雲の動き
	n_color.rgb = lerp(n_color.rgb, cc, cm);

PSOutput.color = lerp(n_color, FOG_COLOR,PSInput.sky );
}
