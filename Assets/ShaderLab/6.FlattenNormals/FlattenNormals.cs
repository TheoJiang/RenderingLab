using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class FlattenNormals : MonoBehaviour
{
    private Mesh _mesh;
    // Start is called before the first frame update
    void Start()
    {
        _mesh = GetComponent<MeshFilter>().mesh;
        var normals = _mesh.normals;
        var tangents = _mesh.tangents;
        var vertices = _mesh.vertices.ToList();
        var verCount = _mesh.vertexCount;
        var triangles = _mesh.triangles;
        
        for (var index = 0; index < triangles.Length; index+=3)
        {
            var v1 = triangles[index];
            var v2 = triangles[index+1];
            var v3 = triangles[index+2];
            var vp1 = vertices[v1];
            var vp2 = vertices[v2];
            var vp3 = vertices[v3];
            //var newN = Vector3.Cross(vp2 - vp1, vp3 - vp1).normalized;
            var newN = Vector3.Cross(vp2 - vp1, vp3 - vp1).normalized;
            normals[v1] = newN;
            normals[v2] = newN;
            normals[v3] = newN;
            tangents[v1] = Vector3.Cross(vp1 - vp3, newN).normalized;
            tangents[v2] = Vector3.Cross(vp2 - vp1, newN).normalized;
            tangents[v3] = Vector3.Cross(vp3 - vp2, newN).normalized;
        }

        _mesh.normals = normals;
        _mesh.tangents = tangents;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
