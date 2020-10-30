using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CombineGroundTex : MonoBehaviour
{
    // public static Texture2D groundTex;
    // Start is called before the first frame update
    void Start()
    {
        var mat = this.GetComponent<Renderer>().sharedMaterial;
        List<string> names = new List<string>();
        mat.GetTexturePropertyNames(names);
        var _Control = mat.GetTexture("_Control") as Texture2D;
        var _Splat0 = mat.GetTexture("_Splat0") as Texture2D;
        var _Splat1 = mat.GetTexture("_Splat1") as Texture2D;
        var _Splat2 = mat.GetTexture("_Splat2") as Texture2D;
        var _Splat3 = mat.GetTexture("_Splat3") as Texture2D;
        
        Texture2D texture = new Texture2D(_Control.width, _Control.height);
        for (int i = 0; i < texture.width; i++)
        {
            for (int j = 0; j < texture.height; j++)
            {
                var color = _Control.GetPixel(i, j);
                var colorRes = (color.r * _Splat0.GetPixel(i, j) + color.g * _Splat1.GetPixel(i, j) +
                              color.b * _Splat2.GetPixel(i, j) +
                              color.a * _Splat0.GetPixel(i, j)) / (color.r + color.g + color.b + color.a);
                texture.SetPixel(i, j, colorRes);
            }
        }
        texture.Apply();
        // groundTex = texture;
        Shader.SetGlobalTexture("_GroundTexture", texture);
        // var renderer = GameObject.Find("Cube").GetComponent<Renderer>();
        // renderer.sharedMaterial.SetTexture("_GroundTexture", groundTex);
        // renderer.sharedMaterial.SetVector("_GroundPosition", this.);
        // mat.SetTexture("_Normal3", texture);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
