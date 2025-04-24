using UnityEngine;

public class SnowMaskPainter : MonoBehaviour
{
    public RenderTexture maskTexture;
    public Material drawMaterial;
    public Transform character;
    public float radius = 0.05f;

    void Update()
    {
        if (Physics.Raycast(character.position + Vector3.up * 5, Vector3.down, out RaycastHit hit))
        {
            Vector2 uv = hit.textureCoord;
            drawMaterial.SetVector("_UV", new Vector4(uv.x, uv.y, radius, 0));
            drawMaterial.SetTexture("_MainTex", maskTexture);
            Graphics.Blit(null, maskTexture, drawMaterial, 0); // Pass 0: рисуем круг
        }

        drawMaterial.SetFloat("_Fade", 0.98f);
        Graphics.Blit(maskTexture, maskTexture, drawMaterial, 1); // Pass 1: затухание
    }
}
