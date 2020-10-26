using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoadURPShaderBundle : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        var bundle = AssetBundle.LoadFromFile("Assets/StreamingAssets/urpshaderbundle");
        var cube = bundle.LoadAsset<GameObject>("Assets/ShaderLab/4.URPShaderBundleTest/URPShaderBundleTest/Cube.prefab");
        var cubeObj = Instantiate(cube);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
