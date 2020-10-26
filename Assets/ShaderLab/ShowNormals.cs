using UnityEngine;

[ExecuteInEditMode]
public class ShowNormals : MonoBehaviour
{
    MeshFilter mf;
    Mesh mesh;
    Matrix4x4 localToWorld;
    //[Range(0, 1000)]
    public int ShowCount = 100;
    [Range(0, 10)]
    public float lineLength = 1;
    public bool showNormals = false;
    public bool showTangents = false;
    public bool showBitTangens = false;

    // Start is called before the first frame update
    void Start()
    {
        mf = gameObject.GetComponent<MeshFilter>();
    }

    // Update is called once per frame
    void Update()
    {
        localToWorld = gameObject.transform.localToWorldMatrix;

        mesh = mf.mesh;
        var vetex = mf.mesh.vertices;
        var normals = mf.mesh.normals;
        var tans = mf.mesh.tangents;
        Vector3[] tangents = new Vector3[tans.Length];
        Vector3[] bitangents = new Vector3[tans.Length];
        for (int i = 0; i < tans.Length; i++)
        {
            tangents[i].x = tans[i].x;
            tangents[i].y = tans[i].y;
            tangents[i].z = tans[i].z;
            bitangents[i] = Vector3.Cross(normals[i], tangents[i]) * tans[i].w;
        }
        if(showNormals) DrawLines(vetex, normals, localToWorld, localToWorld.inverse.transpose, Color.red);
        if (showTangents)
            DrawLines(vetex, tangents, localToWorld, localToWorld, Color.blue);
        if (showBitTangens)
            DrawLines(vetex, bitangents, localToWorld, localToWorld, Color.green);
    }

    void DrawLines(Vector3[] vectors, Vector3[] dirs, Matrix4x4 vertexMatrix, Matrix4x4 dirMatrix, Color color)
    {
        for (int i = 0; i < vectors.Length && i < ShowCount; i++)
        {
            var vertexData = vertexMatrix.MultiplyPoint(vectors[i]);
            var dirData = dirMatrix.MultiplyVector(dirs[i]);
            dirData.Normalize();
            Debug.DrawLine(vertexData, vertexData + dirData * lineLength, color);
            Debug.DrawLine(vertexData, vertexData + dirData * lineLength, color);
        }
    }
}
