using UnityEngine;

public class ImprovedDissolve_Script : MonoBehaviour
{
    [SerializeField] MeshRenderer disRender;
    [SerializeField] Material mat;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        mat = disRender.material;
    }

    private void Update()
    {
        if (mat == null) return;
        mat.SetVector("_PlaneOrigin", transform.position);
        mat.SetVector("_PlaneNormal", transform.up);
    }
}
