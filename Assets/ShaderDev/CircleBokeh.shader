Shader "ShaderDev/CircleBokeh"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)    
        _MainTex ("Main Texture", 2D) = "white" {}
        _Center ("Center", Float) = 0.5
        _Radius ("Radius", Float) = 0.2
		_Feather ("Feather", Range(0.001, 0.05)) = 0.001
    }
    
    Subshader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Center;
            uniform float _Radius;
            float _Feather;
            
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

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw;
                return o;
            }

			float makeCircle(float2 uv, float2 center, float radius, float feather) 
			{
				float circle = pow((uv.y - center.y), 2) + pow((uv.x - center.x), 2);
				float radPow = pow(radius, 2);
				if (circle < radPow) {
					return smoothstep(radPow, radPow - feather, circle);
				}

				return 0;
			}

            half4 frag(vertexOutput i) : COLOR
            {
                float4 col = tex2D(_MainTex, i.texcoord) * _Color;
				col.a = makeCircle(i.texcoord, _Center, _Radius, _Feather);
                return col;
            }
            
            ENDCG
        }
    }
}