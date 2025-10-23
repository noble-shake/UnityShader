using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class PPE_GrayscaleRenderFeature : ScriptableRendererFeature
{
    PPE_GrayscaleRenderPass renderPass;
    [SerializeField] Shader shader;
    Material _material;

    public override void Create()
    {
        this.name = "Grayscale Post Processing";
        renderPass = new PPE_GrayscaleRenderPass();

    }



    public override void AddRenderPasses(ScriptableRenderer renderer,  ref RenderingData renderingData)
    {
        if (shader) _material = CoreUtils.CreateEngineMaterial(shader);
        renderPass.SetupImprove(_material, this.name);
        renderer.EnqueuePass(renderPass);
    }

}
