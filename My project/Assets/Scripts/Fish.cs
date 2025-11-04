using Unity.Mathematics;
using UnityEngine;

public class Fish : MonoBehaviour
{
    public ComputeShader computeShader;

    public Mesh FishMesh;
    public Material material;

    public float scale = 0.1f;
    public Vector2 minMaxBladeHeight = new Vector2(0.5f, 1.5f);

    private GraphicsBuffer transformMatrixBuffer;

    private GraphicsBuffer FishMeshVertexBuffer;
    private GraphicsBuffer FishMeshUVBuffer;
    private GraphicsBuffer FishMeshTriangleBuffer;

    private Bounds bounds;

    private int kernel;
    private uint threadGroupSize;
    private int terrainTriangleCount = 0;

    private void Start()
    {
        kernel = computeShader.FindKernel("FishComputeShader");


        // Grass data for RenderPrimitives.
        Vector3[] FishMeshVertices = FishMesh.vertices;
        FishMeshVertexBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, FishMeshVertices.Length, sizeof(float) * 3);
        FishMeshVertexBuffer.SetData(FishMeshVertices);

        Vector2[] FishMeshUVs = FishMesh.uv;
        FishMeshUVBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, FishMeshUVs.Length, sizeof(float) * 2);
        FishMeshUVBuffer.SetData(FishMeshUVs);

        int[] FishMeshTriangles = FishMesh.triangles;
        FishMeshTriangleBuffer = new GraphicsBuffer(GraphicsBuffer.Target.Structured, FishMeshTriangles.Length, sizeof(int));
        FishMeshTriangleBuffer.SetData(FishMeshTriangles);
        terrainTriangleCount = FishMeshTriangles.Length / 3;
        Debug.Log($"Triangle {terrainTriangleCount}");
        computeShader.SetVector("_TransformMatrices", transform.position);

        // Set bounds.
        bounds = FishMesh.bounds;
        bounds.center += transform.position;
        bounds.Expand(minMaxBladeHeight.y);

        RunComputeShader();
    }

    private void RunComputeShader()
    {
        computeShader.SetMatrix("_TerrainObjectToWorld", transform.localToWorldMatrix);
        computeShader.SetFloat("_Scale", scale);

        computeShader.GetKernelThreadGroupSizes(kernel, out threadGroupSize, out _, out _);
        int threadGroups = Mathf.CeilToInt(terrainTriangleCount / threadGroupSize);
        computeShader.Dispatch(kernel, threadGroups, 1, 1);
    }

    private void Update()
    {
        RenderParams rp = new RenderParams(material);
        rp.worldBounds = bounds;
        rp.matProps = new MaterialPropertyBlock();
        rp.matProps.SetBuffer("_TransformMatrices", transformMatrixBuffer);
        rp.matProps.SetBuffer("_Positions", FishMeshVertexBuffer);
        rp.matProps.SetBuffer("_UVs", FishMeshUVBuffer);

        Graphics.RenderPrimitivesIndexed(rp, MeshTopology.Triangles, FishMeshTriangleBuffer, FishMeshTriangleBuffer.count, instanceCount: terrainTriangleCount);
    }

    private void OnDestroy()
    {
        transformMatrixBuffer.Dispose();

        FishMeshVertexBuffer.Dispose();
        FishMeshUVBuffer.Dispose();
    }
}
