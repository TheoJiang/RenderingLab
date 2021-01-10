Shader "Unlit / OutLine"
{
    Properties
    {
        _Color("outline color",color) = (1,1,1,1)
        _Width("outline width",range(0,1)) = 0.2
        _MaskColor("Mask Color", Color) = (1, 1, 1, 1)

    }
    Subshader
    {
        Pass
        {
            Tags {"LightMode" = "LightweightForward" "RenderType" = "Opaque" "Queue" = "Geometry + 10"}
            //Tags可不添加，只是为了演示
            
            // 直接无脑的全替换为 1， 且不输出颜色
//            colormask 0 //不输出颜色
            ZWrite Off
            ZTest Off
 
            Stencil
            {
                Ref 1
                Comp Always
                Pass replace
            }
 
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Width;
            // CBUFFER_END
            float4 _MaskColor;

            struct appdata
            {
                float4 vertex: POSITION;
            };
 
            struct v2f
            {
                float4 vertex: SV_POSITION;
            };
 
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
 
            half4 frag(v2f i) : SV_Target
            {
                return _MaskColor;
                return half4 (0.0h, 0.0h, 0.0h, 1.0h);
            }
            ENDHLSL
        }
 
        Pass
        {
            Tags {"RenderType" = "Opaque" "Queue" = "Geometry + 20"}
 
            ZTest off
 
            Stencil {
                Ref 1
                Comp notEqual
                Pass keep
            }
 
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            half _Width;
            CBUFFER_END
            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal:NORMAL;
            };
 
            struct v2f
            {
                float4 vertex: SV_POSITION;
            };
 

 
            v2f vert(appdata v)
            {
                v2f o;
                //v.vertex.xyz += _Width * normalize(v.vertex.xyz);
 
                v.vertex.xyz += _Width * normalize(v.normal);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }
 
            half4 frag(v2f i) : SV_Target
            {
                return _Color;
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Mask"
            Tags{"LightMode" = "Mask"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _MaskColor;

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 vertex : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                return _MaskColor;
            }

            ENDHLSL
        }
    }
}