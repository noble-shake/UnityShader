Shader "LucidBoundary/ModifyingTextureShader_Triplanar"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Tile("Tiling", float) = 1
        _BlendPower("Blending", float) = 10
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
                float _Tile;
                float _BlendPower;
            CBUFFER_END


            struct appdata 
            {
                    float4 positionOS : Position;
                    float3 normalOS : NORMAL;
                    // float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                    float4 positionCS : SV_Position;
                    float3 positionWS : TEXCOORD0;
                    float3 normalWS: TEXCOORD1;
            };

            v2f vert (appdata v) 
            {
                    v2f o;
                    o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                    o.positionWS = TransformObjectToWorld(v.positionOS.xyz);

                    o.normalWS = TransformObjectToWorldNormal(v.normalOS);


                    // o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                    return o;
            }
            float4 frag(v2f i) : SV_Target 
            {
                float2 xAxisUV = i.positionWS.zy * _Tile;
                float2 yAxisUV = i.positionWS.xz * _Tile;
                float2 zAxisUV = i.positionWS.xy * _Tile;

                float4 xSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, xAxisUV);
                float4 ySample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, yAxisUV);
                float4 zSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, zAxisUV);

                float3 weights = pow(abs(i.normalWS), _BlendPower);
                weights /= (weights.x + weights.y + weights.z);

                float4 outColor = xSample * weights.x + ySample * weights.y + zSample * weights.z;
                return outColor;

                // float4 lodtextureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_RepeatLinear, radialUV);
                // return lodtextureSample * _BaseColor;
            }

            ENDHLSL            
        }

    }
    FallBack "Diffuse"
}
