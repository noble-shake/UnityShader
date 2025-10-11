Shader "LucidBoundary/ModifyingTextureShader_Flipbook"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Center("Center", Vector) = (0.5, 0.5, 0, 0)
        _RadialScale("Radial", Float) = 1
        _LengthScale("Length", Float) = 1
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
                float2 _Center;
                float _RadialScale;
                float _LengthScale;
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

            float2 CartToPolar(float2 cartUV)
            {
                    const float PI_value = 3.14159235f;
                    float2 offset = cartUV - _Center;
                    float radius = length(offset) * 2;
                    float angle = atan2(offset.x, offset.y) / (2.0f * PI_value);

                    return float2(radius, angle);
            }

            v2f vert (appdata v) 
            {
                    v2f o;
                    o.positionCS = TransformObjectToHClip(v.positionOS);

                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                    return o;
            }
            float4 frag(v2f i) : SV_Target 
            {
                float2 radialUV = CartToPolar(i.uv);
                radialUV.x *= _RadialScale;
                radialUV.y *= _LengthScale;
                float4 lodtextureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_RepeatLinear, radialUV);
                return lodtextureSample * _BaseColor;
            }

            ENDHLSL            
        }

    }
    FallBack "Diffuse"
}
