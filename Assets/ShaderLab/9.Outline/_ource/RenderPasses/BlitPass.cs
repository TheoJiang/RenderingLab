using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// Copy the given color buffer to the given destination color buffer.
///
/// You can use this pass to copy a color buffer to the destination,
/// so you can use it later in rendering. For example, you can copy
/// the opaque texture to use it for distortion effects.
/// </summary>
class BlitPass : ScriptableRenderPass {
    public enum RenderTarget {
        Color,
        RenderTexture,
    }

    public Material blitMaterial = null;
    public int blitShaderPassIndex = 0;
    public FilterMode filterMode { get; set; }

    private RenderTargetIdentifier source { get; set; }
    private RenderTargetHandle destination { get; set; }

    RenderTargetHandle m_TemporaryColorTexture;
    string m_ProfilerTag;

    /// <summary>
    /// Create the CopyColorPass
    /// </summary>
    public BlitPass(RenderPassEvent renderPassEvent, Material blitMaterial, int blitShaderPassIndex, string tag) {
        this.renderPassEvent = renderPassEvent;
        this.blitMaterial = blitMaterial;
        this.blitShaderPassIndex = blitShaderPassIndex;
        m_ProfilerTag = tag;
        m_TemporaryColorTexture.Init("_TemporaryColorTexture");
    }

    /// <summary>
    /// Configure the pass with the source and destination to execute on.
    /// </summary>
    /// <param name="source">Source Render Target</param>
    /// <param name="destination">Destination Render Target</param>
    public void Setup(RenderTargetIdentifier source, RenderTargetHandle destination) {
        this.source = source;
        this.destination = destination;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
        // Camera camera = renderingData.cameraData.camera;
        // if (!camera.name.Contains("RTCamera"))
        // {
        //     return;
        // }

        CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);

        // var ca = renderingData.cameraData.camera;
        // // var ca = GameObject.Find("RTCamera");
        // if (ca.name.Contains("RTCamera"))
        // {
        //     
        //     var came = ca.GetComponent<Camera>();
        //     came.enabled = true;
        //     
        //     if (came)
        //     {
        //         // var pixelRect = came.pixelRect;
        //         // came.targetTexture.width = (int)pixelRect.width;
        //         // came.targetTexture.height = (int)pixelRect.height;
        //         //
        //         var currentRT = RenderTexture.active;
        //         RenderTexture.active = came.targetTexture;
        //         cmd.SetGlobalTexture("_MaskTexture", RenderTexture.active);
        //         RenderTexture.active = currentRT;
        //     }
        //
        //     // came.enabled = false;
        // }
        
        RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
        opaqueDesc.depthBufferBits = 0;
        opaqueDesc.msaaSamples = 1;

        // Can't read and write to same color target, create a temp render target to blit. 
        if (destination == RenderTargetHandle.CameraTarget) {
            cmd.GetTemporaryRT(m_TemporaryColorTexture.id, opaqueDesc, filterMode);
            // 将Source(当前Buffer） Blit至 tempColorTexture， 过程中经材质球对应处理
            // Shader.PropertyToID("_CameraColorTexture") == source.m_NameID == 1142
            Blit(cmd, source, m_TemporaryColorTexture.Identifier(), blitMaterial, blitShaderPassIndex);
            // 将处理后的rt传回
            Blit(cmd, m_TemporaryColorTexture.Identifier(), source);
        }
        else {
            Blit(cmd, source, destination.Identifier(), blitMaterial, blitShaderPassIndex);
        }
        
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
    
    public override void FrameCleanup(CommandBuffer cmd) {
        if (destination == RenderTargetHandle.CameraTarget) {
            cmd.ReleaseTemporaryRT(m_TemporaryColorTexture.id);
        }
    }
}