Shader "Unlit/DepthBuffer_StencilTexture"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseTex("Base Texture", 2D) = "White" {}
        [IntRange] _StencilRef("Stencil Ref", Range(0, 255)) = 1
    }
    SubShader
    {
        Tags 
        {
            "RenderType"="Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"    
        }

        Pass
        {
            Stencil
            {
                Ref[_StencilRef]
                Comp Greater
                Pass Keep
                Fail Keep
            }

            Tags
            {
                "LightMode" = "UniversalForward"    
            }


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            texture2D _BaseTex;
            SamplerState sampler_BaseTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseTex_ST;
            CBUFFER_END

            struct appdata
            {
                float4 posiionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 PositionCS : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.PositionCS = TransformObjectToHClip(v.posiionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 textureSample = SAMPLE_TEXTURE2D(_BaseTex,  sampler_BaseTex, i.uv);
                float4 outputColor = textureSample * _BaseColor;
                return outputColor;
            }
            ENDHLSL
        }
    }
    Fallback Off
}
