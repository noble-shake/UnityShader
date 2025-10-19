using UnityEngine;

public class ModifyingKeyword_Script : MonoBehaviour
{
    [SerializeField] private MeshRenderer rend;
    [SerializeField] private Material material;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        rend = GetComponent<MeshRenderer>();
        material = rend.material;
    }

    // Update is called once per frame
    void Update()
    {
        bool toggelr = Time.time % 2.0f > 1.0f;

        if (toggelr)
        {
            material.EnableKeyword("OVERRIDE_RED_ON");
        }
        else
        {
            material.DisableKeyword("OVERRIDE_RED_ON");
        }
    }
}
