using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlantGrass : MonoBehaviour
{
    public Mesh grassMesh;

    public Material grassMat;

    public GameObject grass;
    List<List<Matrix4x4>> m44List = new List<List<Matrix4x4>>();

    public bool draw;

    public bool instance;
    // Start is called before the first frame update
    void Start()
    {
        // m44 = new List<Matrix4x4>();
        // m44.Clear();
        if (instance)
        {
            Instance();
        }
        else
        {
            DirectDraw();
        }

    }

    void DirectDraw()
    {
        for (int i = 0; i < 60000; i++)
        {
            var c = i % 150;
            var r = i / 150;
            var grassIns = Instantiate(grass);
            grassIns.transform.position = new Vector3(c, 0, r);
            grassIns.transform.rotation = Quaternion.Euler(Random.Range(-10, 10), Random.Range(-30, 30), 0);
            grassIns.transform.localScale = new Vector3(1, 1, 1);
        }
    }
    

    void Instance()
    {
        m44List = new List<List<Matrix4x4>>();
        m44List.Clear();
        for (int i = 0; i < 60000; i++)
        {
            var c = i % 150;
            var r = i / 150;
            var matrix4X4 = Matrix4x4.TRS(new Vector3(c, 0, r), Quaternion.Euler(Random.Range(-10,10), Random.Range(-30,30), 0), new Vector3(1, 1, 1));
            if (m44List.Count == 0)
            {
                List<Matrix4x4> m44 = new List<Matrix4x4>();
                m44.Add(matrix4X4);
                m44List.Add(m44);
            }
            else
            {
                var m44L = m44List[m44List.Count - 1];
                if (m44L.Count < 1023)
                {
                    m44L.Add(matrix4X4);
                }
                else
                {
                    List<Matrix4x4> m44 = new List<Matrix4x4>();
                    m44.Add(matrix4X4);
                    m44List.Add(m44);
                }
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (draw)
        {
            foreach (var m44 in m44List)
            {
                Graphics.DrawMeshInstanced(grassMesh, 0, grassMat, m44.ToArray());
                // Graphics.DrawMeshInstancedIndirect();
            }
        }
    }
}
