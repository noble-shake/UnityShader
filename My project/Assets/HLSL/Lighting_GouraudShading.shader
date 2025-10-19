Shader "Lucid-Boundary/Lighting_GouraudShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _GlossPower("Gloss Power", Float) = 400
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
                float4 diffuse: TEXCOORD1;
                float4 specular: TEXCOORD2;
            };

            texture2D _MainTex;
            SamplerState sampler_MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _MainTex_ST;
                float _GlossPower;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 normalWS = TransformObjectToWorldNormal(v.normalOS);
                float3 positionWS = mul(unity_ObjectToWorld, v.vertex);
                float3 viewWS = GetWorldSpaceNormalizeViewDir(positionWS);

                // Ambient = Sampled Vertex From Spherical Harmonics with Normal Vector
                float3 ambient = SampleSHVertex(normalWS);

                // Diffuse = Color * max(0, dot(Normal, LightSource))
                Light mainLight = GetMainLight();
                float3 diffuse = mainLight.color * max(0, dot(normalWS, mainLight.direction));

                // Specular = Color * Dot(Half Vector Between LightSource and Viewer, NormalVector)^power
                float3 halfVector = normalize(mainLight.direction + viewWS);
                float specular = max(0, dot(normalWS, halfVector));
                specular = pow(specular, _GlossPower);
                float3 specularColor = mainLight.color * specular;

                o.diffuse = float4(ambient + diffuse, 1.0f);
                o.specular = float4(specularColor, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex ,i.uv);
                return tex * _BaseColor * i.diffuse + i.specular;
            }
            ENDHLSL
        }
    }
}
