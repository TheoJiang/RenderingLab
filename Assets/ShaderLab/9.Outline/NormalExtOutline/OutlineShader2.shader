Shader "OutLine_type2"
{
    Properties
    {
        _Matcap("Matcap", 2D) = "white" {}
 
        _Color("outline color",color) = (1,1,1,1)
        _Width("outline width",range(0,1)) = 0.2
 
        [Space][Header(Ztest State)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Ztest", Float) = 0.0
    }
 
    Subshader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" "IgnoreProjector" = "True"}
 
        LOD 300
 
        Cull Back
        HLSLINCLUDE
        #pragma target 2.0
        ENDHLSL
 
 
        Pass
        {
        //新增matcap效果
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
 
            ZWrite On
            ZTest LEqual
            Offset 0 , 0
 
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #define ASE_SRP_VERSION 999999
 
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
 
            #pragma vertex vert
            #pragma fragment frag
 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
 
            #if ASE_SRP_VERSION <= 70108
            #define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
            #endif
 
            #define ASE_NEEDS_VERT_NORMAL
 
 
            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 ase_normal : NORMAL;
 
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
 
            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                float3 worldPos : TEXCOORD0;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                float4 shadowCoord : TEXCOORD1;
                #endif
                #ifdef ASE_FOG
                float fogFactor : TEXCOORD2;
                #endif
                float4 ase_texcoord3 : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
 
            sampler2D _Matcap;
 
 
 
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
 
                half3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
                o.ase_texcoord3.xyz = ase_worldNormal;
 
 
                //setting value to unused interpolator channels and avoid initialization warnings
                o.ase_texcoord3.w = 0;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    float3 defaultVertexValue = v.vertex.xyz;
                #else
                    float3 defaultVertexValue = float3(0, 0, 0);
                #endif
                float3 vertexValue = defaultVertexValue;
                #ifdef ASE_ABSOLUTE_VERTEX_POS
                    v.vertex.xyz = vertexValue;
                #else
                    v.vertex.xyz += vertexValue;
                #endif
                v.ase_normal = v.ase_normal;
 
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float4 positionCS = TransformWorldToHClip(positionWS);
 
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                o.worldPos = positionWS;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                VertexPositionInputs vertexInput = (VertexPositionInputs)0;
                vertexInput.positionWS = positionWS;
                vertexInput.positionCS = positionCS;
                o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                #ifdef ASE_FOG
                o.fogFactor = ComputeFogFactor(positionCS.z);
                #endif
                o.clipPos = positionCS;
                return o;
            }
 
            half4 frag(VertexOutput IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
 
                #if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
                float3 WorldPosition = IN.worldPos;
                #endif
                float4 ShadowCoords = float4(0, 0, 0, 0);
 
                #if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        ShadowCoords = IN.shadowCoord;
                    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                        ShadowCoords = TransformWorldToShadowCoord(WorldPosition);
                    #endif
                #endif
                half3 ase_worldNormal = IN.ase_texcoord3.xyz;
 
                float3 BakedAlbedo = 0;
                float3 BakedEmission = 0;
                float3 Color = tex2D(_Matcap, ((mul(UNITY_MATRIX_V, half4(ase_worldNormal , 0.0)).xyz * 0.5) + 0.5).xy).rgb;
                float Alpha = 1;
                float AlphaClipThreshold = 0.5;
 
                #ifdef _ALPHATEST_ON
                    clip(Alpha - AlphaClipThreshold);
                #endif
 
                #ifdef ASE_FOG
                    Color = MixFog(Color, IN.fogFactor);
                #endif
 
                #ifdef LOD_FADE_CROSSFADE
                    LODDitheringTransition(IN.clipPos.xyz, unity_LODFade.x);
                #endif
 
                return half4(Color, Alpha);
            }
 
            ENDHLSL
        }
 
 
        Pass
        {
            Name "Mask"
            Tags {
            "LightMode" = "Mask"    //切记这里灯光模式为Mask
            "RenderType" = "Transparent"
            "Queue" = "Transparent + 10"
            }
     
            Cull off
            colormask 0
            ZWrite Off
            ZTest always
     
            Stencil
            {
                Ref 1
                Comp Always
                Pass replace
            }
 
        }
 
        Pass
        {
            Name "Fill"
            Tags {
            "LightMode" = "Fill"    //切记这里灯光模式为Fill
            "RenderType" = "Transparent"
            "Queue" = "Transparent + 20"
            "DisableBatching" = "True"
            }
 
 
            Cull Off
            ZWrite on
            ZTest [_ZTest]

            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB
 
            Stencil {
                Ref 1
                Comp notEqual
                Pass keep
            }
 
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
 
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float3 smoothNormal : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
 
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float4 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO
            };
 
            half4 _Color;
            half _Width;
 
            v2f vert(appdata v)
            {
                v2f o;
                 
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
 
                VertexPositionInputs input = GetVertexPositionInputs(v.vertex.xyz);
 
                //float3 normal = any(v.smoothNormal) ? v.smoothNormal : v.normal;
                float3 normal = v.normal;
                float3 viewPosition = input.positionVS;
                float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, normal));
 
                o.vertex = mul(UNITY_MATRIX_P, float4(viewPosition + viewNormal * -viewPosition.z * _Width / 100.0, 1.0));
                o.color = _Color;
 
                return o;
            }
 
            half4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDHLSL
        }
    }
}