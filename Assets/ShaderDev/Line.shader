Shader "ShaderDev/Line"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)    
        _MainTex ("Main Texture", 2D) = "white" {}
        _LineStart ("Line Start", Float) = 0.4
        _LineWidth ("Line Width", Float) = 0.2
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
            uniform float _LineStart;
            uniform float _LineWidth;
            
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

            float makeLine(float2 uv, float start, float end)
            {
                if (uv.x > start && uv.x < end)
                {
                    return 1;   
                }

                return 0;
            }

            half4 frag(vertexOutput i) : COLOR
            {
                float4 col = tex2D(_MainTex, i.texcoord) * _Color;
                col.a = makeLine(i.texcoord, _LineStart, _LineStart + _LineWidth) * _Color.a;
                return col;
            }
            
            ENDCG
        }
    }
}