// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "ShaderDev/11NormalMapOleg"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)    
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal map", 2D) = "white" {}
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
            uniform sampler2D _NormalMap;
            uniform float4 _NormalMap_ST;
            
            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0; 
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 texcoord : TEXCOORD0;
                float4 normalWorld : TEXCOORD1;
                float4 tangentWorld : TEXCOORD2;
                float3 binormalWorld : TEXCOORD3;
                float4 normalTexCoord : TEXCOORD4;
            };

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy) + _MainTex_ST.zw;
                o.normalTexCoord.xy = (v.texcoord.xy * _NormalMap_ST.xy) + _NormalMap_ST.zw;

                // World space T, B, N values
                o.normalWorld = normalize(mul(v.normal, unity_WorldToObject)); // inverse the matrix & order to prevent non-uniform scaling issues
                o.tangentWorld = normalize(mul(v.tangent,unity_ObjectToWorld));
                o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);

                return o;
            }

            float3 normalFromColor(float4 colorVal)
            {
                #if defined(UNITY_NO_DXT5nm)
                    return colorVal.xyz * 2 - 1;
                #else
                    // R => x => A
                    // G => y
                    // B => z => ignored
                    float3 normalVal;
                    normalVal = float3(colorVal.a * 2 - 1,colorVal.g * 2 - 1, 0.0);
                    normalVal.z = sqrt(1 - dot(normalVal, normalVal));
                    return normalVal;
                #endif
            }
            
            float4 frag(vertexOutput i) : COLOR
            {
                // Color at Pixel which we read from Tangent space normal map
                float4 colorAtPixel = tex2D(_NormalMap, i.normalTexCoord);

                // Normal value converted from Color value
                float3 normalAtPixel = normalFromColor(colorAtPixel);

                // Compose TBN matrix
                float3 firstRow = float3(i.tangentWorld.x, i.binormalWorld.x, i.normalWorld.x);
                float3 secondRow = float3(i.tangentWorld.y, i.binormalWorld.y, i.normalWorld.y);
                float3 thirdRow = float3(i.tangentWorld.z, i.binormalWorld.z, i.normalWorld.z);
                
                float3x3 TBNWorld = float3x3(firstRow, secondRow, thirdRow);
                float3 worldNormalAtPixel = normalize(mul(TBNWorld, normalAtPixel)); 

                return float4(worldNormalAtPixel, 1);
                //half4 tex = tex2D(_MainTex, i.texcoord);
                //return tex * _Color;
            }
            
            ENDCG
        }
    }
}