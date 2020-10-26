using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShaderFeatureButton : MonoBehaviour
{
    public GameObject gameObject;
    public Renderer renderer;
    private Material mat;
    private bool key1;
    private bool key2;
    public Text text;
    public void OnClick()
    {
        mat = renderer.material;
        key1 = !key1;
        foreach (var keyword in mat.shaderKeywords)
        {
            Debug.Log(keyword);
        }
        
        Debug.Log(mat.IsKeywordEnabled("KEY1"));

        if (key1)
        {
            // text.tex = "key1";
            Debug.Log("key1 enable");
            
            mat.EnableKeyword("KEY1");
            // mat.DisableKeyword("KEY2");
        }
        else
        {
            Debug.Log("key1 disable");
            mat.DisableKeyword("KEY1");
        }
    }
    
    public void OnClick2()
    {
        mat = renderer.material;
        mat.EnableKeyword("KEY2");
        key2 = !key2;
        if (key2)
        {
            mat.EnableKeyword("KEY2");
            mat.DisableKeyword("KEY1");
        }
        else
        {
            mat.DisableKeyword("KEY2");
        }
    }
}
