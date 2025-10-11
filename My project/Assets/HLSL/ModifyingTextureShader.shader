Shader "LucidBoundary/ModifyingTextureShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Rotation("Rotation", float) = 0.0
        _Cneter("Center", Vector) = (0, 0, 0, 0)
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
                float _Rotation;
                float4 _Center;
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
                    o.uv -= _Center;
                    float c = cos(_Rotation);
                    float s = sin(_Rotation);
                    float2x2 rotMat = float2x2(c, -s, s, c);
                    o.uv = mul(o.uv, rotMat);
                    o.uv += _Center;
                    return o;
            }
            float4 frag(v2f i) : SV_Target 
            {
                // float4 lodtextureSample = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_RepeatLinear, i.uv, 200);
                float4 lodtextureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_RepeatLinear, i.uv);
                return lodtextureSample * _BaseColor;
            }

            ENDHLSL            
        }

    }
    FallBack "Diffuse"
}
