using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEditor;
using UnityEngine;

public class SerializeTerrainObjectData : MonoBehaviour
{

    public Material mat;
    // Start is called before the first frame update
    [MenuItem("Grass/Bake Terrain Objects Data")]
    public static void BakeGrassData()
    {
        try
        {
            var ters =  FindObjectsOfType<Terrain>();
        
            if (!CheckFBXSingleMesh(ters))
            {
                return;
            }
        
            var list = new List<TerrainTreeInfos>();
            foreach (var terrain in ters)
            {
                List<TreeObjectInstance> treeObjectInstances = new List<TreeObjectInstance>();

                var trees = terrain.terrainData.treeInstances;
                foreach (var treeInstance in trees)
                {
                    var pos = terrain.transform.TransformPoint(new Vector3(
                        treeInstance.position.x * terrain.terrainData.size.x,
                        treeInstance.position.y * terrain.terrainData.size.y,
                        treeInstance.position.z * terrain.terrainData.size.z));
                    var data = new TreeObjectInstance(pos,
                        new Vector3(0, treeInstance.rotation, 0), 
                        new Vector3(treeInstance.widthScale, treeInstance.heightScale, treeInstance.widthScale), treeInstance.prototypeIndex);
                    treeObjectInstances.Add(data);
                }
            
                // var meshPaths = terrain.terrainData.treePrototypes.Select(m=>Path.GetFileNameWithoutExtension((AssetDatabase.GetAssetPath(m.prefab.GetComponent<MeshFilter>().sharedMesh)))).ToList();
                var meshPaths = terrain.terrainData.treePrototypes.Select(m => m.prefab.name).ToList();
                TerrainTreeInfos ti = new TerrainTreeInfos(terrain.name, treeObjectInstances, meshPaths);
                list.Add(ti);
            }


            Stream fStream = new FileStream("Assets/Res/Resources/ConceptDemo/Grass/Resources/GrassTransforms.bytes", FileMode.Create, FileAccess.ReadWrite);
            BinaryFormatter bf = new BinaryFormatter();
            MemoryStream ms = new MemoryStream();
            bf.Serialize(fStream, list);
            fStream.Close();
            
            Debug.Log("缓存草信息完成");
            AssetDatabase.Refresh();
        }
        catch (Exception e)
        {
            
            Debug.LogError("缓存草信息发生错误");
            throw;
        }

    }

    
    //     [MenuItem("Grass/Bake Terrain Objects Data")]
    // public static void BakeGrassData()
    // {
    //     var terrains =  FindObjectsOfType<Terrain>();
    //     
    //     if (!CheckFBXSingleMesh(terrains))
    //     {
    //         return;
    //     }
    //     
    //     var list = new List<TerrainTreeInfos>();
    //     foreach (var terrain in terrains)
    //     {
    //         
    //         for (var index = 0; index < terrain.terrainData.treePrototypes.Length; index++)
    //         {
    //             var terrainDataTreePrototype = terrain.terrainData.treePrototypes[index];
    //             var trees = terrain.terrainData.treeInstances;
    //             List<TreeObjectInstance> treeObjectInstances = new List<TreeObjectInstance>();
    //
    //
    //             foreach (var treeInstance in trees)
    //             {
    //                 if (treeInstance.prototypeIndex == index)
    //                 {
    //                     var pos = terrain.transform.TransformPoint(new Vector3(
    //                         treeInstance.position.x * terrain.terrainData.size.x,
    //                         treeInstance.position.y * terrain.terrainData.size.y,
    //                         treeInstance.position.z * terrain.terrainData.size.z));
    //                     var data = new TreeObjectInstance(pos,
    //                         new Vector3(0, treeInstance.rotation, 0),
    //                         new Vector3(treeInstance.widthScale, treeInstance.heightScale, treeInstance.widthScale),
    //                         treeInstance.prototypeIndex);
    //                     treeObjectInstances.Add(data);
    //                 }
    //             }
    //
    //             var meshPaths = terrain.terrainData.treePrototypes.Select(m =>
    //                 Path.GetFileNameWithoutExtension(
    //                     (AssetDatabase.GetAssetPath(m.prefab.GetComponent<MeshFilter>().sharedMesh)))).ToList();
    //             TerrainTreeInfos ti = new TerrainTreeInfos(terrain.name, treeObjectInstances, meshPaths);
    //             list.Add(ti);
    //         }
    //     }
    //
    //
    //     Stream fStream = new FileStream("Assets/Res/Resources/ConceptDemo/Grass/Resources/GrassTransforms.bytes", FileMode.Create, FileAccess.ReadWrite);
    //     BinaryFormatter bf = new BinaryFormatter();
    //     MemoryStream ms = new MemoryStream();
    //     bf.Serialize(fStream, list);
    //     fStream.Close();
    // }
    

    public static bool CheckFBXSingleMesh(Terrain[] terrains)
    {
        // var ters =  FindObjectsOfType<Terrain>();
        foreach (var terrain in terrains)
        {
            foreach (var terrainDataTreePrototype in terrain.terrainData.treePrototypes)
            {
                if (terrainDataTreePrototype.prefab.GetComponentsInChildren<MeshFilter>().Length > 1)
                {
                    EditorUtility.DisplayDialog("错误", "地形树笔刷中存在含有多个网格的FBX, 应该使用只有一个Mesh的FBX文件, 操作中止...", "确定");
                    return false;
                }

                if (AssetDatabase.FindAssets("t:material " + terrainDataTreePrototype.prefab.name, new []{"Assets"}).Length == 0)
                {
                    EditorUtility.DisplayDialog("错误", "不存在与地形树笔刷同名的材质球, 操作中止...", "确定");
                    return false;
                }
            }
        }

        return true;
    }
    

