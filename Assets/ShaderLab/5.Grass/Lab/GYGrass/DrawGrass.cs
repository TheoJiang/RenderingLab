using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;

public class DrawGrass : MonoBehaviour
{
    public static string fileName = @"Assets/ShaderLab/5.Grass/Lab/GYGrass/GrassTransforms.data";//文件名称与路径
    
    public Mesh grassBodyMesh;
    public Material grassBodyMat;
    public Mesh grassTopMesh;
    public Material grassTopmat;

    // Start is called before the first frame update
    void Start()
    {
        InitGrassData();
    }

    private void OnEnable()
    {
        InitGrassData();
    }

    List<List<Matrix4x4>> grassBodyMatrix4x4Infos = new List<List<Matrix4x4>>();
    List<List<Matrix4x4>> grassTopMatrix4x4Infos = new List<List<Matrix4x4>>();

    void InitGrassData()
    {
        var f = File.Open(fileName, FileMode.Open);
        BinaryFormatter bf = new BinaryFormatter();
        List<TreeInfos> treeInfos = (List<TreeInfos>) bf.Deserialize(f);
        
        f.Close();
        grassBodyMatrix4x4Infos.Clear();
        grassTopMatrix4x4Infos.Clear();
        List<Matrix4x4> matrix4X4sBody = new List<Matrix4x4>();
        List<Matrix4x4> matrix4X4sDot = new List<Matrix4x4>();
        
        
        foreach (var treeInfo in treeInfos)
        {
            foreach (var treeObjectInstance in treeInfo.trees)
            {
                var detailedObjectInstance = treeObjectInstance;
        
                if (matrix4X4sBody.Count % 1023 == 0 && detailedObjectInstance.prototypeIndex == 0)
                {
                    matrix4X4sBody = new List<Matrix4x4>();
                    grassBodyMatrix4x4Infos.Add(matrix4X4sBody);
                }
                if (matrix4X4sDot.Count % 1023 == 0 && detailedObjectInstance.prototypeIndex == 1)
                {
                    matrix4X4sDot = new List<Matrix4x4>();
                    grassTopMatrix4x4Infos.Add(matrix4X4sDot);
                }
        
                var p = new Vector3(detailedObjectInstance.Position.x, detailedObjectInstance.Position.y + 0.1f,
                    detailedObjectInstance.Position.z);
                var r = new Vector3(detailedObjectInstance.Rotation.x, detailedObjectInstance.Rotation.y,
                    detailedObjectInstance.Rotation.z);
                var s = new Vector3(detailedObjectInstance.Scale.x, detailedObjectInstance.Scale.y,
                    detailedObjectInstance.Scale.z);
                //new Vector3(0.01f,0.01f,0.01f)
                if (detailedObjectInstance.prototypeIndex == 0)
                {
                    var matrix4X4 = Matrix4x4.TRS(p, Quaternion.Euler(Vector3.zero), Vector3.one);
                    matrix4X4sBody.Add(matrix4X4);
                }
                if (detailedObjectInstance.prototypeIndex == 1)
                {
                    var matrix4X4 = Matrix4x4.TRS(p, Quaternion.Euler(Vector3.zero), Vector3.one);
                    matrix4X4sDot.Add(matrix4X4);
                }
            }
        }
    }


    // Update is called once per frame
    void Update()
    {
        foreach (var ma in grassBodyMatrix4x4Infos)
        {
            Graphics.DrawMeshInstanced(grassBodyMesh, 0, grassBodyMat, ma);
        }
        
        foreach (var ma in grassTopMatrix4x4Infos)
        {
            Graphics.DrawMeshInstanced(grassTopMesh, 0, grassTopmat, ma);
        }
    }
}
