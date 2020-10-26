using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class TreeInfos
{
    public string terrainName;
    public List<TreeObjectInstance> trees;

    public TreeInfos(string name, List<TreeObjectInstance> trees)
    {
        terrainName = name;
        this.trees = trees;
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
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
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
    public float heightScale;
    public float widthScale;
    public int prototypeIndex;
    internal float temporaryDistance;
    
    public TreeObjectInstance(Vector3 Position, Vector3 Rotation, Vector3 Scale, int type)
    {
        this.Position = new Vector3Ser(Position);
        this.Rotation = new Vector3Ser(Rotation);
        this.Scale = new Vector3Ser(Scale);
        this.prototypeIndex = type;
    }
}