    [MenuItem("Grass/Delete Terrain Objects")]
    public static void DeleteTerrainObjects()
    {
        var ters =  FindObjectsOfType<Terrain>();
        var list = new List<TreeInstance>();
        foreach (var terrain in ters)
        {
            terrain.terrainData.SetTreeInstances(list.ToArray(), false);
        }
    }
    
    [MenuItem("Grass/Load Terrain Objects")]
    public static void LoadTerrainObjects()
    {
        var fAsset = Resources.Load(DrawGrass.fileName) as TextAsset;
        var buffer = fAsset.bytes;
        Stream s = new MemoryStream(buffer);
        BinaryFormatter bf = new BinaryFormatter();
        List<TerrainTreeInfos> treeInfos = (List<TerrainTreeInfos>) bf.Deserialize(s);
        s.Close();
        
        var ters =  FindObjectsOfType<Terrain>();

        foreach (var terrain in ters)
        {
            foreach (var treeInfo in treeInfos)
            {
                if (terrain.name == treeInfo.terrainName)
                {
                    var list = new List<TreeInstance>();
                    foreach (var treeObjectInstance in treeInfo.trees)
                    {
                        TreeInstance ti = new TreeInstance();
                        var pos = terrain.transform.InverseTransformPoint(new Vector3(treeObjectInstance.Position.x, treeObjectInstance.Position.y,
                            treeObjectInstance.Position.z));
                        var terrainData = terrain.terrainData;
                        pos.x /= terrainData.size.x;
                        pos.y /= terrainData.size.y;
                        pos.z /= terrainData.size.z;
                        ti.position =  pos;
                        
                        ti.rotation = treeObjectInstance.Rotation.y;
                        ti.heightScale = treeObjectInstance.Scale.y;
                        ti.widthScale = treeObjectInstance.Scale.x;
                        ti.prototypeIndex = treeObjectInstance.prototypeIndex;
                        ti.color = Color.red;
                        list.Add(ti);
                    }
                    terrain.terrainData.treeInstances = list.ToArray();
                }
            }
        }
    }
}


[Serializable]
public class DetailedObjectInstance
 {
     [SerializeField]
     // public GameObject Prefab;
     public Vector3Ser Position;
     [SerializeField]
     public Vector3Ser Rotation;
     [SerializeField]
     public Vector3Ser Scale;
 
     public static DetailedObjectInstance[] ExportObjects(Terrain terrain)
     {
 
         List<DetailedObjectInstance> output = new List<DetailedObjectInstance>();
 
         TerrainData data = terrain.terrainData;
         var a = data.treeInstances;
         
         if (terrain.detailObjectDensity != 0)
         {
 
             int detailWidth = data.detailWidth;
             int detailHeight = data.detailHeight;
 
 
             float delatilWToTerrainW = data.size.x / detailWidth;
             float delatilHToTerrainW = data.size.z / detailHeight;
 
             Vector3 mapPosition = terrain.transform.position;
 
             bool doDentisy = false;
             float targetDentisty = 0;
             if (terrain.detailObjectDensity != 1)
             {
                 targetDentisty = (1 / (1f - terrain.detailObjectDensity));
                 doDentisy = true;
             }
 
 
             float currentDentity = 0;
 
             DetailPrototype[] details = data.detailPrototypes;
             
             for (int i = 0; i < details.Length; i++)
             {
                 // GameObject Prefab = details[i].prototype;
                 //details[i].prototype.GetComponent<Renderer>().material = null;
                 float minWidth = details[i].minWidth;
                 float maxWidth = details[i].maxWidth;
 
                 float minHeight = details[i].minHeight;
                 float maxHeight = details[i].maxHeight;
 
                 int[,] map = data.GetDetailLayer(0, 0, data.detailWidth, data.detailHeight, 0);
                
                 List<Vector3> grasses = new List<Vector3>();
                 for (var y = 0; y < data.detailHeight; y++)
                 {
                     for (var x = 0; x < data.detailWidth; x++)
                     {
                         if (map[x, y] > 0)
                         {
                             currentDentity += 1f;
 
 
                             bool pass = false;
                             if (!doDentisy)
                                 pass = true;
                             else
                                 pass = currentDentity < targetDentisty;
 
                             if (pass)
                             {
                                 float _z = (x * delatilWToTerrainW) + mapPosition.z;
                                 float _x = (y * delatilHToTerrainW) + mapPosition.x;
                                 float _y = terrain.SampleHeight(new Vector3(_x, 0, _z));
                                 grasses.Add(new Vector3(
                                     _x,
                                     _y,
                                     _z
                                     ));
                             }
                             else
                             {
                                 currentDentity -= targetDentisty;
                             }
 
                         }
                     }
                 }
 
                 foreach (var item in grasses)
                 {
                     DetailedObjectInstance e = new DetailedObjectInstance();
                     // e.Prefab = Prefab;
                     var pos = terrain.transform.TransformPoint(item);
                     e.Position = new Vector3Ser(pos.x,pos.y,pos.z);
                     e.Rotation = new Vector3Ser(0, UnityEngine.Random.Range(0, 360), 0);
                     e.Scale = new Vector3Ser(UnityEngine.Random.Range(minWidth, maxWidth), UnityEngine.Random.Range(minHeight, maxHeight), UnityEngine.Random.Range(minWidth, maxWidth));
 
                     output.Add(e);
                 }
             }
         }
 
 
         return output.ToArray();
     }
 }