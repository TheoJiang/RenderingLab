using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Scripting.APIUpdating;

// namespace UnityEngine.Experimental.Rendering.Universal
// {
    [MovedFrom("UnityEngine.Experimental.Rendering.LWRP")]public enum RenderQueueType
    {
        Opaque,
        Transparent,
    }

    [MovedFrom("UnityEngine.Experimental.Rendering.LWRP")]public class PPMaskFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class PPMaskFeatureSettings
        {
            public string passTag = "RenderObjectsFeature";
            public RenderPassEvent Event = RenderPassEvent.AfterRenderingOpaques;

            public FilterSettings filterSettings = new FilterSettings();

            public Material overrideMaterial = null;
            public int overrideMaterialPassIndex = 0;

            public bool overrideDepthState = false;
            public CompareFunction depthCompareFunction = CompareFunction.LessEqual;
            public bool enableWrite = true;

            public StencilStateData stencilSettings = new StencilStateData();

            public CustomCameraSettings cameraSettings = new CustomCameraSettings();
        }

        [System.Serializable]
        public class FilterSettings
        {
            // TODO: expose opaque, transparent, all ranges as drop down
            public RenderQueueType RenderQueueType;
            public LayerMask LayerMask;
            public string[] PassNames;

            public FilterSettings()
            {
                RenderQueueType = RenderQueueType.Opaque;
                LayerMask = 0;
            }
        }

        [System.Serializable]
        public class CustomCameraSettings
        {
            public bool overrideCamera = false;
            public bool restoreCamera = true;
            public Vector4 offset;
            public float cameraFieldOfView = 60.0f;
        }

        public PPMaskFeatureSettings settings = new PPMaskFeatureSettings();

        PPMaskFeaturePass ppmaskFeaturePass;
        private Camera ppCamera;
        public override void Create()
        {
            FilterSettings filter = settings.filterSettings;
            ppmaskFeaturePass = new PPMaskFeaturePass(settings.passTag, settings.Event, filter.PassNames,
                filter.RenderQueueType, filter.LayerMask, settings.cameraSettings);

            ppmaskFeaturePass.overrideMaterial = settings.overrideMaterial;
            ppmaskFeaturePass.overrideMaterialPassIndex = settings.overrideMaterialPassIndex;

            if (settings.overrideDepthState)
                ppmaskFeaturePass.SetDetphState(settings.enableWrite, settings.depthCompareFunction);

            if (settings.stencilSettings.overrideStencilState)
                ppmaskFeaturePass.SetStencilState(settings.stencilSettings.stencilReference,
                    settings.stencilSettings.stencilCompareFunction, settings.stencilSettings.passOperation,
                    settings.stencilSettings.failOperation, settings.stencilSettings.zFailOperation);

            var rtcameraObj = GameObject.Find("RTCamera");
            if (rtcameraObj)
            {
                ppCamera = rtcameraObj.GetComponent<Camera>();
                var rt = RenderTexture.GetTemporary(ppCamera.pixelWidth, ppCamera.pixelHeight, 24);
                rt.useDynamicScale = true;
                ppCamera.targetTexture = rt;
            }
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            var ca = renderingData.cameraData.camera;
            if (!ca.name.Contains("RTCamera"))
            {
                return;
            }

            renderer.EnqueuePass(ppmaskFeaturePass);
        }
    }
// }

