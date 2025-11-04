Shader "LucidBoundary/FishShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _MetallicTex ("Metallic Texture", 2D) = "white" {}
        _MetallicStrength ("Metallic Strength", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _NormalTex("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", float) = 1
        [Toggle(USE_EMISSION_ON)] _EmissionOn("Use Emission Toggle", float) = 0
        _EmissionTex("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor("Emission Color", Color) = (0, 0, 0, 0)
        _AOTex("Ambient Occulsion Map", 2D) = "white" {}

        _WaveSpeed("Wave Speed", Float) = 1
        _WaveStrength("Wave Strength", Float) = 1
        _Height("Height", Float) = 0
    }

    /*

    물고기는 Height에 의해 전체 좌표를 위나 아래로 올린다.
    Radius를 설정해 해당 길이를 빙글 돈다.
    가는 방향으로 계속  회전 시킨다.

    */

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
            "RenderPipeline"="UniversalPipeline" 
        }
        
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"    
            }    

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert;
            #pragma fragment frag;

            #pragma multi_compile_local USE_EMISSION_ON __
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DECLARE_LIGHTMAP_OR_SH

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            texture2D _MainTex;
            texture2D _MetallicTex;
            texture2D _NormalTex;
            texture2D _EmissionTex;
            texture2D _AOTex;

            SamplerState sampler_MainTex;
            SamplerState sampler_MetallicTex;
            SamplerState sampler_NormalTex;
            SamplerState sampler_EmissionTex;
            SamplerState sampler_AOTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _MetallicsStrength;
                float _Smoothness;
                float _NormalStrength;
                float4 _EmissionColor;
                float3 _InteractionPoint;

                float _InteractWaveSpeed;
                float _WaveSpeed;
                float _WaveStrength;
            CBUFFER_END

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 staticLightmapUV : TEXCOORD1;
                float2 dynamicLightmapUV : TEXCOORD2;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
                float4 shadowCoord : TEXCOORD5;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 6);
                #ifdef DYNAMICLIGHTMAP_ON
                    float2 dynamicLightmapUV : TEXCOORD7;
                #endif
            };



            v2f vert(appdata v)
            {

            }

            float4 frag(v2f i) : SV_TARGET
            {

            }

            ENDHLSL

        }
    }
}
