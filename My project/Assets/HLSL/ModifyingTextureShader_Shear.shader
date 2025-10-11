Shader "LucidBoundary/ModifyingTextureShader_Shear"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Shearing("Shear Vector", Vector) = (0, 0, 0, 0)
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

            texture2D _MainTex;
            SamplerState sampler_MainTex;
            SamplerState sampler_RepeatLinear;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;    
                float4 _MainTex_ST;
                float2 _Shearing;
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
                    float2x2 shearMat = float2x2 (1, _Shearing.x, _Shearing.y, 1);

                    v2f o;
                    o.positionCS = TransformObjectToHClip(v.positionOS.xyz);

                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    o.uv = mul(shearMat, o.uv);

                    return o;
            }
            float4 frag(v2f i) : SV_Target 
            {

                float4 textureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_RepeatLinear, i.uv);
                return textureSample * _BaseColor;
            }

            ENDHLSL            
        }

    }
    FallBack "Diffuse"
}
