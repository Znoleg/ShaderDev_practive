Shader "ShaderDev/Circle"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)    
        _MainTex ("Main Texture", 2D) = "white" {}
        _Center ("Center", Float) = 0.5
        _Radius ("Radius", Float) = 0.2
		_OutlineRad ("OutlineRadius", Float) = 0.1
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
			float _OutlineRad;
            
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

			float4 makeCirclePatterned(float2 uv, float2 center, float radius, float outlineRadius, float4 color) 
			{
				float circle = pow((uv.y - center.y), 2) + pow((uv.x - center.x), 2);
				float radPow = pow(radius, 2);
				float cUvDist = distance(center, uv);
				if (cUvDist < radius) {
					float outlineWidth = radius * outlineRadius;
					if (cUvDist < outlineWidth) {
						return float4(255, 255, 255, color.a);
					}

					return color;
				}

				return float4(0, 0, 0, 0);
			}

			float makeCircle(float2 uv, float2 center, float radius) 
			{
				float circle = pow((uv.y - center.y), 2) + pow((uv.x - center.x), 2);
				float radPow = pow(radius, 2);
				if (circle < radPow) {
					return 1;
				}

				return 0;
			}

            half4 frag(vertexOutput i) : COLOR
            {
                float4 col = tex2D(_MainTex, i.texcoord) * _Color;
				col = makeCirclePatterned(i.texcoord, _Center, _Radius, _OutlineRad, col);
                return col;
            }
            
            ENDCG
        }
    }
}