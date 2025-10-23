using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenu("LucidBoundary/Grayscale")]
public sealed class PPE_GrayscaleSetting: VolumeComponent, IPostProcessComponent
{
    public ClampedFloatParameter strength = new ClampedFloatParameter(0.0f, 0.0f, 1.0f);

    public bool IsActive() => strength.value > 0.0f && active;
    public bool IsTileCompatible() => false;
}
