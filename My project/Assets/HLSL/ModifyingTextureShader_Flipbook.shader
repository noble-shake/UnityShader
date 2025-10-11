Shader "LucidBoundary/ModifyingTextureShader_Flipbook"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _FlipSize("Flip Size", Vector) = (1, 1, 1, 1)
        _Speed("Animation Speed", float) = 1
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
                float _Speed;
                float4 _FlipSize;
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

                    float2 tileSize = float2(1.0f, 1.0f) / _FlipSize;
                    float width = _FlipSize.x;
                    float height = _FlipSize.y;
                    float tileCnt = width * height;
                    float tileID = floor((_Time.y * _Speed) % tileCnt);

                    float tileX = (tileID%width) * tileSize.x;
                    float tileY = (floor(tileID / width)) * tileSize.y;

                    o.uv = float2(v.uv.x / width + tileX, v.uv.y / height + tileY);

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
