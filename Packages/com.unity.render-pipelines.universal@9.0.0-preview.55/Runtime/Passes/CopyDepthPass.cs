using System;
using UnityEditor;

namespace UnityEngine.Rendering.Universal.Internal
{
    /// <summary>
    /// Copy the given depth buffer into the given destination depth buffer.
    ///
    /// You can use this pass to copy a depth buffer to a destination,
    /// so you can use it later in rendering. If the source texture has MSAA
    /// enabled, the pass uses a custom MSAA resolve. If the source texture
    /// does not have MSAA enabled, the pass uses a Blit or a Copy Texture
    /// operation, depending on what the current platform supports.
    /// </summary>
    public class CopyDepthPass : ScriptableRenderPass
    {
        private RenderTargetHandle source { get; set; }
        private RenderTargetHandle destination { get; set; }
        internal bool AllocateRT  { get; set; }
        Material m_CopyDepthMaterial;
        const string m_ProfilerTag = "Copy Depth";
        private static readonly ProfilingSampler m_ProfilingSampler = new ProfilingSampler(m_ProfilerTag);

        int m_ScaleBiasId = Shader.PropertyToID("_ScaleBiasRT");

        public CopyDepthPass(RenderPassEvent evt, Material copyDepthMaterial)
        {
            AllocateRT = true;
            m_CopyDepthMaterial = copyDepthMaterial;
            renderPassEvent = evt;
        }
        private RenderTargetHandle outlineRTH { get; set; }
        private Material blitMat;
        private bool outlineRT { get; set; }
        /// <summary>
        /// Configure the pass with the source and destination to execute on.
        /// </summary>
        /// <param name="source">Source Render Target</param>
        /// <param name="destination">Destination Render Targt</param>
        public void Setup(RenderTargetHandle source, RenderTargetHandle destination, bool outline = false)
        {
            this.source = source;
            this.destination = destination;
            PersistentRenderTexture.Init();
            this.outlineRT = outline;
            this.outlineRTH.Init("_MaskDepthTexture");
            this.blitMat = AssetDatabase.LoadAssetAtPath<Material>("Assets/ShaderLab/9.Outline/_aterial.mat");

        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
            base.Configure(cmd, cameraTextureDescriptor);
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var descriptor = renderingData.cameraData.cameraTargetDescriptor;
            descriptor.colorFormat = RenderTextureFormat.Depth;
            descriptor.depthBufferBits = 32; //TODO: do we really need this. double check;
            descriptor.msaaSamples = 1;
            if (this.AllocateRT)
                cmd.GetTemporaryRT(destination.id, descriptor, FilterMode.Point);

            // On Metal iOS, prevent camera attachments to be bound and cleared during this pass.
            ConfigureTarget(destination.Identifier());
            ConfigureClear(ClearFlag.None, Color.black);
        }

        /// <inheritdoc/>
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (m_CopyDepthMaterial == null)
            {
                Debug.LogErrorFormat("Missing {0}. {1} render pass will not execute. Check for missing reference in the renderer resources.", m_CopyDepthMaterial, GetType().Name);
                return;
            }

            CommandBuffer cmd = CommandBufferPool.Get();
            using (new ProfilingScope(cmd, m_ProfilingSampler))
            {
                RenderTargetIdentifier depthSurface = source.Identifier();
                RenderTargetIdentifier copyDepthSurface = destination.Identifier();

                RenderTextureDescriptor descriptor = renderingData.cameraData.cameraTargetDescriptor;
                int cameraSamples = descriptor.msaaSamples;

                CameraData cameraData = renderingData.cameraData;

                switch (cameraSamples)
                {
                    case 8:
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa2);
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa4);
                        cmd.EnableShaderKeyword(ShaderKeywordStrings.DepthMsaa8);
                        break;

                    case 4:
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa2);
                        cmd.EnableShaderKeyword(ShaderKeywordStrings.DepthMsaa4);
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa8);
                        break;

                    case 2:
                        cmd.EnableShaderKeyword(ShaderKeywordStrings.DepthMsaa2);
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa4);
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa8);
                        break;

                    // MSAA disabled
                    default:
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa2);
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa4);
                        cmd.DisableShaderKeyword(ShaderKeywordStrings.DepthMsaa8);
                        break;
                }

                // if (outlineRT)
                // {
                //     cmd.GetTemporaryRT(Shader.PropertyToID("_MaskDepthTexture"), descriptor, FilterMode.Point);
                //     Blit(cmd, source.Identifier(), outlineRTH.Identifier(), blitMat);
                //     cmd.SetGlobalTexture("_MaskTexture", outlineRTH.Identifier());
                //     cmd.SetGlobalTexture("_MaskDepthTexture", outlineRTH.Identifier());
                //     // Blit(cmd, source.Identifier(),  PersistentRenderTexture.outlineRTH.Identifier(), blitMat);
                //     // cmd.SetGlobalTexture("_MaskTexture", PersistentRenderTexture.outlineRTH.Identifier());
                //     // cmd.SetGlobalTexture("_MaskDepthTexture", PersistentRenderTexture.outlineRTH.Identifier());
                // }
                // else
                {
                    cmd.SetGlobalTexture("_CameraDepthAttachment", source.Identifier());
                }

                // Blit has logic to flip projection matrix when rendering to render texture.
                // Currently the y-flip is handled in CopyDepthPass.hlsl by checking _ProjectionParams.x
                // If you replace this Blit with a Draw* that sets projection matrix double check
                // to also update shader.
                // scaleBias.x = flipSign
                // scaleBias.y = scale
                // scaleBias.z = bias
                // scaleBias.w = unused
                float flipSign = (cameraData.IsCameraProjectionMatrixFlipped()) ? -1.0f : 1.0f;
                Vector4 scaleBias = (flipSign < 0.0f)
                    ? new Vector4(flipSign, 1.0f, -1.0f, 1.0f)
                    : new Vector4(flipSign, 0.0f, 1.0f, 1.0f);
                cmd.SetGlobalVector(m_ScaleBiasId, scaleBias);

                cmd.DrawMesh(RenderingUtils.fullscreenMesh, Matrix4x4.identity, m_CopyDepthMaterial);
            }

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        /// <inheritdoc/>
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
            if (cmd == null)
                throw new ArgumentNullException("cmd");

            if (this.AllocateRT)
                cmd.ReleaseTemporaryRT(destination.id);
            destination = RenderTargetHandle.CameraTarget;
        }
    }
}
