Shader "LucidBoundary/ModifyingTexture3DTexture"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 3D) = "white" {}

    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "QUEUE" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert;
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            texture3D _MainTex;
            SamplerState sampler_MainTex;
            SamplerState sampler_RepeatLinear;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;    
                float4 _MainTex_ST;
            CBUFFER_END


            struct appdata 
            {
                    float4 positionOS : Position;
                    float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                    float4 positionCS : SV_Position;
                    float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v) 
            {
                    v2f o;
                    o.positionCS = TransformObjectToHClip(v.positionOS);

                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
            }
            float4 frag(v2f i) : SV_Target 
            {
                float3 animUV = float3(i.uv, _Time.y);

                float4 textureSample = SAMPLE_TEXTURE3D(_MainTex, sampler_MainTex, animUV);
                return textureSample * _BaseColor;
            }

            ENDHLSL            
        }

    }
    FallBack "Diffuse"
}
