using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PersistentRenderTexture
{
    public static RenderTargetHandle outlineRTH { get; set; }
    public static Material blitMat;
    public static bool outlineRT { get; set; }
    
    public static void Init()
    {
        if (outlineRTH.id == 0)
        {
            outlineRTH.Init("_MaskDepthTexture");
            blitMat = AssetDatabase.LoadAssetAtPath<Material>("Assets/ShaderLab/9.Outline/_aterial.mat");
        }
    }


}
