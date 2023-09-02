// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/12Outline"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)    
        _MainTex ("Main Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", Float) = 0.1
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

            half4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
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

            half4 frag(vertexOutput i) : COLOR
            {
                half4 tex = tex2D(_MainTex, i.texcoord);
                return tex * _Color;
            }
            
            ENDCG
        }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 _OutlineColor;
            float _OutlineWidth;
            
            struct vertexInput
            {
                float4 vertex : POSITION; 
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
            };

            float4x4 getScaleMatrix(float outlineWidth)
            {
                float x = 1.0 + outlineWidth;
                float y = 1.0 + outlineWidth;
                float z = 1.0 + outlineWidth;
                float w = 1;
                
                float4x4 scaleMatrix =
                {
                    x, 0, 0, 0,
                    0, y, 0, 0,
                    0, 0, z, 0,
                    0, 0, 0, w
                };
                
                return scaleMatrix;
            }
            
            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                float4x4 scaleMatrix = getScaleMatrix(_OutlineWidth);
                
                o.pos = UnityObjectToClipPos(mul(scaleMatrix, v.vertex));
                return o;
            }

            half4 frag(vertexOutput i) : COLOR
            {
                return _OutlineColor;
            }
            
            ENDCG
        }
    }
}