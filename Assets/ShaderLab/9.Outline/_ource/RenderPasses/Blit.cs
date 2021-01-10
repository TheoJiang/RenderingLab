using UnityEngine;
using UnityEngine.Rendering.Universal;

public class Blit : ScriptableRendererFeature {
    [System.Serializable]
    public class Settings {
        public RenderPassEvent Event = RenderPassEvent.AfterRenderingOpaques;
        
        public Material blitMaterial = null;
        public int blitMaterialPassIndex = -1;
        public Target destination = Target.Color;
        [Header("Just As Name")]
        public string textureId = "_BlitPassTexture";
    }
    
    public enum Target {
        Color,
        Texture
    }

    public Settings settings = new Settings();
    RenderTargetHandle m_RenderTextureHandle;

    BlitPass blitPass;

    public override void Create() {
        // 
        var passIndex = settings.blitMaterial != null ? settings.blitMaterial.passCount - 1 : 1;
        settings.blitMaterialPassIndex = Mathf.Clamp(settings.blitMaterialPassIndex, -1, passIndex);
        blitPass = new BlitPass(settings.Event, settings.blitMaterial, settings.blitMaterialPassIndex, name);
        m_RenderTextureHandle.Init(settings.textureId);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // renderingData.cameraData.camera.Render();
        // var feature = renderer.rendererFeatures[3] as Blit;
        // var ca = GameObject.Find("RTCamera");
        // if (ca)
        // {
        //     var came = ca.GetComponent<Camera>();
        //     came.enabled = true;
        //     if (came)
        //     {
        //         var ppcameraRT = came.targetTexture;
        //         blitPass.blitMaterial.SetTexture("_MaskTexture", ppcameraRT);
        //         
        //     }
        //     came.Render();
        //     came.enabled = false;
        //
        // }
        
        // UniversalRenderPipeline.asset.GetRenderer(0);
        // Camera camera = renderingData.cameraData.camera;
        // if (!camera.name.Contains("RTCamera"))
        // {
        //     return;
        // }
        var src = renderer.cameraColorTarget;
        var dest = (settings.destination == Target.Color) ? RenderTargetHandle.CameraTarget : m_RenderTextureHandle;

        if (settings.blitMaterial == null) {
            Debug.LogWarningFormat("Missing Blit Material. {0} blit pass will not execute. Check for missing reference in the assigned renderer.", GetType().Name);
            return;
        }

        blitPass.Setup(src, dest);
        renderer.EnqueuePass(blitPass);
    }
}