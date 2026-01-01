using UnityEngine;

public class RimFresnelControl : MonoBehaviour
{
    public SkinnedMeshRenderer[] MeshRenderers;
    public Material[] OutlineMats;
    public Material[] ShadingMats;
    public float ColorDiv = 1;
    public float FresnelPow = 1;
    public float RimPow = 1;
    public float OutlineThick = 0.05f;
    public float speed;
    public Color FresnelColor = Color.black;
    public Color RimColor = Color.black;

    private void Start()
    {
        OutlineMats = new Material[MeshRenderers.Length];
        ShadingMats = new Material[MeshRenderers.Length];
        for (int index = 0; index < MeshRenderers.Length; index++)
        {
            OutlineMats[index] = Instantiate(MeshRenderers[index].materials[1]);
            ShadingMats[index] = Instantiate(MeshRenderers[index].materials[0]);
            MeshRenderers[index].materials[0] = ShadingMats[index];

            MeshRenderers[index].materials[1] = OutlineMats[index];
        }
    }

    private void Update()
    {
        for (int index = 0; index < MeshRenderers.Length; index++)
        {
            ShadingMats[index].SetFloat("_Div", ColorDiv);
            ShadingMats[index].SetFloat("_FresnelPower", FresnelPow);
            ShadingMats[index].SetFloat("_RimPower", RimPow);
            ShadingMats[index].SetColor("_FresnelColor", FresnelColor);
            ShadingMats[index].SetColor("_RimColor", RimColor);
            OutlineMats[index].SetFloat("_OutlineThick", OutlineThick);
            Material[] TempMats = new Material[] { ShadingMats[index], OutlineMats[index] };
            MeshRenderers[index].materials = TempMats;
            //MeshRenderers[index].materials[0] = ShadingMats[index];
            //MeshRenderers[index].materials[1] = OutlineMats[index];
        }

        transform.Rotate(new Vector3(0f, Time.unscaledDeltaTime * speed, 0f));
    }
}
