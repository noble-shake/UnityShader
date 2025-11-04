Shader "LucidBoundary/FishShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (0, 0, 0, 1)
		_Radius("Radius", Float) = 1
		_Height("Height", Float) = 0.5
		_WaveSpeed("Wave Speed", Float) = 0.5
		_WaveStrength("Wave Strength", Float) = 0.5
		_BodyStrength("Body Strength", Float) = 0.5
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
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
			#define UNITY_PI 3.14159265359f

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			texture2D _MainTex;
			SamplerState sampler_MainTex;

			struct appdata
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 positionCS : SV_Position;
				float2 uv : TEXCOORD0;
			};

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _BaseColor;
				float3 _TransformMatrices;
				float4x4 _TransformRotation;
				float _BodyStrength;
				float _WaveSpeed;
				float _WaveStrength;
				float _Radius;
				float _Height;
			CBUFFER_END

          float3x3 YRotationMatrix(float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0f;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                return float3x3(
                    cosa, 0, -sina,
                    0, 1, 0,
                    sina, 0, cosa);
            }

            v2f vert (appdata v)
            {
				v2f o;
				float4 pos = mul(unity_ObjectToWorld, v.positionOS);
				float3x3 matRotate = YRotationMatrix(degrees(90.0f - _Time.y)); 
				// pos.xyz = mul(matRotate, pos.xyz);

				// float4 originPos = mul(unity_ObjectToWorld, pos.xyz);

				float swing = sin(_Time.y * _WaveSpeed + pos.x); // Wave * Frequency
				float4 circularMove = float4(cos(_Time.y), 0.0f, sin(_Time.y), 0.0f) * _Radius * swing; 


				float4 rotated = float4(mul(matRotate, pos.xyz), 1.0f);
				float4 result = rotated + circularMove;


				o.positionCS = mul(UNITY_MATRIX_VP, result);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				float4 outputTexture = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				return outputTexture * _BaseColor;
            }
            ENDHLSL
        }
    }
	Fallback Off
}
