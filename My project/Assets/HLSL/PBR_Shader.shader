
Shader "Lucid-Boundary/PBR_Shader"
{
    Properties
    {
        _MainTex ("Maint Texture", 2D) = "white" {}
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
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"    
        }
        LOD 200
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"    
            }

            HLSLPROGRAM
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
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
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

            // struct SurfaceData
            // {
            //     half3 albedo;
            //     half3 specular;
            //     half3 metallic;
            //     half3 smoothness;
            //     half3 normalTS;
            //     half3 emission;
            //     half3 occlusion;
            //     half3 alpha;
            //     half3 clearCoatMask;
            //     half3 clearCoatSmoothness;
            // };

            // struct InputData
            // {
            //     float3 positionWS;
            //     float4 positionCS;
            //     half3 normalWS;
            //     half3 viewDirectionWS;
            //     float4 shadowCoord;
            //     half fogCoord;
            //     half3 vertexLighting;
            //     half3 bakedGI;
            //     float2 normalizedScreenSpaceUV;
            //     half4 shadowMask;
            //     half3x3 tangentToWorld;
            // };

            v2f vert(appdata v)
            {
                v2f o;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);

                o.positionWS = vertexInput.positionWS;
                o.vertex = vertexInput.positionCS;

                // o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalWS = normalInput.normalWS;

                float sign = v.tangentOS.w;
                o.tangentWS = float4(normalInput.tangentWS.xyz, sign);
                o.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                o.shadowCoord = GetShadowCoord(vertexInput);

                OUTPUT_LIGHTMAP_UV(v.staticLightmapUV, unity_LightmapST, o.staticLightmapUV);

                #ifdef DYNAMICLIGHTMAP_ON
                    v.dynamicLightmapUV = v.dynamicLightmapUV * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                #endif
                OUTPUT_SH(o.normalWS.xyz, o.vertexSH);
                return o;

            }



            SurfaceData createSurfaceData(v2f i)
            {
                    SurfaceData surfaceData = (SurfaceData)0;

                    // Albedo ouput
                    float4 albedoSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                    surfaceData.albedo = albedoSample.rgb * _BaseColor.rgb;

                    // Metallic output
                    float4 metallicSample = SAMPLE_TEXTURE2D(_MetallicTex, sampler_MetallicTex, i.uv);
                    surfaceData.metallic = metallicSample * _MetallicsStrength;

                    // smoothness output
                    surfaceData.smoothness = _Smoothness;

                    // normal output
                    float3 normalSample = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, i.uv));
                    normalSample.rg *= _NormalStrength;
                    surfaceData.normalTS = normalSample;

                    // emission output
                    #if USE_EMISSION_ON
                        surfaceData.emission = SAMPLE_TEXTURE2D(_EmissionTex, sampler_EmissionTex, i.uv);
                    #endif

                    // ambient occlusion output
                    float4 aoSample = SAMPLE_TEXTURE2D(_AOTex, sampler_AOTex, i.uv);
                    surfaceData.occlusion = aoSample.r;

                    // alpha output
                    surfaceData.alpha = albedoSample.a * _BaseColor.a;
                    return surfaceData;

            }

            InputData createInputData(v2f i, float3 normalTS)
            {
                InputData inputData = (InputData)0;
                
                // Position input.
                inputData.positionWS = i.positionWS;

                // Normal Input
                float3 bitangent = i.tangentWS.w * cross(i.normalWS, i.tangentWS.xyz);
                inputData.tangentToWorld = float3x3(i.tangentWS.xyz, bitangent, i.normalWS);
                inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);

                // View Direction Input.
                inputData.viewDirectionWS = SafeNormalize(i.viewDirWS);

                // Shadow Coords.
                // inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                // inputData.shadowCoord = TransformWorldToShadowCoord(i.shadowCoord);
                inputData.shadowCoord = i.shadowCoord;

                //Baked lightmaps.
                #if defined(DYNAMICLIGHTMAP_ON)
                    inputData.bakedGI = SAMPLE_GI(i.staticLightmapUV, i. dynamicLightmapUV, i.vertexSH, inputData.normalWS);
                #else
                    inputData.bakedGI = SAMPLE_GI(i.staticLightmapUV, i.vertexSH, inputData.normalWS);
                #endif
                
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(i.vertex);
                inputData.shadowMask = SAMPLE_SHADOWMASK(i.staticLightmapUV);

                return inputData;
            }

            float4 frag(v2f i) : SV_TARGET
            {
                SurfaceData surfaceData = createSurfaceData(i);
                InputData inputData = createInputData(i, surfaceData.normalTS);

                return UniversalFragmentPBR(inputData, surfaceData);    
            }

            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
