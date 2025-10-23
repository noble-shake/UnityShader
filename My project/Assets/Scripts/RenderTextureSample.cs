using UnityEngine;

public class RenderTextureSample : MonoBehaviour
{
    public Camera cam;
    public Material mat;
    private RenderTexture renderTexture;

    private void Start()
    {
        renderTexture = new RenderTexture(1920, 1080, 32, RenderTextureFormat.ARGB32);
        renderTexture.Create();

        cam.targetTexture = renderTexture;
        mat.SetTexture("_MainTex", renderTexture);
    }
}
