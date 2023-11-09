using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// attach this to a camera object to do post processing on it!

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
public class PostProcessWaves : MonoBehaviour
{
    [SerializeField]
    Material postProcessMat; //post process material using our shader

    //do the post process render
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postProcessMat);
    }
}
