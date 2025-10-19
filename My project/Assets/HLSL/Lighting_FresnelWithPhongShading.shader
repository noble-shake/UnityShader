Shader "Lucid-Boundary/Lighting_FresnelWithPhongShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _GlossPower("Gloss Power", Float) = 400
        _FresnelPower("Fresnel Power", Float) = 5
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
            Tags
            {
                "LightMode" = "UniversalForward"    
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
                float4 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normalWS : TEXCOORD1;
                float3 viewWS : TEXCOORD2;
            };

            texture2D _MainTex;
            SamplerState sampler_MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _MainTex_ST;
                float _GlossPower;
                float _FresnelPower;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);

                float3 positionWS = mul(unity_ObjectToWorld, v.vertex);
                o.viewWS = GetWorldSpaceViewDir(positionWS);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.normalWS);
                float3 view = normalize(i.viewWS);

                // Ambient
                float3 ambient = SampleSH(i.normalWS);
                
                // diffuse
                Light mainLight = GetMainLight();
                float3 diffuse = mainLight.color * max(0, dot(normal, mainLight.direction));

                // specular
                float3 halfVector = normalize(mainLight.direction + view);
                float specular = max(0, dot(normal, halfVector));
                specular = pow(specular, _GlossPower);
                float3 specularColor = mainLight.color * specular;

                // fresnel
                float fresnel = 1.0f - max(0, dot(normal, view));
                fresnel = pow(fresnel, _FresnelPower);
                float3 fresnelColor = mainLight.color * fresnel;
                fresnelColor = fresnelColor * float3(0.0f, 0.0f, 1.0f);

                float4 diffuseLighting = float4(ambient + diffuse, 1.0f);
                float4 specularLighting = float4(specularColor + fresnelColor, 1.0f);

                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex ,i.uv);
                return tex * _BaseColor * diffuseLighting + specularLighting;
            }
            ENDHLSL
        }
    }
}
