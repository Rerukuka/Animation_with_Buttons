Shader "Custom/DrawOnMask"
{
    Properties
    {
        _MainTex ("Mask Texture", 2D) = "black" {}
        _UV ("Target UV", Vector) = (0,0,0.1,0)
        _Fade ("Fade Amount", Float) = 0.98
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "DrawCircle"
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _UV;
            float4 _MainTex_TexelSize;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 dist = i.uv - _UV.xy;
                float radius = _UV.z;
                float falloff = smoothstep(radius, radius * 0.5, length(dist));
                float base = tex2D(_MainTex, i.uv).r;
                return float4(max(base, 1.0 - falloff), 0, 0, 1);
            }
            ENDCG
        }

        Pass
        {
            Name "Fade"
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Fade;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float val = tex2D(_MainTex, i.uv).r;
                val *= _Fade;
                return float4(val, 0, 0, 1);
            }
            ENDCG
        }
    }
}
