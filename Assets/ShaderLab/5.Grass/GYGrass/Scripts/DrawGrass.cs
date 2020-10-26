using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;

public class DrawGrass : MonoBehaviour
{
    [Serializable]
    public class GrassTemplateInfo
    {
        public GameObject grassTemplate;
        public Material grassMat;
        public Vector3 scale = Vector3.one;
        public float yAxisOffset;
        [NonSerialized]
        public List<List<Matrix4x4>> grassMatrix4x4Infos;
        [NonSerialized]
        public Mesh mesh;
    }
    
    public static string fileName = @"GrassTransforms";//文件名称与路径

    public GrassTemplateInfo[] grassTemplates;

    void Start()
    {
        InitGrassData();
    }

    private void OnEnable()
    {
        InitGrassData();
    }

    void InitGrassData()
    {
        foreach (var grassTemplateInfo in grassTemplates)
        {
            if (grassTemplateInfo.grassMatrix4x4Infos != null)
            {
                grassTemplateInfo.grassMatrix4x4Infos.Clear();
            }
        }
        
        var fAsset = Resources.Load(DrawGrass.fileName) as TextAsset;
        var buffer = fAsset.bytes;
        Stream stream = new MemoryStream(buffer);
        BinaryFormatter bf = new BinaryFormatter();
        List<TerrainTreeInfos> terrainTreeInfos = (List<TerrainTreeInfos>) bf.Deserialize(stream);
        stream.Close();


        foreach (var treeInfo in terrainTreeInfos)
        {
            foreach (var grassTemplateInfo in grassTemplates)
            {
                
                grassTemplateInfo.mesh = grassTemplateInfo.grassTemplate.GetComponent<MeshFilter>().sharedMesh;
                if (grassTemplateInfo.grassMatrix4x4Infos == null)
                {
                    grassTemplateInfo.grassMatrix4x4Infos = new List<List<Matrix4x4>>();
                }
                
                List<Matrix4x4> grassMatrixs = new List<Matrix4x4>();

                foreach (var treeObjectInstance in treeInfo.trees)
                {
                    if (treeInfo.grassNames[treeObjectInstance.prototypeIndex] == grassTemplateInfo.grassMat.name)
                    {
                        if (grassMatrixs.Count % 1023 == 0)
                        {
                            grassMatrixs = new List<Matrix4x4>();
                            grassTemplateInfo.grassMatrix4x4Infos.Add(grassMatrixs);
                        }
                        
                        var p = new Vector3(treeObjectInstance.Position.x, treeObjectInstance.Position.y + grassTemplateInfo.yAxisOffset,
                            treeObjectInstance.Position.z);
                        var r = new Vector3(treeObjectInstance.Rotation.x, treeObjectInstance.Rotation.y,
                            treeObjectInstance.Rotation.z);
                        var s = new Vector3(treeObjectInstance.Scale.x, treeObjectInstance.Scale.y,
                            treeObjectInstance.Scale.z);

                        var matrix4X4 = Matrix4x4.TRS(p, Quaternion.Euler(Vector3.zero), grassTemplateInfo.scale);
                        grassMatrixs.Add(matrix4X4);
                    }
                }
            }
        }
    }


    // Update is called once per frame
    void Update()
    {
        foreach (var grassTemplateInfo in grassTemplates)
        {
            foreach (var grassMatrix4X4Info in grassTemplateInfo.grassMatrix4x4Infos)
            {
                Graphics.DrawMeshInstanced(grassTemplateInfo.mesh, 0, grassTemplateInfo.grassMat, grassMatrix4X4Info);

            }

        }
    }
}
