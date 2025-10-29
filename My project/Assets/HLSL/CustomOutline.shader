Shader "LucideBoundary/CustomOutline"
{
    Properties
    {
        // _Color ("Color", Color) = (1,1,1,1)
        // _MainTex ("Albedo (RGB)", 2D) = "white" {}
        // _Glossiness ("Smoothness", Range(0,1)) = 0.5
        // _Metallic ("Metallic", Range(0,1)) = 0.0
        _OutlineThick("Outline Thickness", Float) = 1.0
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Name "CustomOutline"

        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline"    
        }
        
        Pass
        {
            Cull Front
            Tags
            {
                "LightMode" = "UniversalForward"    
            }
            // Outline
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma vertex vert
            #pragma fragment frag

            texture2D _MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float _OutlineThick;
            CBUFFER_END

            struct appdata0
            {
                float4 positionOS : POSITION;    
                float3 normalOS : NORMAL;    
            };

            struct v2f0
            {
                float4 positionWS : SV_POSITION;    
            };

            v2f0 vert(appdata0 i)
            {
                    v2f0 o;
                    float3 norm = normalize(i.normalOS);
                    float3 pos = i.positionOS + norm * (_OutlineThick * 0.1f);
                    o.positionWS = TransformObjectToHClip(float4(pos, 1.0f));
                    return o;
            }

            float4 frag(v2f0 i) : SV_TARGET
            {
                return float4(0.0f, 0.0f, 0.0f, 1.0f);
            }

            ENDHLSL
        }
    }
}