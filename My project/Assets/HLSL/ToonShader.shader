Shader "LucideBoundary/ToonShader"
{
    Properties
    {
        // _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        // _Glossiness ("Smoothness", Range(0,1)) = 0.5
        // _Metallic ("Metallic", Range(0,1)) = 0.0
        // _OutlineThick("Outline Thickness", Float) = 1.0
        _GlossPower("Gloss Power", Float) = 1.0
        _Div("Div Amount", Float) = 1.0
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline"    
        }

        Pass
        {
            Cull Back
            Tags
            {
                "LightMode" = "UniversalForward"    
            }
            HLSLPROGRAM



            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #pragma vertex vert
            #pragma fragment frag

            texture2D _MainTex;
            SamplerState sampler_MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _GlossPower;
                float _Div;
            CBUFFER_END

            struct appdata1
            {
                float4 positionOS : POSITION;     
                float3 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct v2f1
            {
                float4 positionWS : SV_POSITION;    
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewWS : TEXCOORD2;
            };

            v2f1 vert(appdata1 v)
            {
                v2f1 o;
                o.positionWS = TransformObjectToHClip(v.positionOS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);

                float3 positionWS = mul(unity_ObjectToWorld, v.positionOS);
                o.viewWS = GetWorldSpaceViewDir(positionWS);
                return o;
            }

            float4 frag(v2f1 i) : SV_TARGET
            {
                float3 normal = normalize(i.normalWS);
                float3 view = normalize(i.viewWS);

                // Ambient
                float3 ambient = SampleSH(i.normalWS);
                
                // diffuse
                Light mainLight = GetMainLight();
                float3 diffuse = mainLight.color * ceil(max(0, dot(normal, mainLight.direction)) * _Div)/_Div;

                float3 halfVector = normalize(mainLight.direction + view);
                float specular = max(0, dot(normal, halfVector));
                specular = pow(specular, _GlossPower);
                float3 specularColor = mainLight.color * specular;

                float4 diffuseLighting = float4(ambient + diffuse, 1.0f);
                float4 specularLighting = float4(specularColor, 1.0f);

                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex ,i.uv);
                return tex * _BaseColor * diffuseLighting + specularLighting;
            }



            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
