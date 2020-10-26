Shader "WavingGrass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }

        _GustNoise ("风噪", 2D) = "white" { }
        _OffsetType ("Type", Range(0, 1)) = 0
        _TransparentLerp("透明过渡插值", Range(0, 2)) = 0
        _TopColor ("Top Color", Color) = (1, 1, 1, 1)
        _BottomColor ("Bottom Color", Color) = (1, 1, 1, 1)
        _ColorBlendLerp("颜色过渡插值", Range(0, 2)) = 0
        _RootFreeze("根部冻结", Range(0, 1)) = 0
        // _OffsetFrequency ("草偏移频率", Range(0, 10)) = 0
        // _OffsetStrength ("草位移强度", Range(0, 20)) = 0
        _OffsetPeriod ("周期", float) = 0
        _OffsetAmplitude ("振幅", float) = 0

        _ShearStrength ("横向倾斜强度", Range(0, 10)) = 0

        _WindSpeed ("风速", Range(0, 10)) = 1
        _WindFrequency ("风频", Range(0, 10)) = 1
        _WindDirect ("风向 x, z", Vector) = (0, 0, 0, 0)
        _Wind2Direct ("风向2 x, z", Vector) = (0, 0, 0, 0)
        _WindTintStrength ("风噪着色强度", Range(0, 10)) = 0
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Color Src Blend Mode", Float) = 1  //声明外部控制开关
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Color Dst Blend Mode", Float) = 1  //声明外部控制开关
        
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha ("Alpha Src Blend Mode", Float) = 1  //声明外部控制开关
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha ("Alpha Dst Blend Mode", Float) = 1  //声明外部控制开关
    }
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline"  "RenderType"="Transparent" "Queue"="Transparent" }
        
        Cull Off
        HLSLINCLUDE
        #pragma target 2.0
        ENDHLSL
        
        LOD 100

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend [_SrcBlend] [_DstBlend], [_SrcBlendAlpha] [_DstBlendAlpha]
            ZWrite Off
			// ZTest LEqual
            HLSLPROGRAM
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #pragma enable_d3d11_debug_symbols

            //#include "UnityCG.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct VertexInput
            {
                float4 positionOS: POSITION;
                float2 uv: TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float2 uv: TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 positionOS: SV_POSITION;
                float3 positionWS: TEXCOORD1;
                float4 color: COLOR;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _GustNoise;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _GustNoise_ST;
            float _OffsetType;
            float _TransparentLerp;
            // float _OffsetFrequency;
            float _OffsetStrength;
            float _OffsetPeriod;
            float _OffsetAmplitude;
            float _ShearStrength;
            float4 _TopColor;
            float4 _BottomColor;
            float _ColorBlendLerp;
            float _RootFreeze;
            float _WindSpeed;
            float _WindFrequency;
            float4 _WindDirect;
            float4 _Wind2Direct;
            float _WindTintStrength;
            CBUFFER_END
            
            // UNITY_INSTANCING_BUFFER_START(Props)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _OffsetType)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransparentType)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _OffsetFrequency)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _OffsetStrength)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _OffsetPeriod)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _OffsetAmplitude)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _ShearStrength)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _TopColor)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _BottomColor)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _WindSpeed)
            //     UNITY_DEFINE_INSTANCED_PROP(half, _WindFrequency)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _WindDirect)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _Wind2Direct)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _WindTintStrength)
            // UNITY_INSTANCING_BUFFER_END(Props)

            float3 RGBToHSV(float3 c)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
                float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
                float d = q.x - min(q.w, q.y);
                float e = 1.0e-10;
                return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 HSVToRGB(float3 c)
            {
                float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
                return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
            }
            
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o); // necessary only if you want to access instanced properties in the fragment Shader.

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float rand = frac(UNITY_MATRIX_M[0][1] + UNITY_MATRIX_M[1][2] + UNITY_MATRIX_M[2][3]) / 2;
                
                // VertexPositionInputs vi = GetVertexPositionInputs(v.positionOS);                

                
                o.positionWS = TransformObjectToWorld(v.positionOS);
                
                // 取到风噪图的颜色. 色值代表风的方向
                //float2 uvW = _WindFrequency * 0.01 * o.positionWS.xz + clamp(0, 1, sin((-0.01) * _WindFrequency * _WindSpeed * _Time.y * normalize(_WindDirect.xyz).xz) );
                float2 uvW = _WindFrequency * 0.01 * o.positionWS.xz + (-0.01) * _WindFrequency * _WindSpeed * _Time.y * normalize(_WindDirect.xyz).xz;
                //float3 sWD = float3(_WindDirect.xy, -_WindDirect.z);
                float2 uvW1 = _WindFrequency * 0.01 * o.positionWS.xz + (-0.01) * _WindFrequency * _WindSpeed * _Time.y * normalize(_Wind2Direct.xyz).xz;
                
                uvW = TRANSFORM_TEX(uvW, _GustNoise);
                uvW = TRANSFORM_TEX(uvW1, _GustNoise);
                
                float3 color = tex2Dlod(_GustNoise, float4(uvW, 0, 0)).xxx;
                float3 color1 = tex2Dlod(_GustNoise, float4(uvW1, 0, 0)).xxx;
                //color.xz *= (normalize(_WindDirect)).xz;
                //color1.xz *= (normalize(_Wind2Direct)).xz;
                float3 combineColor = color + color1;
                    
                combineColor = RGBToHSV(combineColor);
                combineColor.y = 0.3;
                combineColor = HSVToRGB(combineColor);
                o.color = clamp(0,1,float4(combineColor, 1));
                //color = color*color;
                float3 center = float3(0, 0, 0);
                float3 eyeOS = TransformWorldToObject(GetCameraPositionWS());
                float3 zDir = eyeOS - center;   // 中心点到视点的方向, 也是新坐标系的 下的法线方向, 也是Z轴
                // (对于本地坐标系下呈竖直状态的面而言) z轴要么是在原始本地坐标系的xz平面上. 要么就是原始的中心点到视点方向. 无论哪种, 其指向趋势都是向着视点的
                //zDir.y = zDir.y * round(_OffsetType);
                zDir = normalize(zDir);
                
                // 将原本地坐标系的Y轴与zDir点乘. 用得到的值来判断是否是同向的. 同向肯定为正. 颜色不是黑色. 反之则是黑色的.
                // 当zDir.y 不等于0时, 也就是_Type值为1时, zDir就是锚点到视点的方向.被视为了法线和新z轴. 此时本地坐标系的Y轴和zDir趋向同向.
                // 当ZDir.y 等于0时, 也就是_Type值为0时, 说明将指向压平至了原坐标系的,Z
                //float3 testA = UNITY_MATRIX_M[2].xyz;
                //o.color = float4(dot(zDir, testA),dot(zDir, testA),dot(zDir, testA),1) + 0.5;
                
                // 定义向上的方向, 主要是(0,1,0). 目前只是人为的定义的, 后续会重新进行计算出真正合理的y方向
                // z与y会构成一个新的平面. 无论他们是否垂直, 但都能求得一个垂直于这个平面的向量作为x轴
                float3 yDir = abs(zDir.y) > 0.999 ? float3(0, 0, 1): float3(0, 1, 0);
                
                float3 xDir = normalize(cross(yDir, zDir));
                // xDir += float3(0.2,0,0);
                // 如果在y方向也在跟随的话. 也就是_Type值为1时
                yDir = normalize(cross(zDir, xDir));
                
                
                float3 localZAxis = float3(UNITY_MATRIX_M[0][2], UNITY_MATRIX_M[1][2], UNITY_MATRIX_M[2][2]);
                half dotRes = abs(dot(localZAxis, zDir));

                float3 centerOffs = v.positionOS.xyz; // - center
                float4x4 billMatrix = {
                    xDir.x, yDir.x, zDir.x, 0,
                    xDir.y, yDir.y, zDir.y, 0,
                    xDir.z, yDir.z, zDir.z, 0,
                    0, 0, 0, 1,
                };

                // 草斜切矩阵
                float4x4 shearMatrix1 = {
                    1, sin(_TimeParameters.y * color.x) * _ShearStrength, 0, 0,
                    0, 1, 0, 0,
                    0, 0, 1, 0,
                    0, 0, 0, 1,
                };

                float3 localPos = mul(shearMatrix1, float4(centerOffs, 1));
                localPos = mul(billMatrix, localPos);

                // float3 offset = color;
                float uvVLimit = clamp(0.5, 1, o.uv.y + 0.5) * 0 + 1;
                //uvVLimit = 1;
                // 草偏移频率增强             根据视线方向对增强系数定向       根据偏移方向进行偏移
                // float2 _OffsetFreq = sin(_TimeParameters.x * _OffsetFrequency);
                //* - zDir.xz  * (color.xz * _WindDirect  + color1.xz * _Wind2Direct) ;
                //localPos.xz += _OffsetFreq * 50 * uvVLimit * _OffsetStrength;
                localPos.xz += lerp(0, sin(_OffsetPeriod * (color.xz * _WindDirect + color1.xz * _Wind2Direct)) * _OffsetAmplitude, _RootFreeze);
                //localPos.xz += sin(_OffsetPeriod * (color.xz * _WindDirect + color1.xz * _Wind2Direct)) * _OffsetAmplitude;
                o.positionOS = TransformObjectToHClip(float4(localPos, 1));
                return o;
            }

            half4 frag(VertexOutput i): SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                half4 col = tex2D(_MainTex, i.uv);
                col.a *= lerp(0, clamp(0.5,1,col.r + i.color.r), _TransparentLerp * i.uv.y) ;

                half4 mixColor = lerp(_BottomColor , _TopColor, _ColorBlendLerp* i.uv.y);
                col.rgb = max(0.2,i.color).xxx * mixColor.rgb* _WindTintStrength;
                //col.rgb = max(0.5,col.rgb);
                return col;

                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
            }
            ENDHLSL
            
        }
    }
}
