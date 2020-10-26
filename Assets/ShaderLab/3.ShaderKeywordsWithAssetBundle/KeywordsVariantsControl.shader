Shader "Unlit/KeywordsVariantsControl"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature  _ KEY1 
            #pragma shader_feature  _ KEY2
            #pragma shader_feature  _ KEY3
            #pragma shader_feature  _ KEY4
            #pragma shader_feature  _ KEY5
            #pragma shader_feature _ KEY6
            #pragma shader_feature _ KEY7
            #pragma shader_feature _ KEY8
            #pragma shader_feature _ KEY9
            #pragma shader_feature _ KEY10
            #pragma shader_feature _ KEY11
            #pragma shader_feature _ KEY12
            #pragma shader_feature _ KEY13
            #pragma shader_feature _ KEY14
            #pragma shader_feature _ KEY15
            #pragma shader_feature _ KEY16
            #pragma shader_feature _ KEY17
            #pragma shader_feature _ KEY18
            #pragma shader_feature _ KEY19
            #pragma shader_feature _ KEY20
            #pragma shader_feature _ KEY21
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                #if KEY1
                    col.rgb = float3(1,0,0);
                #endif
                
                #if KEY2
                    col.rgb = float3(1,1,0);
                #endif
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
