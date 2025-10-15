Shader "LucidBoundary/BasicTextureShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Tiling("Tiling", Vector) = (1, 1, 0, 0)
        _Offset("Offset", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            // "QUEUE" = "Geometry"
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
            // SamplerState sampler_MainTex;
            SamplerState sampler_RepeatLinear;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;    
                float4 _Tiling;
                float4 _Offset;
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
                    _MainTex_ST.xy = _Tiling;
                    v2f o;
                    o.positionCS = TransformObjectToHClip(v.positionOS);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
            }
            float4 frag(v2f i) : SV_Target 
            {
                // float4 textureSample = tex2D(_MainTex, i.uv); // if _MainTex variable declared with sampler2D
                
                // float4 textureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_RepeatLinear, i.uv);
                float4 lodtextureSample = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_RepeatLinear, i.uv, 200);
                return lodtextureSample * _BaseColor;
            }

            ENDHLSL            
        }
        
        Pass
        {
            Name "DepthNormalsOnly"
            Tags { "LightMode" = "DepthNormalsOnly"}

            ZWrite On
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex DepthOnlyVertex;
            #pragma fragment DepthOnlyFragment;

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"

            #pragma multi_compile_instancing
            #pragma multi_compile_DOTS_INSTANCING_ON

            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
