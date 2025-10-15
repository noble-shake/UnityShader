Shader "Unlit/DepthBuffer_StencilMask"
{
    Properties
    {
        [IntRange] _StencilRef("Stencil Ref", Range(0, 255)) = 1
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
            Blend Zero One
            Stencil
            {
                Ref[_StencilRef]
                Comp Always
                Pass Replace
                Fail Keep
            }

            ZWrite Off
           
        }
    }
    Fallback Off
}
