using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateRT : MonoBehaviour
{
    private Camera rtc;
    // Start is called before the first frame update
    void Start()
    {
        rtc = GetComponent<Camera>();

    }

    // Update is called once per frame
    void Update()
    {
        rtc.enabled = true;
        var currentRT = RenderTexture.active;

        RenderTexture.active = rtc.targetTexture;
        
        rtc.Render();
        Shader.SetGlobalTexture("_MaskTexture", RenderTexture.active);

        RenderTexture.active = currentRT;
        
        rtc.enabled = false;
    }
}
