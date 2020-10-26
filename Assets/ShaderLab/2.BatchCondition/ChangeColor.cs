using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ChangeColor : MonoBehaviour
{
    public GameObject cube;
    public GameObject sphere;

    public static ChangeColor instance;

    private static readonly int color = Shader.PropertyToID("_Color");

    // Start is called before the first frame update
    void Start()
    {
        instance = this;
    }

    private void OnEnable()
    {
        instance = this;
    }
#if UNITY_EDITOR
    [MenuItem("Batching/1.ChangeColor/material/Cube")]
    public static void ChangeColorCube()
    {
        var mat = instance.cube.GetComponent<Renderer>().material;
        mat.SetColor(color, Color.blue);
    }
    [MenuItem("Batching/1.ChangeColor/material/Sphere")]
    public static void ChangeColorSphere()
    {
        var mat = instance.sphere.GetComponent<Renderer>().material;
        mat.SetColor(color, Color.red);
    }
    
    [MenuItem("Batching/1.ChangeColor/Shaderedmaterial/Cube")]
    public static void ChangeColorCubeShaderedmaterial()
    {
        var mat = instance.cube.GetComponent<Renderer>().sharedMaterial;
        mat.SetColor(color, Color.green);
    }
    [MenuItem("Batching/1.ChangeColor/Shaderedmaterial/Sphere")]
    public static void ChangeColorSphereShaderedmaterial()
    {
        var mat = instance.sphere.GetComponent<Renderer>().sharedMaterial;
        mat.SetColor(color, Color.yellow);
    }
    
    [MenuItem("Batching/1.ChangeColor/Property/Cube")]
    public static void ChangeColorCubeProperty()
    {
        MaterialPropertyBlock prop = new MaterialPropertyBlock();
        prop.SetColor(color, Color.magenta);
        var renderer = instance.cube.GetComponent<Renderer>();
        renderer.SetPropertyBlock(prop);
    }
    [MenuItem("Batching/1.ChangeColor/Property/Sphere")]
    public static void ChangeColorSphereProperty()
    {
        MaterialPropertyBlock prop = new MaterialPropertyBlock();
        prop.SetColor(color, Color.cyan);
        var renderer = instance.sphere.GetComponent<Renderer>();
        renderer.SetPropertyBlock(prop);
    }
#endif
}
