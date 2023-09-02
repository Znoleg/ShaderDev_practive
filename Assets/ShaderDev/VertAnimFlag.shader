// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/09VertFlagAnim"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Frequency("Frequency", Float) = 1
        _Amplitude("Amplitude", Float) = 1
        _Speed("Speed", Float) = 1
        _Gravity("Gravity", Float) = 1

        [Header(Rendering)]
        _Offset("Offset", float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Cull Mode", Int) = 2
        [Enum(Off,0,On,1)] _ZWrite("ZWrite", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4
        [Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _ColorMask("Color Mask", Int) = 1
    }

    CGINCLUDE
	#include "UnityCG.cginc"

	#define PI 3.1415926
	#define backC2 2.5949095
	
	//http://docs.unity3d.com/ru/current/Manual/SL-ShaderPerformance.html
	//http://docs.unity3d.com/Manual/SL-ShaderPerformance.html
	uniform half4 _Color;
	uniform sampler2D _MainTex;
	uniform float4 _MainTex_ST;
	uniform float _Frequency;
	uniform float _Amplitude;
	uniform float _Speed;
	uniform float _Gravity;
			
	//https://msdn.microsoft.com/en-us/library/windows/desktop/bb509647%28v=vs.85%29.aspx#VS
	struct vertexInput
	{
		float4 vertex : POSITION;
		float4 texcoord : TEXCOORD0;
	};
			
    struct vertexOutput
    {
    	float4 pos : SV_POSITION;
    	float4 texcoord : TEXCOORD0; 
    };

	//Sine
	float EaseInSine(float x)
	{
	    return 1.0 - cos((x * PI) / 2.0);
	}
			
	float4 vertexFlagAnim(float4 vertPos, float2 uv, float gravity)
	{
		vertPos.z = vertPos.z + sin( (uv.x - (_Time.y * _Speed)) * _Frequency) * (uv.x * _Amplitude);
		vertPos.y -= gravity * EaseInSine(uv.x); 
		return vertPos;
	}
			
	vertexOutput vert(vertexInput v)
	{
		vertexOutput o; UNITY_INITIALIZE_OUTPUT(vertexOutput, o); // d3d11 requires initialization
		v.vertex = vertexFlagAnim(v.vertex, v.texcoord, _Gravity);
		o.pos = UnityObjectToClipPos( v.vertex);
		o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
		return o;
	}
			
	half4 frag(vertexOutput i) : COLOR
	{
		float4 col = tex2D(_MainTex, i.texcoord) * _Color;
		// col.a = drawCircleAnimate(i.texcoord, _Center , _Radius, _Feather);
		return col;
	}

	struct v2fShadow {
        V2F_SHADOW_CASTER;
        UNITY_VERTEX_OUTPUT_STEREO
    };
 
    v2fShadow vertShadow( appdata_base v )
    {
        v2fShadow o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        return o;
    }
 
    float4 fragShadow( v2fShadow i ) : SV_Target
    {
        SHADOW_CASTER_FRAGMENT(i)
    }

	ENDCG

    Subshader
    {
        Tags
        {
            "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Zwrite Off
            Cull Back

            CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			ENDCG
        }

        Pass
        {
            Tags
            {
                "RenderType"="Opaque" "Queue" = "Geometry"
            }
            LOD 100
            Cull [_Culling]
            Offset [_Offset], [_Offset]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            LOD 80
            Cull [_Culling]
            Offset [_Offset], [_Offset]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            ENDCG
        }
    }
}