using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;
using UnityEngine.UIElements;
using static Unity.Burst.Intrinsics.X86.Avx;
using static UnityEditor.ShaderData;

public class PPE_GrayscaleRenderPass : ScriptableRenderPass
{

    private Material material;
    private PPE_GrayscaleSetting setting;
   
    private RenderTargetIdentifier source;
    private RenderTargetIdentifier mainTex;

    private string profilerTag;

    private class PassData
    {
        internal TextureHandle cameraColorTexture; // source
        internal TextureHandle copyColorTexture; // maintTex
        internal Material material;
    }

    private static readonly ProfilingSampler k_ProfilingSampler = new("GrayScale RenderPass");

    public void SetupImprove(Material _material, string profilerTag)
    { 
        this.material = _material;
        this.profilerTag = profilerTag;
        // source = _source;
        VolumeStack stack = VolumeManager.instance.stack;
        setting = stack.GetComponent<PPE_GrayscaleSetting>();
        // renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    [Obsolete]
    public void Setup(ScriptableRenderer renderer, string profilerTag) 
    {

        this.profilerTag = profilerTag;
        source = renderer.cameraColorTargetHandle;
        VolumeStack stack = VolumeManager.instance.stack;
        setting = stack.GetComponent<PPE_GrayscaleSetting>();
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        if (setting != null && setting.IsActive())
        {
            renderer.EnqueuePass(this);
            material = new Material(Shader.Find("LucidBoundary/BasicTextureShader_PostProcessing"));
        }
 
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {

        if (setting == null) return;

        UniversalResourceData resourcesData = frameData.Get<UniversalResourceData>();
        UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
        if (!material || !cameraData.postProcessEnabled) return;

        // Setup RenderTextureHandle
        
        var cameraColorTexture = resourcesData.cameraColor;
        var copyDescriptor = renderGraph.GetTextureDesc(cameraColorTexture);
        copyDescriptor.name = "CopiedTexture";
        copyDescriptor.clearBuffer = false;
        copyDescriptor.msaaSamples = MSAASamples.None;
        copyDescriptor.depthBufferBits = 0;
        var copyColorTexture = renderGraph.CreateTexture(copyDescriptor);
        material.SetFloat("_Strength", setting.strength.value);
        RenderGraphUtils.BlitMaterialParameters para = new(cameraColorTexture, copyColorTexture, material, 0);
        renderGraph.AddBlitPass(para);

        resourcesData.cameraColor = copyColorTexture;
    }

    [Obsolete]
    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
    {
        if (setting == null) return;

        int id = Shader.PropertyToID("_MainTex");
        mainTex =  new RenderTargetIdentifier(id);
        cmd.GetTemporaryRT(id, cameraTextureDescriptor);

        base.Configure(cmd, cameraTextureDescriptor);
    }

    [Obsolete]
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        // RTHandle ColorBuffer = renderingData.cameraData.renderer.cameraColorTargetHandle;

        if (!setting.IsActive()) return;

        CommandBuffer cmd = CommandBufferPool.Get(profilerTag);
        cmd.Blit(source, mainTex);

        material.SetFloat("_Strength", setting.strength.value);

        cmd.Blit(mainTex, source, material);

        context.ExecuteCommandBuffer(cmd);
        cmd.Clear();
        CommandBufferPool.Release(cmd);
    }

    public override void FrameCleanup(CommandBuffer cmd)
    {
        cmd.ReleaseTemporaryRT(Shader.PropertyToID("_MainTex"));
    }
}
