using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class TerrainTreeInfos
{
    public string terrainName;
    // 在Index, 路径,GUID和文件名标记中, 最终选择了文件名.
    // 避免文件GUID丢失,以及美术不慎造成的Index排序混乱.
    public List<string> grassNames;
    public List<TreeObjectInstance> trees;

    public TerrainTreeInfos(string name, List<TreeObjectInstance> treeInfos, List<string> names)
    {
        terrainName = name;
        // this.prototypeIndex = prototypeIndex;
        trees = treeInfos;
        grassNames = names;
    }
}

[System.Serializable]
public class Vector3Ser
{
    public float x,y,z;

    public Vector3Ser(float x, float y, float z)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    public Vector3Ser(Vector3 v)
    {
        x = v.x;
        y = v.y;
        z = v.z;
    }
}


[Serializable]
public class TreeObjectInstance
{
    [SerializeField]
    // public GameObject Prefab;
    public Vector3Ser Position;
    [SerializeField]
    public Vector3Ser Rotation;
    [SerializeField]
    public Vector3Ser Scale;
    public int prototypeIndex;
    
    public TreeObjectInstance(Vector3 Position, Vector3 Rotation, Vector3 Scale, int type)
    {
        this.Position = new Vector3Ser(Position);
        this.Rotation = new Vector3Ser(Rotation);
        this.Scale = new Vector3Ser(Scale);
        this.prototypeIndex = type;
    }
}