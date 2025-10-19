Shader "Lucid-Boundary/DepthBuffer_XRay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _XRayColor("Xray Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"    
        }
        
        // XRay Pass
        Pass
        {
            ZTest Greater
            ZWrite Off

            Tags
            {
                "LightMode" = "UniversalForward"    
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            texture2D _MainTex;

            CBUFFER_START(UnityPerMaterial)
                float4 _XRayColor;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return _XRayColor;
            }
            ENDHLSL
        }
    }

    
}
