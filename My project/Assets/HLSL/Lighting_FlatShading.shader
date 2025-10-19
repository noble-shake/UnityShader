Shader "Lucid-Boundary/Lighting_FlatShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
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
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                nointerpolation float4 flatLighting : TEXCOORD1;
            };

            texture2D _MainTex;
            SamplerState sampler_MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _MainTex_ST;
            CBUFFER_END


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float3 normalWS = TransformObjectToWorldNormal(v.normalOS);
                
                // Ambient
                float3 ambient = SampleSHVertex(normalWS);

                // Diffuse
                Light mainLight = GetMainLight();
                float3 diffuse = mainLight.color * max(0, dot(normalWS, mainLight.direction));

                o.flatLighting = float4(ambient + diffuse, 1.0f);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex ,i.uv);
                return tex * _BaseColor * i.flatLighting;
            }
            ENDHLSL
        }
    }
}
