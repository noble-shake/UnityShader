// 실제로 URP에서는 GrabPass를 사용하지 못한다.

Shader "Lucid-Boundary/GrapPassSepiaToneWithURP"
{
    Properties
    {

    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"    
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 screenUV : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.screenUV = ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float3x3 sepia = float3x3 
                (
                    0.393f, 0.349f, 0.272f, // Red
                    0.769f, 0.686f, 0.534f, // Green
                    0.189f, 0.168f, 0.131f  // Blue
                );

                float2 scrUVs = i.screenUV.xy / i.screenUV.w;
                float3 sceneColor = SampleSceneColor(scrUVs);
                float3 outputColor = mul(sceneColor, sepia);
                return float4(outputColor, 1.0f);
            }
            ENDHLSL
        }
    }
}
