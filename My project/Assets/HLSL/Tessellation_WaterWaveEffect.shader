Shader "LucidBoundary/Tessellation_WaterWaveEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _WaveStrength("Wave Strength", Range(0, 2)) = 0.1
        _WaveSpeed("Wave Speed", Range(0, 10)) = 1


        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend("Source Blend Factor", Int) = 0
        
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend("Destination Blend Factor", Int) = 1

        _TessAmount("Tessellation Amount", Range(1, 64)) = 2

        [Toggle(LOD_ON)] 
        _TessMinDistance("Tess Min Distance", Float) = 20
        _TessMaxDistance("Tess Max Distance", Float) = 50
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "RenderPipeline" = "UniversalPipeline"    
        }

        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            Tags
            {
                "LightMode" = "UniversalForward"    
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma hull tessHull
            #pragma domain tessDomain
            #pragma target 4.6

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #pragma multi_compile LOD_ON __

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct tessControlPoint
            {
                float4 positionOS : INTERNALTESSPOS;
                // float4 positionWS : INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
            };

            struct tessFactors
            {
                float edge[3] : SV_TessFactor;
                float inside : SV_InsideTessFactor;
                
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            texture2D _MainTex;
            SamplerState sampler_MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _BaseColor;
                float _TessAmount;
                float _WaveStrength;
                float _WaveSpeed;
                float _TessMinDistance;
                float _TessMaxDistance;
            CBUFFER_END

            tessControlPoint vert(appdata v)
            {
                tessControlPoint o;
                o.positionOS = v.positionOS;
                o.uv = v.uv;
                return o;
            }

            v2f tessVert(appdata v)
            {
                v2f o;

                float4 positionWS = mul(unity_ObjectToWorld, v.positionOS);
                float height = sin(_Time.y * _WaveSpeed + positionWS.x + positionWS.z);
                positionWS.y += height* _WaveStrength;

                o.positionCS = mul(UNITY_MATRIX_VP, positionWS);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            tessFactors patchConstantFunc(InputPatch<tessControlPoint, 3> patch)
            {
                tessFactors f;
                f.edge[0] = f.edge[1] = f.edge[2] = _TessAmount;
                f.inside = _TessAmount;
                return f;
            }

            tessFactors patchConstantFuncLOD(InputPatch<tessControlPoint, 3> patch)
            {
                tessFactors f;

                float3 triPos0 = patch[0].positionOS.xyz;
                float3 triPos1 = patch[1].positionOS.xyz;
                float3 triPos2 = patch[2].positionOS.xyz;

                float3 edgePos0 = 0.5f * (triPos1 + triPos2);
                float3 edgePos1 = 0.5f * (triPos0 + triPos2);
                float3 edgePos2 = 0.5f * (triPos0 + triPos1);
                
                float3 camPos = _WorldSpaceCameraPos;

                float dist0 = distance(edgePos0, camPos);
                float dist1 = distance(edgePos1, camPos);
                float dist2 = distance(edgePos2, camPos);

                float3 fadeDist = _TessMaxDistance - _TessMinDistance;

                float edgeFactor0 = saturate(1.0f - (dist0 - _TessMinDistance) / fadeDist);
                float edgeFactor1 = saturate(1.0f - (dist1 - _TessMinDistance) / fadeDist);
                float edgeFactor2 = saturate(1.0f - (dist2 - _TessMinDistance) / fadeDist);

                f.edge[0] = max(pow(edgeFactor0, 2) * _TessAmount, 1);
                f.edge[1] = max(pow(edgeFactor1, 2) * _TessAmount, 1);
                f.edge[2] = max(pow(edgeFactor2, 2) * _TessAmount, 1);

                f.inside = (f.edge[0] + f.edge[1] + f.edge[2] / 3.0f);

                return f;
            }


            #if LOD_ON
                [domain("tri")]
                [outputcontrolpoints(3)]
                [outputtopology("triangle_cw")]
                [partitioning("fractional_even")]
                [patchconstantfunc("patchConstantFuncLOD")]
                tessControlPoint tessHull(InputPatch<tessControlPoint, 3> patch, uint id : SV_OutputControlPointID)
                {
                    return patch[id];
                }
            #else
                [domain("tri")]
                [outputcontrolpoints(3)]
                [outputtopology("triangle_cw")]
                [partitioning("fractional_even")]
                [patchconstantfunc("patchConstantFunc")]
                tessControlPoint tessHull(InputPatch<tessControlPoint, 3> patch, uint id : SV_OutputControlPointID)
                {
                    return patch[id];
                }
            #endif


            [domain("tri")]
            v2f tessDomain(tessFactors factors, OutputPatch<tessControlPoint, 3> patch, float3 bcCoords : SV_DomainLocation)
            {
                appdata i;

                i.positionOS = patch[0].positionOS * bcCoords.x + patch[1].positionOS * bcCoords.y + patch[2].positionOS * bcCoords.z;
                i.uv = patch[0].uv * bcCoords.x + patch[1].uv * bcCoords.y + patch[2].uv * bcCoords.z;

                return tessVert(i);
                    
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 textureSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return textureSample * _BaseColor;
            }
            ENDHLSL
        }
    }
}
